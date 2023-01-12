
#import "DTIAPReport.h"
#import "DTReportEvent.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
@implementation DTIAPReport


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
                     currency:(NSString *)currency{
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = [NSNumber numberWithDouble:price];
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_PURCHASED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

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
                   properties:(NSDictionary *)properties
{
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];;
    propertiesCopy[PROPERTY_IAP_ORDER] = order;
    propertiesCopy[PROPERTY_IAP_SKU] = sku;
    propertiesCopy[PROPERTY_IAP_PRICE] = [NSNumber numberWithDouble:price];
    propertiesCopy[PROPERTY_IAP_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_IAP_PURCHASED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


@end
