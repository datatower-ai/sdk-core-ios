//
//  TDPresetProperties+TDDisProperties.h
//
//
//
//  不能使用的

#import "DTPresetProperties.h"
#import "DTBaseEvent.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTPresetProperties (TDDisProperties)

//事件属性
@property(class, nonatomic, readonly) BOOL disableIsForeground;
@property(class, nonatomic, readonly) BOOL disableBundleId;
@property(class, nonatomic, readonly) BOOL disableAppVersionCode;
@property(class, nonatomic, readonly) BOOL disableAppVersion;
@property(class, nonatomic, readonly) BOOL disableLib;
@property(class, nonatomic, readonly) BOOL disableLibVersion;
@property(class, nonatomic, readonly) BOOL disableOs;
@property(class, nonatomic, readonly) BOOL disableOsVersion;
@property(class, nonatomic, readonly) BOOL disableSystemCountry;
@property(class, nonatomic, readonly) BOOL disableSystemLanguage;
@property(class, nonatomic, readonly) BOOL disableScreenHeight;
@property(class, nonatomic, readonly) BOOL disableScreenWidth;
@property(class, nonatomic, readonly) BOOL disableDeviceBrand;
@property(class, nonatomic, readonly) BOOL disableManufacturer;
@property(class, nonatomic, readonly) BOOL disableDeviceModel;
@property(class, nonatomic, readonly) BOOL disableRAM;
@property(class, nonatomic, readonly) BOOL disableDisk;
@property(class, nonatomic, readonly) BOOL disableSimulator;
@property(class, nonatomic, readonly) BOOL disableNetworkType;
@property(class, nonatomic, readonly) BOOL disableMcc;
@property(class, nonatomic, readonly) BOOL disableMnc;
@property(class, nonatomic, readonly) BOOL disableFPS;
@property(class, nonatomic, readonly) BOOL disableZoneOffset;

//用户属性Active
@property(class, nonatomic, readonly) BOOL disableActiveMcc;
@property(class, nonatomic, readonly) BOOL disableActiveMnc;
@property(class, nonatomic, readonly) BOOL disableActiveSystemCountry;
@property(class, nonatomic, readonly) BOOL disableActiveSystemLanguage;
@property(class, nonatomic, readonly) BOOL disableActiveBundleId;
@property(class, nonatomic, readonly) BOOL disableActiveAppVersionCode;
@property(class, nonatomic, readonly) BOOL disableActiveAppVersion;
@property(class, nonatomic, readonly) BOOL disableActiveLib;
@property(class, nonatomic, readonly) BOOL disableActiveLibVersion;
@property(class, nonatomic, readonly) BOOL disableActiveOs;
@property(class, nonatomic, readonly) BOOL disableActiveOsVersion;
@property(class, nonatomic, readonly) BOOL disableActiveManufacturer;
@property(class, nonatomic, readonly) BOOL disableActiveDeviceBrand;
@property(class, nonatomic, readonly) BOOL disableActiveDeviceModel;
@property(class, nonatomic, readonly) BOOL disableActiveScreenHeight;
@property(class, nonatomic, readonly) BOOL disableActiveScreenWidth;
@property(class, nonatomic, readonly) BOOL disableActiveRAM;
@property(class, nonatomic, readonly) BOOL disableActiveDisk;
@property(class, nonatomic, readonly) BOOL disableActiveNetworkType;
@property(class, nonatomic, readonly) BOOL disableActiveSimulator;

//用户属性Latest
@property(class, nonatomic, readonly) BOOL disableLatestAppVersionCode;//
@property(class, nonatomic, readonly) BOOL disableLatestAppVersion;



/// 需要过滤的预置属性
+ (NSArray*)disPresetProperties;

/// 过滤预置属性
/// @param dataDic 外层property
+ (void)handleFilterDisPresetProperties:(NSMutableDictionary *)dataDic;

@end

NS_ASSUME_NONNULL_END
