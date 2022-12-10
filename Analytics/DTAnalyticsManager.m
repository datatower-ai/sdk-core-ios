//
//  DTAnalyticsManager.m
//  report
//
//  Created by neo on 2022/12/5.
//

#import "DTAnalyticsManager.h"
#import "DTPresetPropertyPlugin.h"
#import "DTReachability.h"
#import "DTPresetProperties+DTDisProperties.h"
#import "DTAppState.h"
#import "DTAppLifeCycle.h"
#import "DTTrackEvent.h"
#import "DTTrackTimer.h"
#import "DTAutoTrackManager.h"
#import "DTEventTracker.h"

@interface DTAnalyticsManager ()


/// 事件时长统计
@property (nonatomic, strong)DTTrackTimer *trackTimer;


@property (nonatomic, strong)DTEventTracker *eventTracker;

@end

@implementation DTAnalyticsManager

static DTAnalyticsManager *_manager = nil;

// track操作、操作数据库等在td_trackQueue中进行
static dispatch_queue_t dt_trackQueue;

+ (DTAnalyticsManager *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manager = [[DTAnalyticsManager alloc] init];
        NSString *queuelabel = [NSString stringWithFormat:@"com.datatower.%p", (void *)self];
        dt_trackQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
    return _manager;
}

- (void)initializeWithConfig:(DTConfig *)config {
    //App 状态
    [DTAppState shareInstance];
    //sdk 配置
    self.config = config;
    // 日志模块
    [self initLog];
    // 网络变化监听
    [self networkStateObserver];
    // 用户属性管理器
    [self initProperties];
    //事件计时
    self.trackTimer = [[DTTrackTimer alloc] init];
    // 事件入库、上报
    self.eventTracker = [[DTEventTracker alloc] initWithQueue:dt_trackQueue];
    //生命周期监听
    [self appLifeCycleObserver];
    //自动采集预置事件
    [self enableAutoTrack:DTAutoTrackEventTypeAll];
}

- (void)initLog {
    [DTLogging sharedInstance].loggingLevel = DTLoggingLevelInfo;
}

- (void)networkStateObserver {
    if (![DTPresetProperties disableNetworkType]) {
        [[DTReachability shareInstance] startMonitoring];
    }
}

- (void)appLifeCycleObserver{
    [DTAppLifeCycle startMonitor];
    [self registerAppLifeCycleListener];
}

//
- (void)initProperties {
    // 注册属性插件, 收集设备属性
    self.propertyPluginManager = [[DTPropertyPluginManager alloc] init];
    DTPresetPropertyPlugin *presetPlugin = [[DTPresetPropertyPlugin alloc] init];
    [self.propertyPluginManager registerPropertyPlugin:presetPlugin];
    
//    DTLogInfo(pluginProperties);
}

//MARK: - AppLifeCycle

- (void)registerAppLifeCycleListener {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTAAppLifeCycleStateWillChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(appStateDidChangeNotification:) name:kTAAppLifeCycleStateDidChangeNotification object:nil];
}

- (void)appStateWillChangeNotification:(NSNotification *)notification {
    DTAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];

    if (newState == DTAppLifeCycleStateEnd) {
//        [self stopFlushTimer];
    }
}

- (void)appStateDidChangeNotification:(NSNotification *)notification {
    DTAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];

    if (newState == DTAppLifeCycleStateStart) {
//        [self startFlushTimer];

        // 更新时长统计
//        NSTimeInterval systemUpTime = NSProcessInfo.processInfo.systemUptime;
//        [self.trackTimer enterForegroundWithSystemUptime:systemUpTime];
    } else if (newState == DTAppLifeCycleStateEnd) {
        // 更新事件时长统计
//        NSTimeInterval systemUpTime = NSProcessInfo.processInfo.systemUptime;
//        [self.trackTimer enterBackgroundWithSystemUptime:systemUpTime];
        
#if TARGET_OS_IOS
        // 开启后台任务发送事件
        UIApplication *application = [DTAppState sharedApplication];;
        __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        void (^endBackgroundTask)(void) = ^() {
            [application endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        };
        backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:endBackgroundTask];
        
        // 进入后台时，事件发送完毕，需要关闭后台任务。
        [self.eventTracker _asyncWithCompletion:endBackgroundTask];
#else
//        [self.eventTracker flush];
#endif
        
    } else if (newState == DTAppLifeCycleStateTerminate) {
        // 保证在app杀掉的时候，同步执行完队列内的任务
        dispatch_sync(dt_trackQueue, ^{});
        [self.eventTracker syncSendAllData];
    }
}

//MARK: - Auto Track

- (void)enableAutoTrack:(DTAutoTrackEventType)eventType {
    [[DTAutoTrackManager sharedManager] trackWithAppid:[self.config appid] withOption:eventType];
}

- (void)autoTrackWithEvent:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties {
    DTLogDebug(@"##### autoTrackWithEvent: %@", event.eventName);
    [self handleTimeEvent:event];
    [self asyncAutoTrackEventObject:event properties:properties];
}

/// 将事件加入到事件队列
/// @param event 事件
/// @param properties 自定义属性
- (void)asyncAutoTrackEventObject:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties {
    // 获取当前的SDK上报状态，并记录
//    event.isEnabled = self.isEnabled;
//    event.trackPause = self.isTrackPause;
//    event.isOptOut = self.isOptOut;
    
    dispatch_async(dt_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:NO];
    });
}

//MARK: - Track 事件

- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self track:event properties:propertiesDict time:nil timeZone:nil];
#pragma clang diagnostic pop
}

- (void)track:(NSString *)event properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    DTTrackEvent *trackEvent = [[DTTrackEvent alloc] initWithName:event];
    DTLogDebug(@"##### track.systemUpTime: %lf", trackEvent.systemUpTime);
//    [self configEventTimeValueWithEvent:trackEvent time:time timeZone:timeZone];
    [self handleTimeEvent:trackEvent];
    [self asyncTrackEventObject:trackEvent properties:properties isH5:NO];
}

#pragma mark - Private

/// 将事件加入到事件队列
/// @param event 事件
/// @param properties 自定义属性
- (void)asyncTrackEventObject:(DTTrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    // 获取当前的SDK上报状态，并记录
//    event.isEnabled = self.isEnabled;
//    event.trackPause = self.isTrackPause;
//    event.isOptOut = self.isOptOut;
    
    // 在当前线程获取动态公共属性
//    event.dynamicSuperProperties = [self.superProperty obtainDynamicSuperProperties];
    dispatch_async(dt_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:isH5];
    });
}

- (void)trackEvent:(DTTrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    // 判断是否允许上报
//    if (!event.isEnabled || event.isOptOut) {
//        return;
//    }
    // 当app后台启动时，是否开启数据采集
//    if ([DTAppState shareInstance].relaunchInBackground && !self.config.trackRelaunchedInBackgroundEvents) {
//        return;
//    }
    // 组装通用属性
    [self configBaseEvent:event];
    // 验证事件本身的合法性，具体的验证策略由事件对象本身定义。
    NSError *error = nil;
    [event validateWithError:&error];
    if (error) {
        return;
    }
//    // 过滤事件
//    if ([self.config.disableEvents containsObject:event.eventName]) {
//        return;
//    }

    // 是否是从后台启动
    if ([DTAppState shareInstance].relaunchInBackground) {
        event.properties[@"#relaunched_in_background"] = @YES;
    }
    // 添加从属性插件获取的属性，属性插件只有系统使用，不支持用户自定义。所以属性名字是可信的，不用验证格式
    NSMutableDictionary *pluginProperties = [self.propertyPluginManager propertiesWithEventType:event.eventType];
  
    NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];
    
    [event.properties addEntriesFromDictionary:pluginProperties];
    // 获取当前组装好的最新的属性值
    jsonObj = event.jsonObject;
    
    // 校验用户自定义属性
    properties = [DTPropertyValidator validateProperties:properties validator:event];
    [event.properties addEntriesFromDictionary:properties];
    
    // 将属性中所有NSDate对象，用指定的 timezone 转换成时间字符串
    jsonObj = [event formatDateWithDict:jsonObj];
    
    // 发送数据
    [self.eventTracker track:jsonObj immediately:event.immediately saveOnly:event.isTrackPause];
}


- (void)handleTimeEvent:(DTTrackEvent *)trackEvent {
    // 添加事件统计时长
    BOOL isTrackDuration = [self.trackTimer isExistEvent:trackEvent.eventName];
    BOOL isEndEvent = [trackEvent.eventName isEqualToString:DT_APP_END_EVENT];
    BOOL isStartEvent = [trackEvent.eventName isEqualToString:DT_APP_START_EVENT];
    BOOL isStateInit = [DTAppLifeCycle shareInstance].state == DTAppLifeCycleStateInit;
    
    if (isStateInit) {
        // 兼容冷启动中使用sleep的情况, 也就是在主线程中使用sleep的情况，虽然情况发生的概率是0.000000001%，但还是要兼容下，你懂得😊
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:YES systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
        
    } else if (isStartEvent) {
        // 计算start事件后台时长
        trackEvent.backgroundDuration = [self.trackTimer backgroundDurationOfEvent:trackEvent.eventName isActive:NO systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
        
    } else if (isEndEvent) {
        // 计算end时间前台时长
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:YES systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];

    } else if (isTrackDuration) {
        // 计算自定义事件的时长
        // app 是否在前台
        BOOL isActive = [DTAppState shareInstance].isActive;
        // 计算累计前台时长
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:isActive systemUptime:trackEvent.systemUpTime];
        // 计算累计后台时长
        trackEvent.backgroundDuration = [self.trackTimer backgroundDurationOfEvent:trackEvent.eventName isActive:isActive systemUptime:trackEvent.systemUpTime];
        
        DTLogDebug(@"#####eventName: %@, foregroundDuration: %d", trackEvent.eventName, trackEvent.foregroundDuration);
        DTLogDebug(@"#####eventName: %@, backgroundDuration: %d", trackEvent.eventName, trackEvent.backgroundDuration);
        // 计算时长后，删除当前事件的记录
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else {
        // 没有事件时长的 TD_APP_END_EVENT 事件，判定为重复的无效 end 事件。（系统的生命周期方法可能回调用多次，会造成重复上报）
        if (trackEvent.eventName == DT_APP_END_EVENT) {
            return;
        }
    }
}

- (void)configBaseEvent:(DTBaseEvent *)event {
    // 添加通用的属性
//    event.accountId = self.accountId;
//    event.distinctId = self.getDistinctId;
//    // 如果没有设置timezone，则获取config对象中的默认时区
//    if (event.timeZone == nil) {
//        event.timeZone = self.config.defaultTimeZone;
//    }
    // 事件如果没有指定时间，那么使用系统时间时需要校准
//    if (event.timeValueType == DTEventTimeValueTypeNone && calibratedTime && calibratedTime.stopCalibrate == NO) {
//        NSTimeInterval outTime = NSProcessInfo.processInfo.systemUptime - calibratedTime.systemUptime;
//        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(calibratedTime.serverTime + outTime)];
//        event.time = serverDate;
//    }
}

- (void)timeEvent:(NSString *)event {
//    if ([self hasDisabled]) {
//        return;
//    }
    NSError *error = nil;
    [DTPropertyValidator validateEventOrPropertyName:event withError:&error];
    if (error) {
        return;
    }
    [self.trackTimer trackEvent:event withSystemUptime:NSProcessInfo.processInfo.systemUptime];
}




@end
