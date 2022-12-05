//
//  DTAnalytics.h
//  report
//
//  Created by neo on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTAnalyticsConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTAnalytics : NSObject

+ (void)initializeWithConfig:(DTAnalyticsConfig *)config;

+ (void)trackEventName:(NSString *)eventName properties:(NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END
