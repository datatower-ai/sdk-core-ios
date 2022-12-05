//
//  DTAnalyticsManager.h
//  report
//
//  Created by neo on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTAnalyticsConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTAnalyticsManager : NSObject

+ (DTAnalyticsManager *)shareInstance;

- (void)initializeWithConfig:(DTAnalyticsConfig *)config;

@end

NS_ASSUME_NONNULL_END
