//
//  DTAnalytics.m
//  report
//
//  Created by neo on 2022/12/5.
//

#import "DTAnalytics.h"
#import "DTAnalyticsManager.h"
@implementation DTAnalytics

+ (void)initializeWithConfig:(DTConfig *)config {
    [[DTAnalyticsManager shareInstance] initializeWithConfig:config];
}

+ (void)trackEventName:(NSString *)eventName properties:(NSDictionary *)properties {
    [[DTAnalyticsManager shareInstance] track:eventName properties:properties];
}

@end
