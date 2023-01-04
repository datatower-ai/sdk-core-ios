#import "DTConfig.h"

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

+ (NSString*)version{
    return @"1.3.3-beta2";
}



@end
