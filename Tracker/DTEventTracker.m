//
//  DTEventTracker.m
//
//
//
//
#import "DTEventTracker.h"
#import "DTNetwork.h"
#import "DTReachability.h"
#import "DTDBManager.h"
#import "DTConfig.h"
#import "DTAnalyticsManager.h"
#import "DTDBEventModel.h"

static dispatch_queue_t td_networkQueue;// 网络请求在td_networkQueue中进行
static NSUInteger const kBatchSize = 10;

@interface DTEventTracker ()
@property (atomic, strong) DTNetWork *network;
@property (atomic, strong) DTConfig *config;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) DTDBManager *dataQueue;

@end

@implementation DTEventTracker

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"com.datatower.%p", (void *)self];
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        td_networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)td_networkQueue {
    return td_networkQueue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    if (self = [self init]) {
        self.queue = queue;
        self.config = [DTAnalyticsManager shareInstance].config;
//        self.network = [self generateNetworkWithConfig:self.config];
        self.dataQueue = [DTDBManager sharedInstance];
    }
    return self;
}



//MARK: - Public

- (void)track:(NSDictionary *)event sync:(NSString *)sync immediately:(BOOL)immediately {
    if (immediately) {
        DTLogDebug(@"queueing data flush immediately:%@", event);
        dispatch_async(self.queue, ^{
            dispatch_async(td_networkQueue, ^{
                [self flushImmediately:event];
            });
        });
    } else {
        DTLogDebug(@"queueing data:%@", event);
        // 存入数据库
        [self saveEventsData:event sync:sync];
    }
   
    [self flush];
}

- (void)flushImmediately:(NSDictionary *)event {
//    [self.network flushEvents:@[event]];
}

- (NSInteger)saveEventsData:(NSDictionary *)data sync:(NSString *)sync{
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count = 0;
    @synchronized (DTDBManager.class) {
        [self.dataQueue addEvent:event eventSyn:sync];
    }
    return count;
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
        dispatch_async(td_networkQueue, ^{
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
    // 1，保证end事件发送成功
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && recodSyns.count > 0 && flushSucc) {
//        flushSucc = [self.network flushEvents:recordArray];
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
                for (DTDBEventModel *eventMode in eventModes) {
                    [syns addObject:eventMode.eventSyn];
                    [contents addObject:eventMode.data];
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
    dispatch_sync(td_networkQueue, ^{});
}


//MARK: - Setter & Getter


@end
