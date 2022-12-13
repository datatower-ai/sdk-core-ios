//
//  DTAnalyticsManager.h
//  report
//
//  Created by neo on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTConfig.h"
#import "DTAutoTrackEvent.h"
#import "DTPropertyPluginManager.h"
#import "DTSuperProperty.h"
NS_ASSUME_NONNULL_BEGIN

#ifndef dt_dispatch_main_sync_safe
#define dt_dispatch_main_sync_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

@interface DTAnalyticsManager : NSObject

///  配置
@property (nonatomic, strong)DTConfig *config;

/// 属性插件，用于采集系统属性
@property (nonatomic, strong) DTPropertyPluginManager *propertyPluginManager;

/// 公共属性
@property (nonatomic, strong) DTSuperProperty *superProperty;


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

/**
 记录事件时长

 @param event 事件名称
 */
- (void)timeEvent:(NSString *)event;


- (void)enableAutoTrack:(DTAutoTrackEventType)eventType;

- (void)autoTrackWithEvent:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties;

- (void)setSuperProperties:(NSDictionary *)properties;

- (void)unsetSuperProperty:(NSString *)propertyKey;

- (void)clearSuperProperties;

- (NSDictionary *)currentSuperProperties;
@end

NS_ASSUME_NONNULL_END
