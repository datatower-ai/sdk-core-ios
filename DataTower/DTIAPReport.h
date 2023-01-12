
#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTIAPReport : NSObject
/**
 * 购买成功上报
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 */
+ (void)reportPurchaseSuccess:(NSString *)order
                          sku:(NSString *)sku
                        price:(double)price
                     currency:(NSString *)currency;



/**
 * 购买成功上报
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 * @param properties 自定义属性
 */
+ (void)reportPurchaseSuccess:(NSString *)order
                          sku:(NSString *)sku
                        price:(double)price
                     currency:(NSString *)currency
                   properties:(NSDictionary *)properties;
@end

NS_ASSUME_NONNULL_END
