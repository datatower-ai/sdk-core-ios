#import <Foundation/Foundation.h>
#import "DTConfig.h"
#import "DTAutoTrackEvent.h"
#import "DTPropertyPluginManager.h"
#import "DTSuperProperty.h"
#import "DTPresetProperties.h"
#import "DTCalibratedTimeWithDTServer.h"

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

/// 预置属性
@property (nonatomic, strong) DTPresetProperties *presetProperty;

/// 时间同步
@property (strong, nonatomic) DTCalibratedTimeWithDTServer *calibratedTime;


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


- (void)asyncTrackEventObject:(DTTrackEvent *)event properties:(NSDictionary *)properties;

///发送数据到服务端
- (void)flush;

/**
 记录事件时长

 @param event 事件名称
 */
- (void)timeEvent:(NSString *)event;

- (void)timeEventUpdate:(NSString *)event withState:(BOOL)state;

- (void)trackTimeEvent:(NSString *)event properties:(nullable NSDictionary *)propertieDict;

- (void)enableAutoTrack:(DTAutoTrackEventType)eventType;

- (void)autoTrackWithEvent:(DTAutoTrackEvent *)event properties:(NSDictionary *)properties;

- (void)setSuperProperties:(NSDictionary *)properties;

- (void)unsetSuperProperty:(NSString *)propertyKey;

- (void)clearSuperProperties;

- (NSDictionary *)currentSuperProperties;

- (NSDictionary *)currentDynamicProperties;

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties;

- (void)user_set:(NSDictionary *)properties;

/**
 重置用户属性
 
 @param propertyName 用户属性
 */
- (void)user_unset:(NSString *)propertyName;

/**
 设置单次用户属性

 @param properties 用户属性
 */
- (void)user_setOnce:(NSDictionary *)properties;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 */
- (void)user_add:(NSDictionary *)properties;

/**
  对数值类型用户属性进行累加操作

  @param propertyName  属性名称
  @param propertyValue 属性值
 */
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;

/**
 删除用户 该操作不可逆 需慎重使用
 */
- (void)user_delete;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties;

/**
 对 Array 类型的用户属性进行追加操作，并且对数组内的元素去重
 
 @param properties 用户属性
*/
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties;

/// 设置自有用户系统的id
/// - Parameters:
///   - accountId: 用户系统id
- (void)setAcid:(NSString *)accountId;

/// 设置访客的id
/// - Parameters:
///   - distinctId: 访客id
//- (void)setDistinctid:(NSString *)distinctId;

- (NSString *)currentDistinctID;

/// 设置Firebase的app_instance_id
/// - Parameters:
///   - fiid: Firebase 的 app_instance_id
- (void)setFirebaseAppInstanceId:(NSString *)fiid;

/// 设置AppsFlyer的appsflyer_id
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
- (void)setAppsFlyerId:(NSString *)afid;

/// 设置kochava iid
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
- (void)setKochavaId:(NSString *)koid;

/// 设置AdjustId
/// - Parameter adjustId: AdjustId
- (void)setAdjustId:(NSString *)adjustId;


/// 设置TenjinId
/// - Parameter TenjinId: TenjinId
- (void)setTenjinId:(NSString *)tenjinId;

/// 设置订阅原始订单id
/// - Parameters:
///   - oorderId : 订阅原始订单id
- (void)setIasOriginalOrderId:(NSString *)oorderId;

- (NSString *)getDTid;

- (void)setInMemoryCommonProperties:(NSDictionary *)properties;

- (void)unsetInMomoryCommonProperty:(NSString *)propertyKey;

- (void)clearInMemoryCommonProperties;

- (NSDictionary *)currentInMemoryCommonProperties;

@end

NS_ASSUME_NONNULL_END
