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
#import "DTBaseEvent.h"
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
        NSString *app_build = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
        _appVersionCode = [NSNumber numberWithInt:[app_build intValue]];
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

+ (NSString *)userAgent {
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = [currentDevice systemVersion];
    NSString *model = [currentDevice model];
    
    return [NSString stringWithFormat:@"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile",model,model,systemVersion];
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
    
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableCarrier]) {
        CTCarrier *carrier = nil;
        NSString *carrierName = @"";
        NSString *mcc = @"";
        NSString *mnc = @"";
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
            mcc = carrier.mobileCountryCode;
            mnc = carrier.mobileNetworkCode;
        }
        [p setValue:mcc forKey:COMMON_PROPERTY_MCC];
        [p setValue:mnc forKey:COMMON_PROPERTY_MNC];
    }
#endif
    
    if (![DTPresetProperties disableLib]) {
        [p setValue:self.libName forKey:COMMON_PROPERTY_SDK_TYPE];
    }
    if (![DTPresetProperties disableLibVersion]) {
        [p setValue:self.libVersion forKey:COMMON_PROPERTY_SDK_VERSION];
    }
    if (![DTPresetProperties disableManufacturer]) {
        [p setValue:@"Apple" forKey:COMMON_PROPERTY_DEVICE_MANUFACTURER];
        [p setValue:@"Apple" forKey:COMMON_PROPERTY_DEVICE_BRAND];
    }
    if (![DTPresetProperties disableDeviceModel]) {
        [p setValue:[self td_iphoneType] forKey:COMMON_PROPERTY_DEVICE_MODEL];
    }
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableOs]) {
        [p setValue:@"iOS" forKey:COMMON_PROPERTY_OS];
    }
    if (![DTPresetProperties disableOsVersion]) {
        UIDevice *device = [UIDevice currentDevice];
        [p setValue:[device systemVersion] forKey:COMMON_PROPERTY_OS_VERSION_NAME];
    }
    if (![DTPresetProperties disableScreenWidth]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.width) forKey:COMMON_PROPERTY_SCREEN_WIDTH];
    }
    if (![DTPresetProperties disableScreenHeight]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.height) forKey:COMMON_PROPERTY_SCREEN_HEIGHT];
    }
    
#if TARGET_OS_IOS
    if (![DTPresetProperties disableDeviceType]) {
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            [p setValue:@"iPad" forKey:@"#device_type"];
//        } else {
//            [p setValue:@"iPhone" forKey:@"#device_type"];
//        }
    }
#endif
    
#elif TARGET_OS_OSX
//    if (![TDPresetProperties disableOs]) {
//        [p setValue:@"OSX" forKey:COMMON_PROPERTY_OS];
//    }
//    if (![TDPresetProperties disableOsVersion]) {
//        NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
//        NSString *versionString = [sv objectForKey:@"ProductVersion"];
//        [p setValue:versionString forKey:@"#os_version"];
//    }
#endif
    if (![DTPresetProperties disableSystemLanguage]) {
        NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
//        NSString *preferredLanguages1 = [NSLocale currentLocale].languageCode;
        NSString * retValue = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject] copy];
        if (preferredLanguages && preferredLanguages.length > 0) {
            p[COMMON_PROPERTY_OS_LANG] = [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
        }
        
        NSLocale *locale = [NSLocale currentLocale];
        NSString *country = [locale localeIdentifier];
        p[COMMON_PROPERTY_OS_COUNTRY] = country;
        
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
    
    if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE2";
    if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 Mini";
    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
    if ([platform isEqualToString:@"iPhone14,4"]) return @"iPhone 13 Mini";
    if ([platform isEqualToString:@"iPhone14,5"]) return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"]) return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"]) return @"iPhone 13 Pro Max";
    if ([platform isEqualToString:@"iPhone14,6"]) return @"iPhone SE3";
    if ([platform isEqualToString:@"iPhone14,7"]) return @"iPhone 14";
    if ([platform isEqualToString:@"iPhone14,8"]) return @"iPhone 14 Plus";
    if ([platform isEqualToString:@"iPhone15,2"]) return @"iPhone 14 Pro";
    if ([platform isEqualToString:@"iPhone15,3"]) return @"iPhone 14 Pro Max";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    //ipad
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1";
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
    if ([platform isEqualToString:@"iPad6,11"] || [platform isEqualToString:@"iPad6,12"])   return @"iPad 5";
    if ([platform isEqualToString:@"iPad7,5"] || [platform isEqualToString:@"iPad7,6"])   return @"iPad 6";
    if ([platform isEqualToString:@"iPad7,11"] || [platform isEqualToString:@"iPad7,12"])   return @"iPad 7";
    if ([platform isEqualToString:@"iPad11,6"] || [platform isEqualToString:@"iPad11,7"])   return @"iPad 8";
    if ([platform isEqualToString:@"iPad12,1"] || [platform isEqualToString:@"iPad12,2"])   return @"iPad 9";

    //ipad air
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"])   return @"iPad Air2";
    if ([platform isEqualToString:@"iPad11,3"] || [platform isEqualToString:@"iPad11,4"])   return @"iPad Air3";
    if ([platform isEqualToString:@"iPad13,1"] || [platform isEqualToString:@"iPad13,2"])   return @"iPad Air4";
    if ([platform isEqualToString:@"iPad13,16"] || [platform isEqualToString:@"iPad13,17"])   return @"iPad Air5";

    //ipad mini
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] || [platform isEqualToString:@"iPad4,9"])   return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"])   return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad11,1"] || [platform isEqualToString:@"iPad11,2"])   return @"iPad Mini 5";
    if ([platform isEqualToString:@"iPad14,1"] || [platform isEqualToString:@"iPad14,2"])   return @"iPad Mini 6";
    
    //ipad pro
    if ([platform isEqualToString:@"iPad6,3"] || [platform isEqualToString:@"iPad6,4"])   return @"iPad Pro9 7Inch";
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"])   return @"iPad Pro12 9Inch";
    if ([platform isEqualToString:@"iPad7,1"] || [platform isEqualToString:@"iPad7,2"])   return @"iPad Pro12 9Inch2";
    if ([platform isEqualToString:@"iPad7,3"] || [platform isEqualToString:@"iPad7,4"])   return @"iPad Pro10 5Inch";
    if ([platform isEqualToString:@"iPad8,1"] || [platform isEqualToString:@"iPad8,2"]
        || [platform isEqualToString:@"iPad8,3"] || [platform isEqualToString:@"iPad8,4"])   return @"iPad Pro11 0Inch";
    if ([platform isEqualToString:@"iPad8,5"] || [platform isEqualToString:@"iPad8,6"]
        || [platform isEqualToString:@"iPad8,7"] || [platform isEqualToString:@"iPad8,8"])   return @"iPad Pro12 9Inch3";
    if ([platform isEqualToString:@"iPad8,9"] || [platform isEqualToString:@"iPad8,10"])   return @"iPad Pro11 0Inch2";
    if ([platform isEqualToString:@"iPad13,4"] || [platform isEqualToString:@"iPad13,5"]
        || [platform isEqualToString:@"iPad13,6"] || [platform isEqualToString:@"iPad13,7"])   return @"iPad Pro11 0Inch3";
    if ([platform isEqualToString:@"iPad8,11"] || [platform isEqualToString:@"iPad8,124"])   return @"iPad Pro12 9Inch4";
    if ([platform isEqualToString:@"iPad13,8"] || [platform isEqualToString:@"iPad13,9"]
        || [platform isEqualToString:@"iPad13,10"] || [platform isEqualToString:@"iPad13,11"])   return @"iPad Pro12 9Inch5";


    //Simulator
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
