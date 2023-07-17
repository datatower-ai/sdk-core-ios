#import "DTConfig.h"
#import "DTBaseEvent.h"

#define DT_IOS_SDK_VERSION_NAME @"2.0.3"
#define DT_IOS_SDK_VERSION_TYPE @"iOS"
static DTConfig * _defaultTDConfig;

@implementation DTConfig


+ (DTConfig *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTDConfig = [DTConfig new];
        
    });
    return _defaultTDConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxNumEvents = 10000;
        _logLevel = DTLoggingLevelNone;
    }
    return self;
}

- (NSString*)sdkVersion{
    if (self.commonProperties) {
        //可能从 unity 侧传入 unity SDK version
        if([self.commonProperties.allKeys containsObject:COMMON_PROPERTY_SDK_VERSION]){
            NSString* version = self.commonProperties[COMMON_PROPERTY_SDK_VERSION];
            if (version && version.length > 0) {
                return version;
            }
        }
    }
    return DT_IOS_SDK_VERSION_NAME;
}

- (NSString*)sdkType{
    if (self.commonProperties) {
        //可能从 unity 侧传入 unity SDK type
        if([self.commonProperties.allKeys containsObject:COMMON_PROPERTY_SDK_TYPE]){
            NSString* type = self.commonProperties[COMMON_PROPERTY_SDK_TYPE];
            if (type && type.length > 0) {
                return type;
            }
        }
    }
    return DT_IOS_SDK_VERSION_TYPE;
}



@end
