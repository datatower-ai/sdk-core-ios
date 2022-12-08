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


@interface DTAnalyticsManager ()

@property (nonatomic, strong)DTAnalyticsConfig *config;

@end

@implementation DTAnalyticsManager

static DTAnalyticsManager *_manager = nil;

+ (DTAnalyticsManager *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manager = [[DTAnalyticsManager alloc] init];
    });
    return _manager;
}

- (void)initializeWithConfig:(DTAnalyticsConfig *)config {
    
    [DTAppState shareInstance];
    
    self.config = config;
    // 日志模块
    [self initLog];
    // 网络变化监听
    [self networkStateObserver];
    // 用户属性管理器
    [self initProperties];
    //TODO: 这里需要梳理下都需要哪些能力。
    
    
}

- (void)initLog {
    
}

- (void)networkStateObserver {
    if (![DTPresetProperties disableNetworkType]) {
        [[DTReachability shareInstance] startMonitoring];
    }
}

//
- (void)initProperties {
    // 注册属性插件
    self.propertyPluginManager = [[DTPropertyPluginManager alloc] init];
    DTPresetPropertyPlugin *presetPlugin = [[DTPresetPropertyPlugin alloc] init];
    [self.propertyPluginManager registerPropertyPlugin:presetPlugin];
    
    // 添加从属性插件获取的属性，属性插件只有系统使用，不支持用户自定义。所以属性名字是可信的，不用验证格式
    NSMutableDictionary *pluginProperties = [self.propertyPluginManager propertiesWithEventType:DTEventTypeTrack];
//    DTLogInfo(pluginProperties);
}

- (void)registerAppLifeCycleListener {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTAAppLifeCycleStateWillChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(appStateDidChangeNotification:) name:kTAAppLifeCycleStateDidChangeNotification object:nil];
}



@end
