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
#import "PerfLogger.h"

static dispatch_queue_t dt_networkQueue;// 网络请求在td_networkQueue中进行
static NSUInteger const kBatchSize = 10;

@interface DTEventTracker ()
@property (atomic, strong) DTConfig *config;
@property (atomic, copy) NSURL *sendURL;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) DTDBManager *dbOp;

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
        self.dbOp = [DTDBManager sharedInstance];
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
        BOOL result = [self.dbOp addEvent:event eventSyn:sync];
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
    
    if(![DTConfig shareInstance].enableUpload)
    {
        DTLogDebug(@"upload not enable");
        return;
    }
    
    [[DTPerfLogger shareInstance] doLog:TRACKBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    //判断网络
    NSString *networkType = [[DTReachability shareInstance] networkState];
    if (![DTReachability convertNetworkType:networkType]) {
        if (completion) {
            completion();
        }
        
        [[DTPerfLogger shareInstance] doLog:TRACKEND time:[NSDate timeIntervalSinceReferenceDate]];
        
        return;
    }
    //判断时间是否校准
    DTCalibratedTimeWithDTServer *timeCalibrater = [[DTAnalyticsManager shareInstance] calibratedTime];
    if(![timeCalibrater enable]){
        [timeCalibrater recalibrationWithDTServer];
        if (completion) {
            completion();
        }
        
        [[DTPerfLogger shareInstance] doLog:TRACKEND time:[NSDate timeIntervalSinceReferenceDate]];
        
        return;
    }
    
    [[DTPerfLogger shareInstance] doLog:READEVENTDATAFROMDBBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    // 获取数据库数据，取前十条数据
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodSyns;
    @synchronized (DTDBManager.class) {
        // 数据库里获取前kBatchSize条数据
        NSArray<DTDBEventModel *> *eventModes = [self.dbOp queryEventsCount:size];
        NSMutableArray *syns = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
        NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
        for (DTDBEventModel *eventMode in eventModes) {
            [self handleEventTime:eventMode syns:syns contents:contents];
            [self applySuperPropertiesIfNeeded:eventMode];
        }
        recodSyns = syns;
        recordArray = contents;
    }
    
    [[DTPerfLogger shareInstance] doLog:READEVENTDATAFROMDBEND time:[NSDate timeIntervalSinceReferenceDate]];
    
    // 数据库没有数据了
    if (recordArray.count == 0 || recodSyns.count == 0) {
        if (completion) {
            completion();
        }
        
        [[DTPerfLogger shareInstance] doLog:TRACKEND time:[NSDate timeIntervalSinceReferenceDate]];
        
        return;
    }
    
    // 网络情况较好，会在此处持续的将数据库中的数据发送完
    // 保证end事件发送成功
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && recodSyns.count > 0 && flushSucc) {
        @autoreleasepool {
            [[DTPerfLogger shareInstance] doLog:UPLOADDATABEGIN time:[NSDate timeIntervalSinceReferenceDate]];
            
            flushSucc = [self sendEventsData:recordArray];
            
            [[DTPerfLogger shareInstance] doLog:UPLOADDATAEND time:[NSDate timeIntervalSinceReferenceDate]];
            
            if (flushSucc) {
                @synchronized (DTDBManager.class) {
                    
                    [[DTPerfLogger shareInstance] doLog:DELETEDBBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
                    
                    BOOL ret = [self.dbOp deleteEventsWithSyns:recodSyns];
                    
                    [[DTPerfLogger shareInstance] doLog:DELETEDBEND time:[NSDate timeIntervalSinceReferenceDate]];
                    
                    if (!ret) {
                        break;
                    }
                    // 数据库里获取前kBatchSize条数据
                    [[DTPerfLogger shareInstance] doLog:READEVENTDATAFROMDBBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
                    
                    NSArray<DTDBEventModel *> *eventModes = [self.dbOp queryEventsCount:size];
                    NSMutableArray *syns = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
                    NSMutableArray *contents = [[NSMutableArray alloc] initWithCapacity:eventModes.count];
                    for (DTDBEventModel *eventMode in eventModes) {
                        [self handleEventTime:eventMode syns:syns contents:contents];
                    }
                    recodSyns = syns;
                    recordArray = contents;
                    
                    [[DTPerfLogger shareInstance] doLog:READEVENTDATAFROMDBEND time:[NSDate timeIntervalSinceReferenceDate]];
                    
                }
            } else {
                break;
            }
        }
    }
    if (completion) {
        completion();
    }
    
    [[DTPerfLogger shareInstance] doLog:TRACKEND time:[NSDate timeIntervalSinceReferenceDate]];
}

- (void)handleEventTime:(DTDBEventModel *) eventMode syns:(NSMutableArray *)syns contents:(NSMutableArray *)contents {
    DTCalibratedTimeWithDTServer *timeCalibrater = [[DTAnalyticsManager shareInstance] calibratedTime];
    NSNumber *eventTime = eventMode.data[@"#event_time"];
    //事件时间已校准
    if (eventTime && [eventTime longValue] > 0){
        [eventMode.data removeObjectForKey:@"#event_su_time"];
        [eventMode.data removeObjectForKey:@"#event_device_time"];
        [eventMode.data removeObjectForKey:@"#process_sessionId"];

        [syns addObject:eventMode.eventSyn];
        [contents addObject:eventMode.data];
    } else {
        //时间同步器可用
        if (timeCalibrater && [timeCalibrater enable]) {
            NSNumber *eventSystemUpTime = eventMode.data[@"#event_su_time"];
            
            void(^defaulHandle)(void) = ^{
                
                NSTimeInterval outTime = [eventSystemUpTime doubleValue] - timeCalibrater.systemUptime ;
                NSTimeInterval realTime = timeCalibrater.serverTime + outTime;
                [eventMode.data setValue:[self formatTime:realTime * 1000] forKey:@"#event_time"];
                [eventMode.data removeObjectForKey:@"#event_device_time"];
                [eventMode.data removeObjectForKey:@"#process_sessionId"];
                [eventMode.data removeObjectForKey:@"#event_su_time"];
                [syns addObject:eventMode.eventSyn];
                [contents addObject:eventMode.data];
            };
            
            NSString *sessionId = eventMode.data[@"#process_sessionId"];
            NSNumber *dHistoryTime = [eventMode.data objectForKey:@"#event_device_time"];
            if ([sessionId isEqualToString:[DTBaseEvent sessionId]] || !dHistoryTime) {
                //               当次进程采集的上报，时间是完全可信的
                defaulHandle();
            } else {
                
                //更新服务器时开机时间
                NSTimeInterval updateSystemUpTime = timeCalibrater.systemUptime;
                
                // 开机时间的间隔
                NSTimeInterval sInterval = updateSystemUpTime - [eventSystemUpTime doubleValue];
                NSTimeInterval deviceTime = timeCalibrater.deviceTime;
                
                // 系统时间间隔
                NSTimeInterval dInterval = deviceTime - [dHistoryTime doubleValue];
                NSTimeInterval realTime = 0.;
                
                if ([timeCalibrater isDeviceTimeCorrect]) {
                    if ((sInterval * dInterval) > 0 && fabs( sInterval - dInterval) < 5 * 60) {
                        NSTimeInterval outTime = [eventSystemUpTime doubleValue] - timeCalibrater.systemUptime ;
                        realTime = timeCalibrater.serverTime + outTime;
                    } else {
                        realTime = [dHistoryTime doubleValue];
                    }
                } else {
                    if ((sInterval * dInterval) > 0 && fabs( sInterval - dInterval) < 5 * 60) {
                        NSTimeInterval outTime = [eventSystemUpTime doubleValue] - timeCalibrater.systemUptime ;
                        realTime = timeCalibrater.serverTime + outTime;
                    } else {
//                        NSMutableDictionary *props = [eventMode.data objectForKey:@"properties"];
//                        [props setValue:@(false) forKey:@"#time_trusted"];
                        [eventMode.data setValue:@(false) forKey:@"#time_trusted"];
                        realTime = [dHistoryTime doubleValue];
                    }
                }
                
                [eventMode.data setValue:[self formatTime:realTime * 1000] forKey:@"#event_time"];
                [eventMode.data removeObjectForKey:@"#event_device_time"];
                [eventMode.data removeObjectForKey:@"#process_sessionId"];
                [eventMode.data removeObjectForKey:@"#event_su_time"];
                [syns addObject:eventMode.eventSyn];
                [contents addObject:eventMode.data];
            }
        }
    }
}

- (void)applySuperPropertiesIfNeeded:(DTDBEventModel *)eventMode {
    BOOL hasSet = [eventMode.data[@"hasSetCommonProperties"] boolValue];
    if (!hasSet) {
        NSDictionary *properties = [eventMode.data objectForKey:@"properties"];
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:properties];
        
        DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
        // 静态公共属性
        NSDictionary *superProperties = instance.currentSuperProperties;
        
        // 动态公共属性
        NSDictionary *superDynamicProperties = instance.currentDynamicProperties;
        
        // 需要共享的公共属性
        NSDictionary *inMemoryCommonProperties = instance.currentInMemoryCommonProperties;
        
        [temp addEntriesFromDictionary:superProperties];
        [temp addEntriesFromDictionary:superDynamicProperties];
        [temp addEntriesFromDictionary:inMemoryCommonProperties];
        [eventMode.data setObject:temp forKey:@"properties"];
    }
    [eventMode.data removeObjectForKey:@"hasSetCommonProperties"];
}


- (void)syncSendAllData {
    dispatch_sync(dt_networkQueue, ^{});
}

//just for test purpose only
+ (NSInteger)getDBCount {
    @synchronized (DTDBManager.class) {
        return [[DTDBManager sharedInstance] queryEventCount];
    }
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
