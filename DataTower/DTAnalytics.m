#import "DTAnalytics.h"
#import "DTAnalyticsManager.h"
#import "PerfLogger.h"
@implementation DTAnalytics


+ (void)trackEventName:(NSString *)eventName properties:(NSDictionary *)properties {
    [[DTAnalyticsManager shareInstance] track:eventName properties:properties];
}

+ (void)trackEventName:(NSString *)eventName{
    [[DTAnalyticsManager shareInstance] track:eventName];
}

/**
 设置用户属性
 
 @param properties 用户属性
 */
+ (void)userSet:(NSDictionary *)properties{
    [[DTAnalyticsManager shareInstance] user_set:properties];
}

/**
 重置用户属性
 
 @param propertyName 用户属性
 */
+ (void)userUnset:(NSString *)propertyName{
    [[DTAnalyticsManager shareInstance] user_unset:propertyName];
}

/**
 设置单次用户属性
 
 @param properties 用户属性
 */
+ (void)userSetOnce:(NSDictionary *)properties{
    [[DTAnalyticsManager shareInstance] user_setOnce:properties];
}

/**
 对数值类型用户属性进行累加操作
 
 @param properties 用户属性
 */
+ (void)userAdd:(NSDictionary *)properties{
    [[DTAnalyticsManager shareInstance] user_add:properties];
}

/**
 删除用户 该操作不可逆 需慎重使用
 */
+ (void)userDelete{
    [[DTAnalyticsManager shareInstance] user_delete];
}

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
 */
+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties{
    [[DTAnalyticsManager shareInstance] user_append:properties];
}

+ (void)userUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    [[DTAnalyticsManager shareInstance] user_uniqAppend:properties];
}

/// 设置自有用户系统的id
/// - Parameters:
///   - accountId: 用户系统id
+ (void)setAccountId:(NSString *)accountId {
    [[DTAnalyticsManager shareInstance] setAcid:accountId];
}

//+ (void)setDistinctId:(NSString *)distinctId; {
//    [[DTAnalyticsManager shareInstance] setDistinctid:distinctId];
//}

/// 设置Firebase的app_instance_id
/// - Parameters:
///   - fiid: Firebase 的 app_instance_id
+ (void)setFirebaseAppInstanceId:(NSString *)fiid {
    [[DTAnalyticsManager shareInstance] setFirebaseAppInstanceId:fiid];
}

/// 设置AppsFlyer的appsflyer_id
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
+ (void)setAppsFlyerId:(NSString *)afid {
    [[DTAnalyticsManager shareInstance] setAppsFlyerId:afid];
}

/// 设置kochava iid
/// - Parameters:
///   - afuid: AppsFlyer的appsflyer_id
+ (void)setKochavaId:(NSString *)koid {
    [[DTAnalyticsManager shareInstance] setKochavaId:koid];
}

/// 设置AdjustId
/// - Parameter adjustId: AdjustId
+ (void)setAdjustId:(NSString *)adjustId {
    [[DTAnalyticsManager shareInstance] setAdjustId:adjustId];
}

+ (void)setIasOriginalOrderId:(NSString *)oorderId {
    [[DTAnalyticsManager shareInstance] setIasOriginalOrderId:oorderId];
}

+ (NSString *)getDataTowerId {
    [[DTPerfLogger shareInstance] doLog:GETDTIDBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    NSString *ret = [[DTAnalyticsManager shareInstance] getDTid];
    
    [[DTPerfLogger shareInstance] doLog:GETDTIDEND time:[NSDate timeIntervalSinceReferenceDate]];
    
    return ret;
}

+ (NSString *)getDistinctId {
    return [[DTAnalyticsManager shareInstance] currentDistinctID];
}

+ (void)setEnableTracking:(BOOL)track {
    [DTConfig shareInstance].enableUpload = track;
    if(track)
    {
        [[DTAnalyticsManager shareInstance] flush];
    }
}

+ (void)setSuperProperties:(nullable NSDictionary *)superProps {
    if(!superProps || superProps.count == 0) {
        [[DTAnalyticsManager shareInstance] clearSuperProperties];
    } else {
        [[DTAnalyticsManager shareInstance] setSuperProperties:superProps];
    }
}

+ (void)setDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    
    [[DTAnalyticsManager shareInstance] registerDynamicSuperProperties:dynamicSuperProperties];
}

@end
