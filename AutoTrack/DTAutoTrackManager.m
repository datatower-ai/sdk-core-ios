#import "DTAutoTrackManager.h"


#import "DTJSONUtil.h"
#import "DTConfig.h"
#import "DTAppLifeCycle.h"
#import "DTAppState.h"
#import "DTRunTime.h"
#import "DTPresetProperties+DTDisProperties.h"

#import "DTAppStartEvent.h"
#import "DTAppEndEvent.h"
#import "DTAppEndTracker.h"
#import "DTColdStartTracker.h"
#import "DTInstallTracker.h"
#import "DTAppState.h"
#import "DTAnalyticsManager.h"
#import "DTAppInitializeTracker.h"

#ifndef DT_LOCK
#define DT_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef DT_UNLOCK
#define DT_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif


@interface DTAutoTrackManager ()
/// key: 数据采集SDK的唯一标识  value: 开启的自动采集事件类型
@property (atomic, strong) NSMutableDictionary<NSString *, id> *autoTrackOptions;
@property (nonatomic, strong, nonnull) dispatch_semaphore_t trackOptionLock;

@property (nonatomic, strong) DTHotStartTracker *appHotStartTracker;
@property (nonatomic, strong) DTAppEndTracker *appEndTracker;
@property (nonatomic, strong) DTColdStartTracker *appColdStartTracker;
@property (nonatomic, strong) DTInstallTracker *appInstallTracker;
@property (nonatomic, strong) DTAppInitializeTracker *appInitializeTracker;

@end


@implementation DTAutoTrackManager

#pragma mark - Public

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static DTAutoTrackManager *manager = nil;
    dispatch_once(&once, ^{
        manager = [[[DTAutoTrackManager class] alloc] init];
        manager.autoTrackOptions = [NSMutableDictionary new];
        manager.trackOptionLock = dispatch_semaphore_create(1);
        [manager registerAppLifeCycleListener];
    });
    return manager;
}

- (void)trackWithAppid:(NSString *)appid withOption:(DTAutoTrackEventType)type {
    DT_LOCK(self.trackOptionLock);
    self.autoTrackOptions[appid] = @(type);
    DT_UNLOCK(self.trackOptionLock);
    
    //安装事件
    if (type & DTAutoTrackEventTypeAppInstall) {
        DTAppInstallEvent *event = [[DTAppInstallEvent alloc] initWithName:DT_APP_INSTALL_EVENT];
        // 安装事件提前1s统计
//        event.time = [[NSDate date] dateByAddingTimeInterval: -1];
        [self.appInstallTracker trackWithInstanceTag:appid event:event params:nil];
    }
    
    //初始化事件
//    if (type & DTAutoTrackEventTypeInitialize) {
//        DTAppInitializeEvent *event = [[DTAppInitializeEvent alloc] initWithName:DT_APP_INITIALIZE];
//        [self.appInitializeTracker trackWithInstanceTag:appid event:event params:nil];
//    }
    
    // 开始记录end事件时长
    if (type & DTAutoTrackEventTypeAppEnd) {
        DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
        [instance timeEvent:DT_APP_END_EVENT];
    }

    // 上报app_start 冷启动
    if (type & DTAutoTrackEventTypeAppStart) {
        dispatch_block_t mainThreadBlock = ^(){
            // 在下一个runloop中执行，此代码，否则relaunchInBackground会不准确。relaunchInBackground 在 AppLifeCycle 管理类中获得
            NSString *eventName = [DTAppState shareInstance].relaunchInBackground ? DT_APP_START_BACKGROUND_EVENT : DT_APP_START_EVENT;
            DTAppStartEvent *event = [[DTAppStartEvent alloc] initWithName:eventName];
            event.resumeFromBackground = NO;
            // 启动原因
            if (![DTPresetProperties disableStartReason]) {
                NSString *reason = [DTRunTime getAppLaunchReason];
                if (reason && reason.length) {
                    event.startReason = reason;
                }
            }
            DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
            [instance setInMemoryCommonProperties:@{COMMON_PROPERTY_IS_FOREGROUND:@YES}];
            
            [self.appColdStartTracker trackWithInstanceTag:appid event:event params:nil];
        };
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    }

}



#pragma mark - Private

- (BOOL)isAutoTrackEventType:(DTAutoTrackEventType)eventType {
    BOOL isIgnored = YES;
    for (NSString *appid in self.autoTrackOptions) {
        DTAutoTrackEventType type = (DTAutoTrackEventType)[self.autoTrackOptions[appid] integerValue];
        isIgnored = !(type & eventType);
        if (isIgnored == NO)
            break;
    }
    return !isIgnored;
}


- (DTAutoTrackEventType)autoTrackOptionForAppid:(NSString *)appid {
    return (DTAutoTrackEventType)[[self.autoTrackOptions objectForKey:appid] integerValue];
}



//MARK: - App Life Cycle

- (void)registerAppLifeCycleListener {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTAAppLifeCycleStateWillChangeNotification object:nil];
}

- (void)appStateWillChangeNotification:(NSNotification *)notification {
    DTAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];
    DTAppLifeCycleState oldState = [[notification.userInfo objectForKey:kTAAppLifeCycleOldStateKey] integerValue];

    if (newState == DTAppLifeCycleStateStart) {
        for (NSString *appid in self.autoTrackOptions) {
            DTAutoTrackEventType type = (DTAutoTrackEventType)[self.autoTrackOptions[appid] integerValue];
            
            // 只开启采集热启动的start事件。冷启动事件，在开启自动采集的时候上报
            if ((type & DTAutoTrackEventTypeAppStart) && oldState != DTAppLifeCycleStateInit) {
                NSString *eventName = [DTAppState shareInstance].relaunchInBackground ? DT_APP_START_BACKGROUND_EVENT : DT_APP_START_EVENT;
                DTAppStartEvent *event = [[DTAppStartEvent alloc] initWithName:eventName];
                event.resumeFromBackground = YES;
                // 启动原因
                if (![DTPresetProperties disableStartReason]) {
                    NSString *reason = [DTRunTime getAppLaunchReason];
                    if (reason && reason.length) {
                        event.startReason = reason;
                    }
                }
                DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
                [instance setInMemoryCommonProperties:@{COMMON_PROPERTY_IS_FOREGROUND:@YES}];
                
                [self.appHotStartTracker trackWithInstanceTag:appid event:event params:@{}];
            }
            
            if (type & DTAutoTrackEventTypeAppEnd) {
                // 开始记录app_end 事件的时间
                DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
                [instance timeEvent:DT_APP_END_EVENT];
            }
        }
    } else if (newState == DTAppLifeCycleStateEnd) {
        for (NSString *appid in self.autoTrackOptions) {
            DTAutoTrackEventType type = (DTAutoTrackEventType)[self.autoTrackOptions[appid] integerValue];
            if (type & DTAutoTrackEventTypeAppEnd) {
                DTAppEndEvent *event = [[DTAppEndEvent alloc] initWithName:DT_APP_END_EVENT];
                DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
                [instance setInMemoryCommonProperties:@{COMMON_PROPERTY_IS_FOREGROUND:@NO}];
                [self.appEndTracker trackWithInstanceTag:appid event:event params:@{}];
            }
            
            if (type & DTAutoTrackEventTypeAppStart) {
                // 开始记录app_start 事件的时间
                DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
                [instance timeEvent:DT_APP_START_EVENT];
            }
        }
    }
}

//MARK: - Getter & Setter

- (DTHotStartTracker *)appHotStartTracker {
    if (!_appHotStartTracker) {
        _appHotStartTracker = [[DTHotStartTracker alloc] init];
    }
    return _appHotStartTracker;
}

- (DTColdStartTracker *)appColdStartTracker {
    if (!_appColdStartTracker) {
        _appColdStartTracker = [[DTColdStartTracker alloc] init];
    }
    return _appColdStartTracker;
}

- (DTInstallTracker *)appInstallTracker {
    if (!_appInstallTracker) {
        _appInstallTracker = [[DTInstallTracker alloc] init];
    }
    return _appInstallTracker;
}

- (DTAppEndTracker *)appEndTracker {
    if (!_appEndTracker) {
        _appEndTracker = [[DTAppEndTracker alloc] init];
    }
    return _appEndTracker;
}

- (DTAppInitializeTracker *)appInitializeTracker {
    if (!_appInitializeTracker) {
        _appInitializeTracker = [[DTAppInitializeTracker alloc] init];
    }
    return _appInitializeTracker;
}

@end
