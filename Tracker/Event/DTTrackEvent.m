//
//  DTTrackEvent.m
//
//
//
//

#import "DTTrackEvent.h"
#import "DTPresetProperties.h"
#import "DTPresetProperties+DTDisProperties.h"
//#import "NSDate+TAFormat.h"

@implementation DTTrackEvent

- (instancetype)initWithName:(NSString *)eventName {
    if (self = [self init]) {
        self.eventName = eventName;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventType = DTEventTypeTrack;
        // 获取当前开机时长
        self.systemUpTime = NSProcessInfo.processInfo.systemUptime;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    // 验证事件名字
    [DTPropertyValidator validateEventOrPropertyName:self.eventName withError:error];
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    dict[@"#event_name"] = self.eventName;
    
    if (![DTPresetProperties disableDuration]) {
        if (self.foregroundDuration > 0) {
            self.properties[@"#duration"] = [NSString stringWithFormat:@"%.3f", self.foregroundDuration];
        }
    }
    
    if (![DTPresetProperties disableBackgroundDuration]) {
        if (self.backgroundDuration > 0) {
            self.properties[@"#background_duration"] = [NSString stringWithFormat:@"%.3f", self.backgroundDuration];
        }
    }
    
    return dict;
}

- (double)timeZoneOffset {
//    NSTimeZone *tz = self.timeZone ?: [NSTimeZone localTimeZone];
    return 0;
}

//MARK: - Delegate

- (void)dt_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [DTPropertyValidator validateNormalTrackEventPropertyKey:key value:value error:error];
}

@end
