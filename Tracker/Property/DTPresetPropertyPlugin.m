//
//  DTPresetPropertyPlugin.m
//
//
//
//

#import "DTPresetPropertyPlugin.h"
#import "DTPresetProperties.h"
#import "DTPresetProperties+DTDisProperties.h"
#import "DTDeviceInfo.h"
#import "DTReachability.h"

@interface DTPresetPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;

@end

@implementation DTPresetPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    if (![DTPresetProperties disableAppVersion]) {
        self.properties[COMMON_PROPERTY_APP_VERSION_NAME] = [DTDeviceInfo sharedManager].appVersion;
        self.properties[COMMON_PROPERTY_APP_VERSION_CODE] = [DTDeviceInfo sharedManager].appVersionCode;
    }
   
}

- (void)asyncGetPropertyCompletion:(DTPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    [mutableDict addEntriesFromDictionary:[[DTDeviceInfo sharedManager] getAutomaticData]];
    
    if (![DTPresetProperties disableNetworkType]) {
        mutableDict[COMMON_PROPERTY_NETWORK_TYPE] = [[DTReachability shareInstance] networkState];
    }
    
    if (completion) {
        completion(mutableDict);
    }
}

@end
