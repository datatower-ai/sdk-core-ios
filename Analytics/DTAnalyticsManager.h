//
//  DTAnalyticsManager.h
//  report
//
//  Created by neo on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTConfig.h"
#import "DTPropertyPluginManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTAnalyticsManager : NSObject

@property (nonatomic, strong) DTPropertyPluginManager *propertyPluginManager;

#pragma mark -  initiate

+ (DTAnalyticsManager *)shareInstance;

- (void)initializeWithConfig:(DTConfig *)config;

#pragma mark -  Track

/**
 自定义事件埋点

 @param event         事件名称
 */
- (void)track:(NSString *)event;


/**
 自定义事件埋点

 @param event         事件名称
 @param propertieDict 事件属性
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;

@end

NS_ASSUME_NONNULL_END
