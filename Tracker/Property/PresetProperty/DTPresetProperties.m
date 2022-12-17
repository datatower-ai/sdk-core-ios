//
//  TDPresetProperties.m
//  ThinkingSDK
//
//  Created by huangdiao on 2021/5/25.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "DTPresetProperties.h"
#import "DTPresetProperties+DTDisProperties.h"
#import "DTBaseEvent.h"
#import "DTDeviceInfo.h"
#import "DTConfig.h"

@interface DTPresetProperties ()

@property (nonatomic, copy, readwrite) NSString *bundle_id;
@property (nonatomic, copy, readwrite) NSString *carrier;
@property (nonatomic, copy, readwrite) NSString *device_id;
@property (nonatomic, copy, readwrite) NSString *device_model;
@property (nonatomic, copy, readwrite) NSString *manufacturer;
@property (nonatomic, copy, readwrite) NSString *network_type;
@property (nonatomic, copy, readwrite) NSString *os;
@property (nonatomic, copy, readwrite) NSString *os_version;
@property (nonatomic, copy, readwrite) NSNumber *screen_height;
@property (nonatomic, copy, readwrite) NSNumber *screen_width;
@property (nonatomic, copy, readwrite) NSString *system_language;
@property (nonatomic, copy, readwrite) NSNumber *zone_offset;

@property (nonatomic, copy) NSDictionary *presetProperties;
@property (nonatomic, copy) NSDictionary *activeProperties;
@property (nonatomic, copy) NSDictionary *latestProperties;

@end

@implementation DTPresetProperties

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateActivePresetProperties:dict];
        [self updateLatestPresetProperties:dict];
    }
    return self;
}

- (NSDictionary *)getActivePresetProperties {
    return [_activeProperties copy];
}

- (NSDictionary *)getLatestPresetProperties {
    
    return [_latestProperties copy];
}

- (void)updateActivePresetProperties:(NSDictionary *)dict {
    if (!dict){
        return;
    }
    NSMutableDictionary *copyDict = [dict mutableCopy];
    NSMutableDictionary *activeProperties = [NSMutableDictionary dictionary];
    
    activeProperties[USER_PROPERTY_ACTIVE_MCC]              = copyDict[COMMON_PROPERTY_MCC];
    activeProperties[USER_PROPERTY_ACTIVE_MNC]              = copyDict[COMMON_PROPERTY_MNC];
    activeProperties[USER_PROPERTY_ACTIVE_OS_COUNTRY]       = copyDict[COMMON_PROPERTY_OS_COUNTRY];
    activeProperties[USER_PROPERTY_ACTIVE_OS_LANG]          = copyDict[COMMON_PROPERTY_OS_LANG];
    activeProperties[USER_PROPERTY_ACTIVE_PKG]              = [DTDeviceInfo bundleId];
    activeProperties[USER_PROPERTY_ACTIVE_APP_VERSION_CODE] = copyDict[COMMON_PROPERTY_APP_VERSION_CODE];
    activeProperties[USER_PROPERTY_ACTIVE_APP_VERSION_NAME] = copyDict[COMMON_PROPERTY_APP_VERSION_NAME];
    activeProperties[USER_PROPERTY_ACTIVE_SDK_TYPE]         = copyDict[COMMON_PROPERTY_SDK_TYPE];
    activeProperties[USER_PROPERTY_ACTIVE_SDK_VERSION]      = copyDict[COMMON_PROPERTY_SDK_VERSION];
    activeProperties[USER_PROPERTY_ACTIVE_OS]               = copyDict[COMMON_PROPERTY_OS];
    activeProperties[USER_PROPERTY_ACTIVE_OS_VERSION_NAME]  = copyDict[COMMON_PROPERTY_OS_VERSION_NAME];
    activeProperties[USER_PROPERTY_ACTIVE_DEVICE_MANUFACTURER] = copyDict[COMMON_PROPERTY_DEVICE_MANUFACTURER];
    activeProperties[USER_PROPERTY_ACTIVE_DEVICE_BRAND]     = copyDict[COMMON_PROPERTY_DEVICE_BRAND];
    activeProperties[USER_PROPERTY_ACTIVE_DEVICE_MODEL]     = copyDict[COMMON_PROPERTY_DEVICE_MODEL];
    activeProperties[USER_PROPERTY_ACTIVE_SCREEN_HEIGHT]    = copyDict[COMMON_PROPERTY_SCREEN_HEIGHT];
    activeProperties[USER_PROPERTY_ACTIVE_SCREEN_WIDTH]     = copyDict[COMMON_PROPERTY_SCREEN_WIDTH];
    activeProperties[USER_PROPERTY_ACTIVE_MEMORY_USED]      = copyDict[COMMON_PROPERTY_MEMORY_USED];
    activeProperties[USER_PROPERTY_ACTIVE_STORAGE_USED]     = copyDict[COMMON_PROPERTY_STORAGE_USED];
    activeProperties[USER_PROPERTY_ACTIVE_NETWORK_TYPE]     = copyDict[COMMON_PROPERTY_NETWORK_TYPE];
    activeProperties[USER_PROPERTY_ACTIVE_SIMULATOR]        = copyDict[COMMON_PROPERTY_SIMULATOR];
    activeProperties[USER_PROPERTY_ACTIVE_USER_AGENT]       = [DTDeviceInfo userAgent];
    _activeProperties = activeProperties;
    
}

- (void)updateLatestPresetProperties:(NSDictionary *)dict {
    if (!dict){
        return;
    }
    NSMutableDictionary *copyDict = [dict mutableCopy];
    NSMutableDictionary *latestProperties = [NSMutableDictionary dictionary];
    if([DTConfig shareInstance].enabledDebug){
        latestProperties[USER_PROPERTY_LATEST_DEBUG] = @(YES);
    }
    latestProperties[USER_PROPERTY_LATEST_APP_VERSION_CODE] = copyDict[COMMON_PROPERTY_APP_VERSION_CODE];
    latestProperties[USER_PROPERTY_LATEST_APP_VERSION_NAME] = copyDict[COMMON_PROPERTY_APP_VERSION_NAME];
    _latestProperties = latestProperties;
}

- (void)updateValuesWithDictionary:(NSDictionary *)dict {
    _bundle_id = dict[@"#bundle_id"]?:@"";
    _carrier = dict[@"#carrier"]?:@"";
    _device_id = dict[@"#device_id"]?:@"";
    _device_model = dict[@"#device_model"]?:@"";
    _manufacturer = dict[@"#manufacturer"]?:@"";
    _network_type = dict[@"#network_type"]?:@"";
    _os = dict[@"#os"]?:@"";
    _os_version = dict[@"#os_version"]?:@"";
    _screen_height = dict[@"#screen_height"]?:@(0);
    _screen_width = dict[@"#screen_width"]?:@(0);
    _system_language = dict[@"#system_language"]?:@"";
    _zone_offset = dict[@"#zone_offset"]?:@(0);

    _presetProperties = [NSDictionary dictionaryWithDictionary:dict];
    
    // 过滤不需要的预置属性
    NSMutableDictionary *updateProperties = [_presetProperties mutableCopy];
    NSArray *propertykeys = updateProperties.allKeys;
    NSArray *registerkeys = [DTPresetProperties disPresetProperties];
    NSMutableSet *set1 = [NSMutableSet setWithArray:propertykeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:registerkeys];
    [set1 intersectSet:set2];// 求交集
    if (set1.allObjects.count) {
        [updateProperties removeObjectsForKeys:set1.allObjects];
    }
    
    // 移除lib、lib_version
    if ([updateProperties.allKeys containsObject:@"#lib"]) {
        [updateProperties removeObjectForKey:@"#lib"];
    }
    if ([updateProperties.allKeys containsObject:@"#lib_version"]) {
        [updateProperties removeObjectForKey:@"#lib_version"];
    }
    
    _presetProperties = updateProperties;
}

- (NSDictionary *)toEventPresetProperties {
    return [_presetProperties copy];
}

@end
