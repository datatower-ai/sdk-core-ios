//
//  DataTower.m
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import "DTIAPReport.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
@implementation DTIAPReport

/**
 * 展示购买入口的时候上报
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 * @param seq 系列行为标识
 * @param placement 入口，可为空
 */
+ (void)reportEntrance:(NSString *)order
                   sku:(NSString *)sku
                 price:(NSNumber *)price
              currency:(NSString *)currency
                   seq:(NSString *)seq
             placement:(NSString *)placement {
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = price;
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    propertiesCopy[PROPERTY_IAP_PLACEMENT] = placement;
    propertiesCopy[PROPERTY_IAP_SEQ] = seq;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_ENTRANCE];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 点击购买的时候上报
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 * @param seq 系列行为标识
 * @param placement 入口，可为空
 */
+ (void)reportToPurchase:(NSString *)order
                     sku:(NSString *)sku
                   price:(NSNumber *)price
                currency:(NSString *)currency
                     seq:(NSString *)seq
               placement:(NSString *)placement {
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = price;
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    propertiesCopy[PROPERTY_IAP_PLACEMENT] = placement;
    propertiesCopy[PROPERTY_IAP_SEQ] = seq;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_TO_PURCHASE];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}
/**
 * 购买成功的时候上报，无论是否消耗
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 * @param seq 系列行为标识
 * @param placement 入口，可为空
 */
+ (void)reportPurchased:(NSString *)order
                    sku:(NSString *)sku
                  price:(NSNumber *)price
               currency:(NSString *)currency
                    seq:(NSString *)seq
              placement:(NSString *)placement {
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = price;
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    propertiesCopy[PROPERTY_IAP_PLACEMENT] = placement;
    propertiesCopy[PROPERTY_IAP_SEQ] = seq;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_PURCHASED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}
/**
 * 购买失败的时候上报
 *
 * @param order 订单
 * @param sku 商品ID
 * @param price 价格， 如 9.99
 * @param currency 货币，如usd
 * @param seq 系列行为标识
 * @param code 错误码
 * @param placement 入口，可为空
 * @param msg 额外信息，可为空
 */
+ (void)reportNotToPurchased:(NSString *)order
                         sku:(NSString *)sku
                       price:(NSNumber *)price
                    currency:(NSString *)currency
                         seq:(NSString *)seq
                        code:(NSString *)code
                         msg:(NSString *)msg
                   placement:(NSString *)placement {
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = price;
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    propertiesCopy[PROPERTY_IAP_PLACEMENT] = placement;
    propertiesCopy[PROPERTY_IAP_SEQ] = seq;
    propertiesCopy[PROPERTY_IAP_CODE] = code;
    propertiesCopy[PROPERTY_IAP_MSG] = msg;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_NOT_PURCHASED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


@end
