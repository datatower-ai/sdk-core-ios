//
//  DTInstallTracker.m
//
//
//
//

#import "DTInstallTracker.h"
#import "DTDeviceInfo.h"

@implementation DTInstallTracker

- (BOOL)isOneTime {
    return YES;
}

- (BOOL)additionalCondition {
    return [DTDeviceInfo sharedManager].isFirstOpen;
}

@end
