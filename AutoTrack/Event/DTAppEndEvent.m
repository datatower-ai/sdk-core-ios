//
//  DTAppEndEvent.m
//  
//
//
//

#import "DTAppEndEvent.h"
#import "DTPresetProperties+DTDisProperties.h"

@implementation DTAppEndEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    // 重新处理自动采集事件的时长，主要有 app_start， app_end
    // app_start app_end 事件是自动采集管理类采集到的。存在以下问题：自动采集管理类 和 timeTracker事件时长管理类 都是通过监听appLifeCycle的通知来做出处理，所以不在一个精确的统一的时间点。会存在有微小误差，需要消除。
    // 测试下来，误差都小于0.01s.
    CGFloat minDuration = 0.01;
    if (![DTPresetProperties disableDuration]) {
        if (self.foregroundDuration > minDuration) {
            self.properties[COMMON_PROPERTY_EVENT_SESSION_DURATION] = [self formatTime:self.foregroundDuration * 1000];
        }
    }
    return dict;
}

@end
