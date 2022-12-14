//
//  DTAnalytics.h
//  report
//
//  Created by neo on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTAnalytics : NSObject

+ (void)initializeWithConfig:(DTConfig *)config;

+ (void)trackEventName:(NSString *)eventName;

+ (void)trackEventName:(NSString *)eventName properties:(NSDictionary *)properties;

/**
 设置用户属性

 @param properties 用户属性
 */
+ (void)userSet:(NSDictionary *)properties;

/**
 重置用户属性
 
 @param propertyName 用户属性
 */
+ (void)userUnset:(NSString *)propertyName;

/**
 设置单次用户属性

 @param properties 用户属性
 */
+ (void)userSetOnce:(NSDictionary *)properties;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 */
+ (void)userAdd:(NSDictionary *)properties;

/**
 删除用户 该操作不可逆 需慎重使用
 */
+ (void)userDelete;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
*/
+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties;





@end

NS_ASSUME_NONNULL_END
