//
//  TDPresetProperties+TDDisProperties.m
//
//
//
//

#import "DTPresetProperties+DTDisProperties.h"



static BOOL _disableIsForeground;//
static BOOL _disableBundleId;
static BOOL _disableAppVersionCode;//
static BOOL _disableAppVersion;
static BOOL _disableLib;
static BOOL _disableLibVersion;
static BOOL _disableOs;
static BOOL _disableOsVersion;
static BOOL _disableSystemCountry;//
static BOOL _disableSystemLanguage;
static BOOL _disableScreenHeight;
static BOOL _disableScreenWidth;
static BOOL _disableDeviceBrand;//
static BOOL _disableManufacturer;
static BOOL _disableDeviceModel;
static BOOL _disableRAM;
static BOOL _disableDisk;
static BOOL _disableSimulator;
static BOOL _disableNetworkType;
static BOOL _disableMcc;//
static BOOL _disableMnc;//
static BOOL _disableFPS;
static BOOL _disableZoneOffset;

//用户属性Active
static BOOL _disableActiveMcc;//
static BOOL _disableActiveMnc;//
static BOOL _disableActiveSystemCountry;//
static BOOL _disableActiveSystemLanguage;
static BOOL _disableActiveBundleId;
static BOOL _disableActiveAppVersionCode;//
static BOOL _disableActiveAppVersion;
static BOOL _disableActiveLib;
static BOOL _disableActiveLibVersion;
static BOOL _disableActiveOs;
static BOOL _disableActiveOsVersion;
static BOOL _disableActiveManufacturer;
static BOOL _disableActiveDeviceBrand;
static BOOL _disableActiveDeviceModel;
static BOOL _disableActiveScreenHeight;
static BOOL _disableActiveScreenWidth;
static BOOL _disableActiveRAM;
static BOOL _disableActiveDisk;
static BOOL _disableActiveNetworkType;
static BOOL _disableActiveSimulator;

//用户属性Latest
static BOOL _disableLatestAppVersionCode;//
static BOOL _disableLatestAppVersion;




#define TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY @"DTDisPresetProperties"

@implementation DTPresetProperties (DTDisProperties)

static NSArray *__td_disPresetProperties;

+ (NSArray*)disPresetProperties {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __td_disPresetProperties = (NSArray *)[[[NSBundle mainBundle] infoDictionary] objectForKey:TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY];
        if (__td_disPresetProperties && __td_disPresetProperties.count) {

            _disableIsForeground    = [__td_disPresetProperties containsObject:COMMON_PROPERTY_IS_FOREGROUND];
            _disableBundleId        = [__td_disPresetProperties containsObject:COMMON_PROPERTY_BUNDLE_ID];
            _disableAppVersionCode  = [__td_disPresetProperties containsObject:COMMON_PROPERTY_APP_VERSION_CODE];
            _disableAppVersion      = [__td_disPresetProperties containsObject:COMMON_PROPERTY_APP_VERSION_NAME];
            _disableLib             = [__td_disPresetProperties containsObject:COMMON_PROPERTY_SDK_TYPE];
            _disableLibVersion      = [__td_disPresetProperties containsObject:COMMON_PROPERTY_SDK_VERSION];
            _disableOs              = [__td_disPresetProperties containsObject:COMMON_PROPERTY_OS];
            _disableOsVersion       = [__td_disPresetProperties containsObject:COMMON_PROPERTY_OS_VERSION_NAME];
            _disableSystemCountry   = [__td_disPresetProperties containsObject:COMMON_PROPERTY_OS_COUNTRY];
            _disableSystemLanguage  = [__td_disPresetProperties containsObject:COMMON_PROPERTY_OS_LANG];
            _disableScreenHeight    = [__td_disPresetProperties containsObject:COMMON_PROPERTY_SCREEN_HEIGHT];
            _disableScreenWidth     = [__td_disPresetProperties containsObject:COMMON_PROPERTY_SCREEN_WIDTH];
            _disableDeviceBrand     = [__td_disPresetProperties containsObject:COMMON_PROPERTY_DEVICE_BRAND];
            _disableManufacturer    = [__td_disPresetProperties containsObject:COMMON_PROPERTY_DEVICE_MANUFACTURER];
            _disableDeviceModel     = [__td_disPresetProperties containsObject:COMMON_PROPERTY_DEVICE_MODEL];
            _disableRAM             = [__td_disPresetProperties containsObject:COMMON_PROPERTY_MEMORY_USED];
            _disableDisk            = [__td_disPresetProperties containsObject:COMMON_PROPERTY_STORAGE_USED];
            _disableSimulator       = [__td_disPresetProperties containsObject:COMMON_PROPERTY_SIMULATOR];
            _disableNetworkType     = [__td_disPresetProperties containsObject:COMMON_PROPERTY_NETWORK_TYPE];
            _disableMcc             = [__td_disPresetProperties containsObject:COMMON_PROPERTY_MCC];
            _disableMnc             = [__td_disPresetProperties containsObject:COMMON_PROPERTY_MNC];
            _disableFPS             = [__td_disPresetProperties containsObject:COMMON_PROPERTY_FPS];
            _disableZoneOffset      = [__td_disPresetProperties containsObject:COMMON_PROPERTY_ZONE_OFFSET];

            //用户属性Active
            _disableActiveMcc           = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_MCC];
            _disableActiveMnc           = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_MNC];
            _disableActiveSystemCountry = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_OS_COUNTRY];
            _disableActiveSystemLanguage= [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_OS_LANG];
            _disableActiveAppVersionCode= [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_APP_VERSION_CODE];
            _disableActiveAppVersion    = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_APP_VERSION_NAME];
            _disableActiveLib           = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_SDK_TYPE];
            _disableActiveLibVersion    = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_SDK_VERSION];
            _disableActiveOs            = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_OS];
            _disableActiveOsVersion     = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_OS_VERSION_NAME];
            _disableActiveManufacturer  = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_DEVICE_MANUFACTURER];
            _disableActiveDeviceBrand   = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_DEVICE_BRAND];
            _disableActiveDeviceModel   = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_DEVICE_MODEL];
            _disableActiveScreenHeight  = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_SCREEN_HEIGHT];
            _disableActiveScreenWidth   = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_SCREEN_WIDTH];
            _disableActiveRAM           = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_MEMORY_USED];
            _disableActiveDisk          = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_STORAGE_USED];
            _disableActiveNetworkType   = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_NETWORK_TYPE];
            _disableActiveSimulator     = [__td_disPresetProperties containsObject:USER_PROPERTY_ACTIVE_SIMULATOR];

            //用户属性Latest
            _disableLatestAppVersionCode = [__td_disPresetProperties containsObject:USER_PROPERTY_LATEST_APP_VERSION_CODE];
            _disableLatestAppVersion     = [__td_disPresetProperties containsObject:USER_PROPERTY_LATEST_APP_VERSION_NAME];
        }
    });
    return __td_disPresetProperties;
}


+ (void)handleFilterDisPresetProperties:(NSMutableDictionary *)dataDic
{
    if (!__td_disPresetProperties || !__td_disPresetProperties.count) {
        return ;
    }
    NSArray *propertykeys = dataDic.allKeys;
    NSArray *registerkeys = [DTPresetProperties disPresetProperties];
    NSMutableSet *set1 = [NSMutableSet setWithArray:propertykeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:registerkeys];
    [set1 intersectSet:set2];// 求交集
    if (!set1.allObjects.count) {
        return ;
    }
    [dataDic removeObjectsForKeys:set1.allObjects];
    return ;
}


+ (BOOL)disableIsForeground {
    return _disableIsForeground;
}

+ (BOOL)disableBundleId {
    return _disableBundleId;
}

+ (BOOL)disableAppVersion {
    return _disableAppVersion;
}

+ (BOOL)disableAppVersionCode {
    return _disableAppVersionCode;
}

+ (BOOL)disableLib {
    return _disableLib;
}

+ (BOOL)disableLibVersion {
    return _disableLibVersion;
}

+ (BOOL)disableOs {
    return _disableOs;
}

+ (BOOL)disableOsVersion {
    return _disableOsVersion;
}

+ (BOOL)disableSystemCountry {
    return _disableSystemCountry;
}

+ (BOOL)disableSystemLanguage {
    return _disableSystemLanguage;
}

+ (BOOL)disableScreenHeight {
    return _disableScreenHeight;
}

+ (BOOL)disableScreenWidth {
    return _disableScreenWidth;
}

+ (BOOL)disableDeviceBrand {
    return _disableDeviceBrand;
}

+ (BOOL)disableManufacturer {
    return _disableManufacturer;
}

+ (BOOL)disableDeviceModel {
    return _disableDeviceModel;
}

+ (BOOL)disableRAM {
    return _disableRAM;
}

+ (BOOL)disableDisk {
    return _disableDisk;
}

+ (BOOL)disableSimulator {
    return _disableSimulator;
}

+ (BOOL)disableNetworkType {
    return _disableNetworkType;
}

+ (BOOL)disableMcc {
    return _disableMcc;
}

+ (BOOL)disableMnc {
    return _disableMnc;
}

+ (BOOL)disableFPS {
    return _disableFPS;
}

+ (BOOL)disableZoneOffset {
    return _disableZoneOffset;
}

//active

+ (BOOL)disableActiveMcc {
    return _disableActiveMcc;
}

+ (BOOL)disableActiveMnc {
    return _disableActiveMnc;
}

+ (BOOL)disableActiveSystemCountry {
    return _disableActiveSystemCountry;
}

+ (BOOL)disableActiveSystemLanguage {
    return _disableActiveSystemLanguage;
}

+ (BOOL)disableActiveAppVersion {
    return _disableActiveAppVersion;
}

+ (BOOL)disableActiveAppVersionCode {
    return _disableActiveAppVersionCode;
}

+ (BOOL)disableActiveLib {
    return _disableActiveLib;
}

+ (BOOL)disableActiveLibVersion {
    return _disableActiveLibVersion;
}

+ (BOOL)disableActiveOs {
    return _disableActiveOs;
}

+ (BOOL)disableActiveOsVersion {
    return _disableActiveOsVersion;
}

+ (BOOL)disableActiveManufacturer {
    return _disableActiveManufacturer;
}

+ (BOOL)disableActiveDeviceBrand {
    return _disableActiveDeviceBrand;
}

+ (BOOL)disableActiveDeviceModel {
    return _disableActiveDeviceModel;
}

+ (BOOL)disableActiveScreenHeight {
    return _disableActiveScreenHeight;
}

+ (BOOL)disableActiveScreenWidth {
    return _disableActiveScreenWidth;
}

+ (BOOL)disableActiveRAM {
    return _disableActiveRAM;
}

+ (BOOL)disableActiveDisk {
    return _disableActiveDisk;
}

+ (BOOL)disableActiveNetworkType {
    return _disableActiveNetworkType;
}

+ (BOOL)disableActiveSimulator {
    return _disableActiveSimulator;
}

+ (BOOL)disableLatestAppVersion {
    return _disableLatestAppVersion;
}

+ (BOOL)disableLatestAppVersionCode {
    return _disableLatestAppVersionCode;
}




@end
