#import "DTDeviceInfo.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

#import "DTKeychainHelper.h"
#import "DTConfig.h"
//#import "ThinkingAnalyticsSDKPrivate.h"
//#import "TDFile.h"
#import "DTPresetProperties+DTDisProperties.h"

#define kTDDyldPropertyNames @[@"DTPerformance"]
#define kTDGetPropertySelName @"getPresetProperties"

#if TARGET_OS_IOS
static CTTelephonyNetworkInfo *__td_TelephonyNetworkInfo;
#endif

@interface DTDeviceInfo ()

@property (nonatomic, readwrite) BOOL isFirstOpen;
@property (nonatomic, strong) NSDictionary *automaticData;

@end

@implementation DTDeviceInfo

+ (void)load {
#if TARGET_OS_IOS
    __td_TelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
#endif
}


+ (DTDeviceInfo *)sharedManager {
    static dispatch_once_t onceToken;
    static DTDeviceInfo *manager;
    dispatch_once(&onceToken, ^{
        manager = [[DTDeviceInfo alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.libName = @"iOS";
        self.libVersion = DTConfig.version;
        _deviceId = [self getDTID];
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        _automaticData = [self dt_collectProperties];
    }
    return self;
}

+ (NSString *)libVersion {
    return [self sharedManager].libVersion;
}

+ (NSString *)deviceId {
    return [self sharedManager].deviceId;
}

- (void)dt_updateData {
    _automaticData = [self dt_collectProperties];
}

-(NSDictionary *)getAutomaticData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_automaticData];
    [dic addEntriesFromDictionary:[DTDeviceInfo getAPMParams]];
    _automaticData = dic;
    return _automaticData;
}

- (NSDictionary *)dt_collectProperties {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    
    if (![DTPresetProperties disableDeviceId]) {
        [p setValue:_deviceId forKey:@"#device_id"];
    }
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableCarrier]) {
        CTCarrier *carrier = nil;
        NSString *carrierName = @"";
    #ifdef __IPHONE_12_0
            if (@available(iOS 12.1, *)) {
                // 双卡双待的情况
                NSArray *carrierKeysArray = [__td_TelephonyNetworkInfo.serviceSubscriberCellularProviders.allKeys sortedArrayUsingSelector:@selector(compare:)];
                carrier = __td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.firstObject];
                if (!carrier.mobileNetworkCode) {
                    carrier = __td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
                }
            }
    #endif
        
        if (!carrier) {
            carrier = [__td_TelephonyNetworkInfo subscriberCellularProvider];
        }
        
        // 系统特性，在SIM没有安装的情况下，carrierName也存在有值的情况，这里额外添加MCC和MNC是否有值的判断
        // MCC、MNC、isoCountryCode在没有安装SIM卡、没在蜂窝服务范围内时候为nil
        if (carrier.carrierName &&
            carrier.carrierName.length > 0 &&
            carrier.mobileNetworkCode &&
            carrier.mobileNetworkCode.length > 0) {
            carrierName = carrier.carrierName;
        }
        [p setValue:carrierName forKey:@"#carrier"];
    }
#endif
    
    if (![DTPresetProperties disableLib]) {
        [p setValue:self.libName forKey:@"#lib"];
    }
    if (![DTPresetProperties disableLibVersion]) {
        [p setValue:self.libVersion forKey:@"#lib_version"];
    }
    if (![DTPresetProperties disableManufacturer]) {
        [p setValue:@"Apple" forKey:@"#manufacturer"];
    }
    if (![DTPresetProperties disableDeviceModel]) {
        [p setValue:[self td_iphoneType] forKey:@"#device_model"];
    }
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableOs]) {
        [p setValue:@"iOS" forKey:@"#os"];
    }
    if (![DTPresetProperties disableOsVersion]) {
        UIDevice *device = [UIDevice currentDevice];
        [p setValue:[device systemVersion] forKey:@"#os_version"];
    }
    if (![DTPresetProperties disableScreenWidth]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.width) forKey:@"#screen_width"];
    }
    if (![DTPresetProperties disableScreenHeight]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.height) forKey:@"#screen_height"];
    }
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableDeviceType]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [p setValue:@"iPad" forKey:@"#device_type"];
        } else {
            [p setValue:@"iPhone" forKey:@"#device_type"];
        }
    }
#endif
    
#elif TARGET_OS_OSX
    if (![TDPresetProperties disableOs]) {
        [p setValue:@"OSX" forKey:@"#os"];
    }
    if (![TDPresetProperties disableOsVersion]) {
        NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
        NSString *versionString = [sv objectForKey:@"ProductVersion"];
        [p setValue:versionString forKey:@"#os_version"];
    }
#endif
    if (![DTPresetProperties disableSystemLanguage]) {
        NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
//        NSString *preferredLanguages1 = [NSLocale currentLocale].languageCode;
        NSString * retValue = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject] copy];
        if (preferredLanguages && preferredLanguages.length > 0) {
            p[@"#system_language"] = [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
        }
    }
    // 添加性能指标
    [p addEntriesFromDictionary:[DTDeviceInfo getAPMParams]];
    
    return [p copy];
}

+ (NSString*)bundleId
{
     return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)td_iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}

- (NSString *)getDTID {
    // DT ID
    NSString *dtId;
    DTKeychainHelper *wrapper = [[DTKeychainHelper alloc] init];

    NSString *dtIdKeychain = [wrapper readDTID];
    
    if (dtIdKeychain.length == 0) {
        // 新设备、新用户
        dtId = [[NSUUID UUID] UUIDString];
        [wrapper saveDTID:dtId];
    }else {
        dtId = dtIdKeychain;
    }
    return dtId;
}



- (NSString *)dealStringWithRegExp:(NSString *)string {
    NSRegularExpression *regExp = [[NSRegularExpression alloc]initWithPattern:@"[0-9AXYHJKLMW]"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    return [regExp stringByReplacingMatchesInString:string
                                                     options:NSMatchingReportProgress
                                                       range:NSMakeRange(0, string.length)
                                                withTemplate:@""];
}

#if TARGET_OS_IOS

+ (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    
    if (!__td_TelephonyNetworkInfo) {
        return networkType;
    }
    
    @try {
        NSString *currentRadio = nil;
        
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [__td_TelephonyNetworkInfo serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [__td_TelephonyNetworkInfo.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = __td_TelephonyNetworkInfo.currentRadioAccessTechnology;
        }
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            networkType = @"4G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyeHRPD] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            networkType = @"3G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            networkType = @"2G";
        }
#ifdef __IPHONE_14_1
        else if (@available(iOS 14.1, *)) {
            if ([currentRadio isKindOfClass:[NSString class]]) {
                if([currentRadio isEqualToString:CTRadioAccessTechnologyNRNSA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyNR]) {
                    networkType = @"5G";
                }
            }
        }
#endif
    } @catch (NSException *exception) {
//        DTLogError(@"%@: %@", self, exception);
    }
    
    return networkType;
}

#elif TARGET_OS_OSX
+ (NSString *)currentRadio {
    return @"WIFI";
}
#endif

+ (NSDate *)dt_getInstallTime {
    
    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    __autoreleasing NSError *error;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path error:&error] objectForKey:NSFileCreationDate];
    if (!error) {
        return installDate;
    }
    return [NSDate date];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (NSDictionary *)getAPMParams {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    for (NSString *clsName in kTDDyldPropertyNames) {
        Class cls = NSClassFromString(clsName);
        SEL sel = NSSelectorFromString(kTDGetPropertySelName);
        if (cls && sel && [cls respondsToSelector:sel]) {
            NSDictionary *result = [cls performSelector:sel];
//            NSDictionary *result = [NSObject performSelector:sel onTarget:cls withArguments:@[]];
            if ([result isKindOfClass:[NSDictionary class]] && result.allKeys.count > 0) {
                [p addEntriesFromDictionary:result];
            }
      
        }
    }
    return p;
}

#pragma clang diagnostic pop

+ (BOOL)isIPad {
#if TARGET_OS_IOS
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#elif TARGET_OS_OSX
    return NO;
#endif
}

@end
