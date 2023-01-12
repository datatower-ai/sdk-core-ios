
#import "DTIASReport.h"
#import "DTReportEvent.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
@implementation DTIASReport

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
                      currency:(NSString *)currency
{
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    
    propertiesCopy[IAS_SKU] = sku;
    propertiesCopy[IAS_ORDER_ID] = orderId;
    propertiesCopy[IAS_ORIGINAL_ORDER_ID] = originalOrderId;
    propertiesCopy[IAS_PRICE] = [NSNumber numberWithDouble:price];
    propertiesCopy[IAS_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SUBSCRIBE_SUCCESS_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

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
                    properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    
    propertiesCopy[IAS_SKU] = sku;
    propertiesCopy[IAS_ORDER_ID] = orderId;
    propertiesCopy[IAS_ORIGINAL_ORDER_ID] = originalOrderId;
    propertiesCopy[IAS_PRICE] = [NSNumber numberWithDouble:price];
    propertiesCopy[IAS_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SUBSCRIBE_SUCCESS_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


@end
