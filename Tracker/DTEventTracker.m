//
//  DTEventTracker.m
//
//
//
//
#import "DTEventTracker.h"
#import "DTReachability.h"
#import "DTDBManager.h"
#import "DTConfig.h"
#import "DTAnalyticsManager.h"
#import "DTDBEventModel.h"
#import "DTJSONUtil.h"
#import "DTNetWork.h"
#import "DTReachability.h"

static dispatch_queue_t dt_networkQueue;// 网络请求在td_networkQueue中进行
static NSUInteger const kBatchSize = 10;

@interface DTEventTracker ()
@property (atomic, strong) DTConfig *config;
@property (atomic, copy) NSURL *sendURL;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) DTDBManager *dataQueue;

@end

@implementation DTEventTracker

+ (void)initialize {
    static dispatch_once_t DTOnceToken;
    dispatch_once(&DTOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"com.datatower.%p", (void *)self];
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        dt_networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

- (dispatch_queue_t)dt_networkQueue {
    return dt_networkQueue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    if (self = [self init]) {
        self.queue = queue;
        self.config = [DTAnalyticsManager shareInstance].config;
        self.sendURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/report", self.config.serverUrl]];
        self.dataQueue = [DTDBManager sharedInstance];
    }
    return self;
}



//MARK: - Public

- (void)track:(NSDictionary *)event sync:(NSString *)sync immediately:(BOOL)immediately {
    if (immediately) {
        DTLogDebug(@"queueing data flush immediately:%@", event);
        dispatch_async(self.queue, ^{
            dispatch_async(dt_networkQueue, ^{
                [self flushImmediately:event];
            });
        });
    } else {
        // 存入数据库
        [self saveEventsData:event sync:sync];
        
        [self flush];
    }
}

- (void)flushImmediately:(NSDictionary *)event {
    [self sendEventsData:@[event]];
}

- (void)saveEventsData:(NSDictionary *)data sync:(NSString *)sync{
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    @synchronized (DTDBManager.class) {
        BOOL result = [self.dataQueue addEvent:event eventSyn:sync];
        if(result) {
            DTLogDebug(@"save data success:%@", data[@"#event_name"]);
        }
    }
}

- (void)flush {
    [self _asyncWithCompletion:^{}];
}

/// 异步同步数据（将本地数据库中的数据同步到TA）
/// 需要将此事件加到serialQueue队列中进行哦
/// 有些场景是事件入库和发送网络请求是同时发生的。事件入库是在serialQueue中进行，上报数据是在networkQueue中进行。如要确保事件入库在先，则需要将上报数据操作添加到serialQueue
- (void)_asyncWithCompletion:(void(^)(void))completion {
    // 在任务队列中异步执行，需要判断当前是否已经在任务队列中，避免重复包装
    void(^block)(void) = ^{
        dispatch_async(dt_networkQueue, ^{
            [self _syncWithSize:kBatchSize completion:completion];
        });
    };
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(self.queue)) {
        block();
    } else {
        dispatch_async(self.queue, block);
    }    
}

/// 同步数据（将本地数据库中的数据同步到后台）
/// @param size 每次从数据库中获取的最大条数，默认10条
/// @param completion 同步回调
/// 该方法需要在networkQueue中进行，会持续的发送网络请求直到数据库的数据被发送完
- (void)_syncWithSize:(NSUInteger)size completion:(void(^)(void))completion {
    //判断网络
    NSString *networkType = [[DTReachability shareInstance] networkState];
    if (![DTReachability convertNetworkType:networkType]) {
        if (completion) {
            completion();
        }
        return;
    }
    // 获取数据库数据，取前十条数据
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodSyns;
    @synchronized (DTDBManager.class) {
        // 数据库里获取前kBatchSize条数据
        NSArray<DTDBEventModel *> *eventModes = [self.dataQueue queryEventsCount:size];
        NSMutableArray *syns = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
        NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
        for (DTDBEventModel *eventMode in eventModes) {
            [syns addObject:eventMode.eventSyn];
            [contents addObject:eventMode.data];
        }
        recodSyns = syns;
        recordArray = contents;
    }

    // 数据库没有数据了
    if (recordArray.count == 0 || recodSyns.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }

    // 网络情况较好，会在此处持续的将数据库中的数据发送完
    // 保证end事件发送成功
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && recodSyns.count > 0 && flushSucc) {
        flushSucc = [self sendEventsData:recordArray];
        if (flushSucc) {
            @synchronized (DTDBManager.class) {
                BOOL ret = [self.dataQueue deleteEventsWithSyns:recodSyns];
                if (!ret) {
                    break;
                }
                // 数据库里获取前kBatchSize条数据
                NSArray<DTDBEventModel *> *eventModes = [self.dataQueue queryEventsCount:size];
                NSMutableArray *syns = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
                NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
                //时间同步器
                DTCalibratedTime *timeCalibrater = [[DTAnalyticsManager shareInstance] calibratedTime];
                for (DTDBEventModel *eventMode in eventModes) {
                    NSNumber *eventTime = eventMode.data[@"#event_time"];
                    //事件时间已校准
                    if (eventTime && [eventTime longValue] > 0){
                        [eventMode.data removeObjectForKey:@"#event_su_time"];
                        [syns addObject:eventMode.eventSyn];
                        [contents addObject:eventMode.data];
                    }else {
                        //时间同步器可用
                        if (timeCalibrater && timeCalibrater.stopCalibrate == NO) {
                            NSNumber *eventSystemUpTime = eventMode.data[@"#event_su_time"];
                            NSTimeInterval outTime = [eventSystemUpTime longValue] - timeCalibrater.systemUptime * 1000;
                            NSTimeInterval realTime = timeCalibrater.serverTime * 1000 + outTime;
                            [eventMode.data setValue:[self formatTime:realTime] forKey:@"#event_time"];
                            
                            [eventMode.data removeObjectForKey:@"#event_su_time"];
                            [syns addObject:eventMode.eventSyn];
                            [contents addObject:eventMode.data];
                        }
                    }
                    
                }
                recodSyns = syns;
                recordArray = contents;
            }
        } else {
            break;
        }
    }
    if (completion) {
        completion();
    }
}


- (void)syncSendAllData {
    dispatch_sync(dt_networkQueue, ^{});
}
- (BOOL)sendEventsData:(NSArray<NSDictionary *> *) eventArray{
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    header[@"Content-Type"] = @"text/plain";
    
    NSString *jsonString = [DTJSONUtil JSONStringForObject:eventArray];
    NSData *postBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL reslult = [DTNetWork postRequestWithURL:self.sendURL requestBody:postBody headers:header];
    if (reslult) {
        DTLogDebug(@"flush success sendContent---->:%@",jsonString);
    }
    return reslult;
    
}

- (NSNumber *)formatTime:(NSTimeInterval)time {
    NSString *timeDoubleStr = [NSString stringWithFormat:@"%.3f", time];
    NSArray *arr = [timeDoubleStr componentsSeparatedByString:@"."];
    NSString *timeLongStr = [arr objectAtIndex:0];
    return @([timeLongStr longLongValue]);
}

//MARK: - Setter & Getter


@end
