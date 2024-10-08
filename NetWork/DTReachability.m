//
//  TAReachability.m
//
//
//
//

#import "DTReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if __has_include(<ThinkingSDK/DTLogging.h>)
#import <ThinkingSDK/DTLogging.h>
#else
#import "DTLogging.h"
#import "DTAnalyticsManager.h"
#endif


@interface DTReachability ()
#if TARGET_OS_IOS
@property (atomic, assign) SCNetworkReachabilityRef reachability;
#endif
@property (nonatomic, assign) BOOL isWifi;
@property (nonatomic, assign) BOOL isWwan;

@end

@implementation DTReachability

#if TARGET_OS_IOS
/// 网络状态监听的回调方法
static void DTReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    DTReachability *instance = (__bridge DTReachability *)info;
    if (instance && [instance isKindOfClass:[DTReachability class]]) {
        [instance reachabilityChanged:flags];
    }
}
#endif

//MARK: - Public Methods

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static DTReachability *reachability = nil;
    dispatch_once(&onceToken, ^{
        reachability = [[DTReachability alloc] init];
    });
    return reachability;
}

#if TARGET_OS_IOS

- (NSString *)networkState {
    if (self.isWifi) {
        return @"wifi";
    } else if (self.isWwan) {
        return [self currentRadio];
    } else {
        return @"NULL";
    }
}

- (void)startMonitoring {
    [self stopMonitoring];

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,"datatower.com");
    self.reachability = reachability;
    
    if (self.reachability != NULL) {
        SCNetworkReachabilityFlags flags;
        BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(self.reachability, &flags);
        if (didRetrieveFlags) {
            self.isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
            self.isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
            [[DTAnalyticsManager shareInstance] flush];
        }
        
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if (SCNetworkReachabilitySetCallback(self.reachability, DTReachabilityCallback, &context)) {
            if (!SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes)) {
                SCNetworkReachabilitySetCallback(self.reachability, NULL, NULL);
            }
        }
    }
}

- (void)stopMonitoring {
    if (!self.reachability) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

+ (DTNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return DTNetworkTypeNONE;
    } else if ([@"wifi" isEqualToString:networkType]) {
        return DTNetworkTypeWIFI;
    } else if ([@"2g" isEqualToString:networkType]) {
        return DTNetworkType2G;
    } else if ([@"3g" isEqualToString:networkType]) {
        return DTNetworkType3G;
    } else if ([@"4g" isEqualToString:networkType]) {
        return DTNetworkType4G;
    }else if([@"5g"isEqualToString:networkType])
    {
        return DTNetworkType5G;
    }
    return DTNetworkTypeNONE;
}

//MARK: - Private Methods

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    self.isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
    self.isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
    [[DTAnalyticsManager shareInstance] flush];
}

- (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    @try {
        static CTTelephonyNetworkInfo *info = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            info = [[CTTelephonyNetworkInfo alloc] init];
        });
        NSString *currentRadio = nil;
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [info serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [info.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = info.currentRadioAccessTechnology;
        }
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            networkType = @"4g";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyeHRPD] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            networkType = @"3g";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            networkType = @"2g";
        }
#ifdef __IPHONE_14_1
        else if (@available(iOS 14.1, *)) {
            if ([currentRadio isKindOfClass:[NSString class]]) {
                if([currentRadio isEqualToString:CTRadioAccessTechnologyNRNSA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyNR]) {
                    networkType = @"5g";
                }
            }
        }
#endif
    } @catch (NSException *exception) {
        DTLogError(@"%@: %@", self, exception);
    }
    
    return networkType;
}

#elif TARGET_OS_OSX

+ (DTNetworkType)convertNetworkType:(NSString *)networkType {
    return DTNetworkTypeWIFI;
}

- (void)startMonitoring {
}

- (void)stopMonitoring {
}

- (NSString *)currentRadio {
    return @"wifi";
}

- (NSString *)networkState {
    return @"wifi";
}

#endif

@end
