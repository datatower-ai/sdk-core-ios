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
        self.properties[@"#app_version"] = [DTDeviceInfo sharedManager].appVersion;
    }
    if (![DTPresetProperties disableBundleId]) {
        self.properties[@"#bundle_id"] = [DTDeviceInfo bundleId];
    }
        
    if (![DTPresetProperties disableInstallTime]) {
        self.properties[@"#install_time"] = [DTDeviceInfo dt_getInstallTime];
    }
}

- (void)asyncGetPropertyCompletion:(DTPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    [mutableDict addEntriesFromDictionary:[[DTDeviceInfo sharedManager] getAutomaticData]];
    
    if (![DTPresetProperties disableNetworkType]) {
        mutableDict[@"#network_type"] = [[DTReachability shareInstance] networkState];
    }
    
    if (completion) {
        completion(mutableDict);
    }
}

@end
