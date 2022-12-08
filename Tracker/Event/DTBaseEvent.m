//
//  DTBaseEvent.m
//
//
//
//

#import "DTBaseEvent.h"

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "DTLogging.h"
#endif

//#import "ThinkingAnalyticsSDKPrivate.h"

kDTEventType const kDTEventTypeTrack            = @"track";
kDTEventType const kDTEventTypeTrackFirst       = @"track_first";
kDTEventType const kDTEventTypeTrackUpdate      = @"track_update";
kDTEventType const kDTEventTypeTrackOverwrite   = @"track_overwrite";
kDTEventType const kDTEventTypeUserSet          = @"user_set";
kDTEventType const kDTEventTypeUserUnset        = @"user_unset";
kDTEventType const kDTEventTypeUserAdd          = @"user_add";
kDTEventType const kDTEventTypeUserDel          = @"user_del";
kDTEventType const kDTEventTypeUserSetOnce      = @"user_setOnce";
kDTEventType const kDTEventTypeUserAppend       = @"user_append";
kDTEventType const kDTEventTypeUserUniqueAppend = @"user_uniq_append";

#define kDefaultTimeFormat  @"yyyy-MM-dd HH:mm:ss.SSS"


@interface DTBaseEvent ()
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation DTBaseEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 只能直接访问变量，不要触发 setter 方法。默认记录当前事件发生的时间
        _time = [NSDate date];
        self.timeValueType = DTEventTimeValueTypeNone;
        self.uuid = [NSUUID UUID].UUIDString;
    }
    return self;
}

- (instancetype)initWithType:(DTEventType)type {
    if (self = [self init]) {
        self.eventType = type;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    // 子类实现
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"#time"] = self.time;
    dict[@"#uuid"] = self.uuid;
    dict[@"#type"] = [self eventTypeString];
    if (self.accountId) {
        dict[@"#account_id"] = self.accountId;
    }
    if (self.distinctId) {
        dict[@"#distinct_id"] = self.distinctId;
    }
    dict[@"properties"] = self.properties;
    return dict;
}

- (NSMutableDictionary *)formatDateWithDict:(NSDictionary *)dict {
    if (dict == nil || ![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    NSMutableDictionary *mutableDict = nil;
    if ([dict isKindOfClass:NSMutableDictionary.class]) {
        mutableDict = (NSMutableDictionary *)dict;
    } else {
        mutableDict = [dict mutableCopy];
    }
    
    NSArray<NSString *> *keys = dict.allKeys;
    for (NSInteger i = 0; i < keys.count; i++) {
        id value = dict[keys[i]];
        if ([value isKindOfClass:NSDate.class]) {
            NSString *newValue = [self.timeFormatter stringFromDate:(NSDate *)value];
            mutableDict[keys[i]] = newValue;
        } else if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *newValue = [self formatDateWithDict:value];
            mutableDict[keys[i]] = newValue;
        }
    }
    return mutableDict;
}

- (NSString *)eventTypeString {
    switch (self.eventType) {
        case DTEventTypeTrack: {
            return DT_EVENT_TYPE_TRACK;
        } break;
        case DTEventTypeTrackFirst: {
            // 首次事件的类型仍然是track
            return DT_EVENT_TYPE_TRACK_FIRST;
        } break;
        case DTEventTypeTrackUpdate: {
            return DT_EVENT_TYPE_TRACK_UPDATE;
        } break;
        case DTEventTypeTrackOverwrite: {
            return DT_EVENT_TYPE_TRACK_OVERWRITE;
        } break;
        case DTEventTypeUserAdd: {
            return DT_EVENT_TYPE_USER_ADD;
        } break;
        case DTEventTypeUserSet: {
            return DT_EVENT_TYPE_USER_SET;
        } break;
        case DTEventTypeUserUnset: {
            return DT_EVENT_TYPE_USER_UNSET;
        } break;
        case DTEventTypeUserAppend: {
            return DT_EVENT_TYPE_USER_APPEND;
        } break;
        case DTEventTypeUserUniqueAppend: {
            return DT_EVENT_TYPE_USER_UNIQ_APPEND;
        } break;
        case DTEventTypeUserDel: {
            return DT_EVENT_TYPE_USER_DEL;
        } break;
        case DTEventTypeUserSetOnce: {
            return DT_EVENT_TYPE_USER_SETONCE;
        } break;
            
        default:
            return nil;
            break;
    }
}

+ (DTEventType)typeWithTypeString:(NSString *)typeString {
    if ([typeString isEqualToString:DT_EVENT_TYPE_TRACK]) {
        return DTEventTypeTrack;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_TRACK_FIRST]) {
        return DTEventTypeTrack;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_TRACK_UPDATE]) {
        return DTEventTypeTrackUpdate;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_TRACK_OVERWRITE]) {
        return DTEventTypeTrackOverwrite;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_ADD]) {
        return DTEventTypeUserAdd;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_DEL]) {
        return DTEventTypeUserDel;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_SET]) {
        return DTEventTypeUserSet;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_UNSET]) {
        return DTEventTypeUserUnset;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_APPEND]) {
        return DTEventTypeUserAppend;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_UNIQ_APPEND]) {
        return DTEventTypeUserUniqueAppend;
    } else if ([typeString isEqualToString:DT_EVENT_TYPE_USER_SETONCE]) {
        return DTEventTypeUserSetOnce;
    }
    return DTEventTypeNone;
}

//MARK: - Private

//MARK: - Delegate

- (void)dt_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    
}

//MARK: - Setter & Getter

- (NSMutableDictionary *)properties {
    if (!_properties) {
        _properties = [NSMutableDictionary dictionary];
    }
    return _properties;
}

-  (void)setTimeZone:(NSTimeZone *)timeZone {
    _timeZone = timeZone;
    
    // 更新时区信息
    self.timeFormatter.timeZone = timeZone ?: [NSTimeZone localTimeZone];
}

- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = kDefaultTimeFormat;
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // 默认时区
        _timeFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    return _timeFormatter;
}

- (void)setTime:(NSDate *)time {
    // 过滤time为nil
    if (time) {
        [self willChangeValueForKey:@"time"];
        _time = time;
        [self didChangeValueForKey:@"time"];
    }
}

@end
