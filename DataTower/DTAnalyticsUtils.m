
#import "DTAnalyticsManager.h"
#import "DTAnalyticsUtils.h"

@implementation DTAnalyticsUtils

/// 初始化事件的计时器，计时单位为毫秒。
/// - Parameters:
///     - eventName:事件的名称
+ (void)trackTimerStart:(NSString *)eventName {
    [[DTAnalyticsManager shareInstance] timeEvent:eventName];
}

/// 暂停事件的计时器，计时单位为毫秒。
/// - Parameters:
///     - eventName:事件的名称
+ (void)trackTimerPause:(NSString *)eventName {
    [[DTAnalyticsManager shareInstance] timeEventUpdate:eventName withState:YES];
}

/// 恢复事件的计时器，计时单位为毫秒。
/// - Parameters:
///     - eventName:事件的名称
+ (void)trackTimerResume:(NSString *)eventName {
    [[DTAnalyticsManager shareInstance] timeEventUpdate:eventName withState:NO];
}

/// 停止事件的计时器
/// - Parameters:
///    - eventName:事件的名称
+ (void)trackTimerEnd:(NSString *)eventName {
    [[DTAnalyticsManager shareInstance] trackTimeEvent:eventName properties:nil];
}

/// 停止事件的计时器
/// - Parameters:
///    - eventName:事件的名称
///    - properties:自定义事件的属性
+ (void)trackTimerEnd:(NSString *)eventName properties:(NSDictionary *)properties {
    [[DTAnalyticsManager shareInstance] trackTimeEvent:eventName properties:properties];
}
@end
