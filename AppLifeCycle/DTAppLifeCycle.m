//
//  DTAppLifeCycle.m
//
//
//
//

#import "DTAppLifeCycle.h"
#import "DTAppState.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/DTLogging.h>
#else
#import "DTLogging.h"
#endif

NSNotificationName const kTAAppLifeCycleStateWillChangeNotification = @"com.datatower.TAAppLifeCycleStateWillChange";
NSNotificationName const kTAAppLifeCycleStateDidChangeNotification = @"com.datatower.TAAppLifeCycleStateDidChange";
NSString * const kTAAppLifeCycleNewStateKey = @"new";
NSString * const kTAAppLifeCycleOldStateKey = @"old";


@interface DTAppLifeCycle ()
/// 状态
@property (nonatomic, assign) DTAppLifeCycleState state;

@end

@implementation DTAppLifeCycle

+ (void)startMonitor {
    [DTAppLifeCycle shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static DTAppLifeCycle *appLifeCycle = nil;
    dispatch_once(&onceToken, ^{
        appLifeCycle = [[DTAppLifeCycle alloc] init];
    });
    return appLifeCycle;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 不触发setter事件
        _state = DTAppLifeCycleStateInit;
        [self registerListeners];
        [self setupLaunchedState];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerListeners {
    if ([DTAppState runningInAppExtension]) {
        return;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IOS
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];

#elif TARGET_OS_OSX

//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidFinishLaunching:)
//                               name:NSApplicationDidFinishLaunchingNotification
//                             object:nil];
//
//    // 聚焦活动状态，和其他 App 之前切换聚焦，和 DidResignActive 通知会频繁调用
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidBecomeActive:)
//                               name:NSApplicationDidBecomeActiveNotification
//                             object:nil];
//    // 失焦状态
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidResignActive:)
//                               name:NSApplicationDidResignActiveNotification
//                             object:nil];
//
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationWillTerminate:)
//                               name:NSApplicationWillTerminateNotification
//                             object:nil];
#endif
}

- (void)setupLaunchedState {
    if ([DTAppState runningInAppExtension]) {
        return;
    }
    
    dispatch_block_t mainThreadBlock = ^(){
#if TARGET_OS_IOS
        UIApplication *application = [DTAppState sharedApplication];
        BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
        BOOL isAppStateBackground = NO;
#endif
        // 设置 app 是否是在后台自启动
        [DTAppState shareInstance].relaunchInBackground = isAppStateBackground;

        self.state = DTAppLifeCycleStateStart;
    };

    if (@available(iOS 13.0, *)) {
        // iOS 13 及以上在异步主队列的 block 修改状态的原因:+
        // 1. 保证在发送app状态改变的通知之前，SDK的初始化操作都已经完成。这样能保证在自动采集管理类发送app_start事件时公共属性已设置完毕（其实通过监听 UIApplicationDidFinishLaunchingNotification 也可以实现）
        // 2. 在包含有 SceneDelegate 的工程中，延迟获取 applicationState 才是准确的（通过监听 UIApplicationDidFinishLaunchingNotification 获取不准确）
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    } else {
        // iOS 13 以下通过监听 UIApplicationDidFinishLaunchingNotification 的通知来处理后台唤醒和冷启动（非延迟初始化）的情况:
        // 1. iOS 13 以下在后台被唤醒时，异步主队列的 block 不会执行。所以需要同时监听 UIApplicationDidFinishLaunchingNotification
        // 2. iOS 13 以下不会含有 SceneDelegate
#if TARGET_OS_IOS
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
#endif
        // 处理 iOS 13 以下冷启动，客户延迟初始化的情况。延迟初始化时，已经错过了 UIApplicationDidFinishLaunchingNotification 通知
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    }
}

//MARK: - Notification Action

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#if TARGET_OS_IOS
    UIApplication *application = [DTAppState sharedApplication];
    BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
    BOOL isAppStateBackground = NO;
#endif
    
    // 设置 app 是否是后台自启动
    [DTAppState shareInstance].relaunchInBackground = isAppStateBackground;
    
    self.state = DTAppLifeCycleStateStart;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    DTLogDebug(@"application did become active");

#if TARGET_OS_IOS
    // 防止主动触发 UIApplicationDidBecomeActiveNotification
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
#elif TARGET_OS_OSX
    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (!application.isActive) {
        return;
    }
#endif
    
    // 设置 app 是否是后台自启动
    [DTAppState shareInstance].relaunchInBackground = NO;

    self.state = DTAppLifeCycleStateStart;
}

#if TARGET_OS_IOS
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    DTLogDebug(@"application did enter background");

    // 防止主动触发 UIApplicationDidEnterBackgroundNotification
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateBackground) {
        return;
    }

    self.state = DTAppLifeCycleStateEnd;
}

#elif TARGET_OS_OSX
- (void)applicationDidResignActive:(NSNotification *)notification {
    TDLogDebug(@"application did resignActive");

    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (application.isActive) {
        return;
    }
    self.state = TAAppLifeCycleStateEnd;
}
#endif

- (void)applicationWillTerminate:(NSNotification *)notification {
    DTLogDebug(@"application will terminate");

    self.state = DTAppLifeCycleStateTerminate;
}

//MARK: - Setter

- (void)setState:(DTAppLifeCycleState)state {
    // 过滤重复的状态
    if (_state == state) {
        return;
    }
    
    // 设置 app 是否是在前台
    [DTAppState shareInstance].isActive = (state == DTAppLifeCycleStateStart);

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    userInfo[kTAAppLifeCycleNewStateKey] = @(state);
    userInfo[kTAAppLifeCycleOldStateKey] = @(_state);

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateWillChangeNotification object:self userInfo:userInfo];

    _state = state;

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateDidChangeNotification object:self userInfo:userInfo];
}

@end
