#import "DTCalibratedTime.h"

@implementation DTCalibratedTime

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.serverTime = 0;
        self.systemUptime = 0;
        self.deviceTime = 0;
    }

    return self;
}

- (void)recalibrationWithTimeInterval:(NSTimeInterval)timestamp {
    self.serverTime = timestamp;
    self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
    self.deviceTime = [[NSDate date] timeIntervalSince1970];
}

@end
