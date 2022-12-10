//
//  DTAutoTrackEvent.m
//
//
//

#import "DTAutoTrackEvent.h"
#import "DTPresetProperties+DTDisProperties.h"

@implementation DTAutoTrackEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];    
    // 重新处理自动采集事件的时长，主要有 app_start， app_end
    // app_start app_end 事件是自动采集管理类采集到的。存在以下问题：自动采集管理类 和 timeTracker事件时长管理类 都是通过监听appLifeCycle的通知来做出处理，所以不在一个精确的统一的时间点。会存在有微小误差，需要消除。
    // 测试下来，误差都小于0.01s.
    CGFloat minDuration = 0.01;
    if (![DTPresetProperties disableDuration]) {
        if (self.foregroundDuration > minDuration) {
            self.properties[@"#duration"] = [NSString stringWithFormat:@"%.3f", self.foregroundDuration];
        }
    }
    if (![DTPresetProperties disableBackgroundDuration]) {
        if (self.backgroundDuration > minDuration) {
            self.properties[@"#background_duration"] = [NSString stringWithFormat:@"%.3f", self.backgroundDuration];
        }
    }
    
    return dict;
}

/// 根据eventName返回自动采集类型
- (DTAutoTrackEventType)autoTrackEventType {
    if ([self.eventName isEqualToString:DT_APP_START_EVENT]) {
        return DTAutoTrackEventTypeAppStart;
    } else if ([self.eventName isEqualToString:DT_APP_START_BACKGROUND_EVENT]) {
        return DTAutoTrackEventTypeAppStart;
    } else if ([self.eventName isEqualToString:DT_APP_END_EVENT]) {
        return DTAutoTrackEventTypeAppEnd;
    } else if ([self.eventName isEqualToString:DT_APP_INITIALIZE]) {
        return DTAutoTrackEventTypeInitialize;
    } else if ([self.eventName isEqualToString:DT_APP_INSTALL_EVENT]) {
        return DTAutoTrackEventTypeAppInstall;
    } else {
        return DTAutoTrackEventTypeNone;
    }
}

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [DTPropertyValidator validateAutoTrackEventPropertyKey:key value:value error:error];
}

@end
