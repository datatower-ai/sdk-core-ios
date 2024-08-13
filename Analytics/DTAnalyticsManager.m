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
#import "DTFile.h"
#import "DTDeviceInfo.h"
#import "DTAppStartEvent.h"
#import "DTAppEndEvent.h"
#import "DTUserPropertyHeader.h"
#import "PerfLogger.h"

@interface DTAnalyticsManager ()

/// 公共属性
@property (nonatomic, strong) DTSuperProperty *superProperty;

/// 事件时长统计
@property (nonatomic, strong)DTTrackTimer *trackTimer;

@property (nonatomic, strong)DTEventTracker *eventTracker;

@property (atomic, copy, nullable) NSString *accountId;

@property (atomic, copy, nullable) NSString *distinctId;

@property (strong, nonatomic) DTFile *file;

@property (nonatomic, assign) BOOL hasSetUserOnce;

@property (nonatomic, strong) NSMutableDictionary *inMemoryCommonProps;

@end

@implementation DTAnalyticsManager

static DTAnalyticsManager *_manager = nil;

// track操作、操作数据库等在td_trackQueue中进行
static dispatch_queue_t dt_trackQueue;

+ (DTAnalyticsManager *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manager = [[DTAnalyticsManager alloc] init];
        NSString *queuelabel = [NSString stringWithFormat:@"com.datatower.main.%p", (void *)self];
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
    //恢复持久化数据
    [self retrievePersistedData];
    // 用户属性管理器
    [self initProperties];
    //事件计时
    self.trackTimer = [[DTTrackTimer alloc] init];
    // 事件入库、上报
    self.eventTracker = [[DTEventTracker alloc] initWithQueue:dt_trackQueue];
    //同步时间
    [self calibratedTimeWithDTServer];
    //生命周期监听
    [self appLifeCycleObserver];
    //采集预置事件
    [self trackPresetEvents];
    
    self.inMemoryCommonProps = [[NSMutableDictionary alloc] init];
}

- (void)initLog {
    if ([[self config] enabledDebug]) {
        [DTLogging sharedInstance].loggingLevel = [self config].logLevel;
    }
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

- (void)calibratedTimeWithDTServer {
    self.calibratedTime = [[DTCalibratedTimeWithDTServer alloc]
                           initWithNetworkQueue:[self.eventTracker dt_networkQueue] url:self.config.serverUrl appId:self.config.appid];
    [self.calibratedTime recalibrationWithDTServer];
}

- (void)initProperties {
    // 初始化公共属性管理
    self.superProperty = [[DTSuperProperty alloc] initWithToken:self.config.appid isLight:NO];
    // 注册属性插件, 收集设备属性
    self.propertyPluginManager = [[DTPropertyPluginManager alloc] init];
    DTPresetPropertyPlugin *presetPlugin = [[DTPresetPropertyPlugin alloc] init];
    [self.propertyPluginManager registerPropertyPlugin:presetPlugin];
    
    //预置属性，用于用户属性设置
    self.presetProperty = [[DTPresetProperties alloc] initWithDictionary:[self.propertyPluginManager propertiesWithEventType:DTEventTypeTrack]];
}

- (void)trackPresetEvents{
    // app_install 、app_initialize、session_start、session_end
    [self enableAutoTrack:DTAutoTrackEventTypeAll];
    
    [self user_set: [self.presetProperty getLatestPresetProperties]];
    if(!self.hasSetUserOnce) {
        [self user_setOnce: [self.presetProperty getActivePresetProperties]];
        self.hasSetUserOnce = true;
        [self saveUserDefaultData];
    }
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

        // 更新时长统计
        NSTimeInterval systemUpTime = NSProcessInfo.processInfo.systemUptime;
        [self.trackTimer enterForegroundWithSystemUptime:systemUpTime];
    } else if (newState == DTAppLifeCycleStateEnd) {
        // 更新事件时长统计
        NSTimeInterval systemUpTime = NSProcessInfo.processInfo.systemUptime;
        [self.trackTimer enterBackgroundWithSystemUptime:systemUpTime];
        
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
        [self.eventTracker flush];
#endif
        
    } else if (newState == DTAppLifeCycleStateTerminate) {
        // 保证在app杀掉的时候，同步执行完队列内的任务
        dispatch_sync(dt_trackQueue, ^{});
        [self.eventTracker syncSendAllData];
    }
}

- (void)retrievePersistedData {
    self.file = [[DTFile alloc] initWithAppid:[[self config] appid]];
    self.accountId = [self.file unarchiveAccountId];
    self.distinctId = [self.file unarchiveDistinctId];
    [self loadUserDefaultData];
}

- (void)setSuperProperties:(NSDictionary *)properties {
    dispatch_async(dt_trackQueue, ^{
        [self.superProperty registerSuperProperties:properties];
    });
}

- (void)unsetSuperProperty:(NSString *)propertyKey {
    dispatch_async(dt_trackQueue, ^{
        [self.superProperty unregisterSuperProperty:propertyKey];
    });
}

- (void)clearSuperProperties {
    dispatch_async(dt_trackQueue, ^{
        [self.superProperty clearSuperProperties];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperty currentSuperProperties];
}

- (NSDictionary *)currentDynamicProperties {
    return [self.superProperty obtainDynamicSuperProperties];
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    
    dispatch_async(dt_trackQueue, ^{
        [self.superProperty registerDynamicSuperProperties:dynamicSuperProperties];
    });
}

- (void)loadUserDefaultData {
    self.hasSetUserOnce = [[[NSUserDefaults standardUserDefaults] objectForKey:@"hasSetUserOnce"] boolValue];
}

- (void)saveUserDefaultData {
    [[NSUserDefaults standardUserDefaults] setBool:self.hasSetUserOnce forKey:@"hasSetUserOnce"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//MARK: - Auto Track

- (void)enableAutoTrack:(DTAutoTrackEventType)eventType {
    [[DTAutoTrackManager sharedManager] trackWithAppid:[self.config appid] withOption:eventType];
}

- (void)autoTrackWithEvent:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties {
    [self handleTimeEvent:event];
    [self asyncAutoTrackEventObject:event properties:properties];
}

/// 将事件加入到事件队列
/// @param event 事件
/// @param properties 自定义属性
- (void)asyncAutoTrackEventObject:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties {
    dispatch_async(dt_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:NO];
    });
}

//MARK: - Track 事件
/// 将事件加入到事件队列
/// @param event 事件
/// @param properties 自定义属性
- (void)asyncTrackEventObject:(DTTrackEvent *)event properties:(NSDictionary *)properties {
    dispatch_async(dt_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:NO];
    });
}

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
    
    NSError *error = nil;
    [DTPropertyValidator validateCustomInputEventName:event error:&error];
    if (error) {
        return;
    }
    
    DTTrackEvent *trackEvent = [[DTTrackEvent alloc] initWithName:event];
    DTLogDebug(@"##### track %@ systemUpTime: %lf",event, trackEvent.systemUpTime);
    [self handleTimeEvent:trackEvent];
    [self asyncTrackEventObject:trackEvent properties:properties isH5:NO];
}

// 发送将数据库数据
- (void)flush {
    [self.eventTracker flush];
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
    
    dispatch_async(dt_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:isH5];
    });
}


/// 将事件加入到事件队列
/// @param event 事件
/// @param properties 自定义属性
- (void)asyncUserEventObject:(DTUserEvent *)event properties:(NSDictionary *)properties {
    // 获取当前的SDK上报状态，并记录
//    event.isEnabled = self.isEnabled;
//    event.trackPause = self.isTrackPause;
//    event.isOptOut = self.isOptOut;
    
    dispatch_async(dt_trackQueue, ^{
        [self trackUserEvent:event properties:properties];
    });
}

- (void)trackUserEvent:(DTUserEvent *)event properties:(NSDictionary *)properties {
    // 组装通用属性
    [self configBaseEvent:event];
    // 校验并添加用户自定义属性
    [event.properties addEntriesFromDictionary:[DTPropertyValidator validateProperties:properties validator:event]];
    // 将属性中所有NSDate对象，用指定的 timezone 转换成时间字符串
    NSDictionary *jsonObj = [event formatDateWithDict:event.jsonObject];
    // 发送数据
    [self.eventTracker track:jsonObj sync:event.uuid immediately:false ];
}

- (void)trackEvent:(DTTrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    
    [[DTPerfLogger shareInstance] doLog:WRITEEVENTTODBBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    // 组装通用属性
    [self configBaseEvent:event];
    // 验证事件本身的合法性，具体的验证策略由事件对象本身定义。
    NSError *error = nil;
    [event validateWithError:&error];
    if (error) {
        return;
    }
    // 是否是从后台启动
    if ([DTAppState shareInstance].relaunchInBackground) {
        event.properties[@"#relaunched_in_background"] = @YES;
    }
    
    if ([event isKindOfClass:[DTAppStartEvent class]]) {
        NSString *session = [[NSUUID UUID] UUIDString];
        event.properties[COMMON_PROPERTY_EVENT_SESSION] = session;
        [self setInMemoryCommonProperties:@{COMMON_PROPERTY_EVENT_SESSION:session}];
    }
    
    //    如果没有开启上传，说明用户需要设置额外的属性，公共属性等到上传时再添加
    event.hasSetCommonProperties = NO;
    if([DTConfig shareInstance].enableUpload)
    {
        // 静态公共属性
        NSDictionary *superProperties = self.superProperty.currentSuperProperties;
        
        // 动态公共属性
        NSDictionary *superDynamicProperties = self.superProperty.obtainDynamicSuperProperties;
        
        // 需要共享的公共属性,比如sessionid
        NSDictionary *inMemoryCommonProperties = self.inMemoryCommonProps;

        [event.properties addEntriesFromDictionary:superProperties];
        [event.properties addEntriesFromDictionary:superDynamicProperties];
        [event.properties addEntriesFromDictionary:inMemoryCommonProperties];
        event.hasSetCommonProperties = YES;
    }

    // 添加从属性插件获取的属性，属性插件只有系统使用，不支持用户自定义。所以属性名字是可信的，不用验证格式
    NSMutableDictionary *pluginProperties = [self.propertyPluginManager propertiesWithEventType:event.eventType];
  
    NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];

    [event.properties addEntriesFromDictionary:pluginProperties];
    
    if ([event isKindOfClass:[DTAppEndEvent class]]) {
        [self unsetSuperProperty:COMMON_PROPERTY_EVENT_SESSION];
    }
    
    // 获取当前组装好的最新的属性值
    jsonObj = event.jsonObject;
    
    // 校验用户自定义属性
    properties = [DTPropertyValidator validateProperties:properties validator:event];
    [event.properties addEntriesFromDictionary:properties];
    
    // 录入数据
    [self.eventTracker track:jsonObj sync:event.uuid immediately:false];
    
    [[DTPerfLogger shareInstance] doLog:WRITEEVENTTODBEND time:[NSDate timeIntervalSinceReferenceDate]];
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
        
        trackEvent.duration = [self.trackTimer durationOfEvent:trackEvent.eventName systemUptime:trackEvent.systemUpTime];
        
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
    event.accountId = self.accountId;
    event.distinctId = self.distinctId;
    event.dtid = [[DTDeviceInfo sharedManager] deviceId];
    event.appid = [self.config appid];
    event.isDebug = [self.config enabledDebug];
    event.bundleId = [DTDeviceInfo bundleId];
    // 事件如果没有指定时间，那么使用系统时间时需要校准
    if (self.calibratedTime && [self.calibratedTime enable]) {
        NSTimeInterval systemUpTime = NSProcessInfo.processInfo.systemUptime;
        NSTimeInterval outTime = systemUpTime - self.calibratedTime.systemUptime;
        NSTimeInterval realTime = self.calibratedTime.serverTime + outTime;
        event.time = realTime;
    }
}


#pragma mark - timeEvent

- (void)timeEvent:(NSString *)event {
    NSError *error = nil;
    [DTPropertyValidator validateEventOrPropertyName:event withError:&error];
    if (error) {
        return;
    }
    [self.trackTimer trackEvent:event withSystemUptime:NSProcessInfo.processInfo.systemUptime];
}

- (void)timeEventUpdate:(NSString *)event withState:(BOOL)state{
    NSError *error = nil;
    [DTPropertyValidator validateEventOrPropertyName:event withError:&error];
    if (error) {
        return;
    }
    [self.trackTimer updateTimerState:event withSystemUptime:NSProcessInfo.processInfo.systemUptime withState:state];
}

- (void)trackTimeEvent:(NSString *)event properties:(nullable NSDictionary *)propertieDict; {
    if([self.trackTimer isExistEvent:event]){
        [self track:event];
        [self.trackTimer removeEvent:event];
    }
}


#pragma mark - User

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    if (propertyName && propertyValue) {
        [self user_add:@{propertyName: propertyValue}];
    }
}

- (void)user_add:(NSDictionary *)properties {
    DTUserEventAdd *event = [[DTUserEventAdd alloc] init];
    
    [self asyncUserEventObject:event properties:properties];
}

- (void)user_setOnce:(NSDictionary *)properties {
    DTUserEventSetOnce *event = [[DTUserEventSetOnce alloc] init];
    [self asyncUserEventObject:event properties:properties];
}

- (void)user_set:(NSDictionary *)properties {
    DTUserEventSet *event = [[DTUserEventSet alloc] init];
    [self asyncUserEventObject:event properties:properties];
}

- (void)user_unset:(NSString *)propertyName {
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary *properties = @{propertyName: @0};
        DTUserEventUnset *event = [[DTUserEventUnset alloc] init];
        [self asyncUserEventObject:event properties:properties];
    }
}

- (void)user_delete {
    DTUserEventDelete *event = [[DTUserEventDelete alloc] init];
    [self asyncUserEventObject:event properties:nil];
}

- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties {
    if (![self allElementIsArray:properties]) {
        DTLogError(@"invalie arg, user_append only receive array arg");
        NSLog(@"invalie arg, user_append only receive array arg");
        return;
    }
    
    DTUserEventAppend *event = [[DTUserEventAppend alloc] init];
    [self asyncUserEventObject:event properties:properties];
}

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    if (![self allElementIsArray:properties]) {
        DTLogError(@"invalie arg, user_append only receive array arg");
        NSLog(@"invalie arg, user_append only receive array arg");
        return;
    }
    DTUserEventUniqueAppend *event = [[DTUserEventUniqueAppend alloc] init];
    [self asyncUserEventObject:event properties:properties];
}

/// 设置自有用户系统的id
/// - Parameters:
///   - accountId: 用户系统id
- (void)setAcid:(NSString *)accountId {
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        DTLogError(@"accountId invald", accountId);
        return;
    }

    self.accountId = accountId;
    @synchronized (self.file) {
        [self.file archiveAccountId:accountId];
    }
}

//- (void)setDistinctid:(NSString *)distinctId {
//    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
//        DTLogError(@"distinctId invald", distinctId);
//        return;
//    }
//
//    self.distinctId = distinctId;
//    @synchronized (self.file) {
//        [self.file archiveDistinctId:self.distinctId];
//    }
//}

- (NSString *)currentDistinctID {
    return self.distinctId;
}

/// 设置Firebase的app_instance_id
/// - Parameters:
///   - fiid: Firebase 的 app_instance_id
- (void)setFirebaseAppInstanceId:(NSString *)fiid {
   
    if(!fiid) {
        fiid = @"";
    } else if (![fiid isKindOfClass:[NSString class]]) {
        DTLogError(@"FirebaseAppInstanceId invald", fiid);
        return;
    }
    
    [self user_set:@{USER_PROPERTY_LATEST_FIREBASE_IID:fiid}];
    [self.superProperty setThirdPartyId:COMMON_PROPERTY_FIREBASE_IID value:fiid];
}

/// 设置AppsFlyer的appsflyer_id
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
- (void)setAppsFlyerId:(NSString *)afid {
    if(!afid) {
        afid = @"";
    } else if (![afid isKindOfClass:[NSString class]] ) {
        DTLogError(@"AppsFlyerId invald", afid);
        return;
    }
    [self user_set:@{USER_PROPERTY_LATEST_APPSFLYER_ID:afid}];
    [self.superProperty setThirdPartyId:COMMON_PROPERTY_APPSFLYER_ID value:afid];
}

/// 设置kochava iid
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
- (void)setKochavaId:(NSString *)koid {
    if(!koid) {
        koid = @"";
    } else if (![koid isKindOfClass:[NSString class]]) {
        DTLogError(@"KochavaId invald", koid);
        return;
    }
    [self user_set:@{USER_PROPERTY_LATEST_KOCHAVA_ID:koid}];
    [self.superProperty setThirdPartyId:COMMON_PROPERTY_KOCHAVA_ID value:koid];
}

/// 设置AdjustId
/// - Parameter adjustId: AdjustId
- (void)setAdjustId:(NSString *)adjustId {
    if(!adjustId) {
        adjustId = @"";
    } else if (![adjustId isKindOfClass:[NSString class]] ) {
        DTLogError(@"adjustId invald", adjustId);
        return;
    }
    [self user_set:@{USER_PROPERTY_LATEST_ADJUST_ID:adjustId}];
    [self.superProperty setThirdPartyId:COMMON_PROPERTY_ADJUST_ID value:adjustId];
}

/// 设置TenjinId
/// - Parameter TenjinId: TenjinId
- (void)setTenjinId:(NSString *)tenjinId {
    if(!tenjinId) {
        tenjinId = @"";
    } else if (![tenjinId isKindOfClass:[NSString class]] ) {
        DTLogError(@"tenjinId invald", tenjinId);
        return;
    }
    [self user_set:@{USER_PROPERTY_LATEST_TENJIN_ID:tenjinId}];
    [self.superProperty setThirdPartyId:COMMON_PROPERTY_TENJIN_ID value:tenjinId];
}

- (void)setIasOriginalOrderId:(NSString *)oorderId {
    if (![oorderId isKindOfClass:[NSString class]] || oorderId.length == 0) {
        DTLogError(@"oorderId invald", oorderId);
        return;
    }
    [self setInMemoryCommonProperties:@{COMMON_PROPERTY_IAS_ORIGINAL_ORDER_ID:oorderId}];
}

- (NSString *)getDTid {
    return [[DTDeviceInfo sharedManager] deviceId];
}

- (BOOL)allElementIsArray:(NSDictionary *)dict {
    BOOL ret = YES;
    for (NSString *k in dict.allKeys) {
        NSArray *ary = dict[k];
        
        if (![ary isKindOfClass:[NSArray class]]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (void)setInMemoryCommonProperties:(NSDictionary *)properties {
    dispatch_async(dt_trackQueue, ^{
        [self.inMemoryCommonProps addEntriesFromDictionary:properties];
    });
}

- (void)unsetInMomoryCommonProperty:(NSString *)propertyKey {
    dispatch_async(dt_trackQueue, ^{
        [self.inMemoryCommonProps removeObjectForKey:propertyKey];
    });
}

- (void)clearInMemoryCommonProperties {
    dispatch_async(dt_trackQueue, ^{
        [self.inMemoryCommonProps removeAllObjects];
    });
}

- (NSDictionary *)currentInMemoryCommonProperties {
    return self.inMemoryCommonProps;
}

@end
