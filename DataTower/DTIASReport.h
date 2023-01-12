
#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTIASReport : NSObject

/// 订阅成功事件上报
/// - Parameters:
///   - originalOrderId: 原始订单订单ID
///   - orderId: 订单ID
///   - sku: 订阅的产品ID
///   - price: 价格
///   - currency: 货币
+ (void)reportSubscribeSuccess:(NSString *)originalOrderId
                       orderId:(NSString *)orderId
                           sku:(NSString *)sku
                         price:(double)price
                      currency:(NSString *)currency;
                    

/// 订阅成功事件上报
/// - Parameters:
///   - originalOrderId: 原始订单订单ID
///   - orderId: 订单ID
///   - sku: 订阅的产品ID
///   - price: 价格
///   - currency: 货币
///   - properties: 自定义属性
+ (void)reportSubscribeSuccess:(NSString *)originalOrderId
                       orderId:(NSString *)orderId
                           sku:(NSString *)sku
                         price:(double)price
                      currency:(NSString *)currency
                    properties:(NSDictionary *)properties;
@end

NS_ASSUME_NONNULL_END
