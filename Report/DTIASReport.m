
#import "DTIASReport.h"
#import "DTReportEvent.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
@implementation DTIASReport

/// 展示订阅上报事件
/// - Parameters:
///   - seq: 系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement: 页面区分 ，不可为空
///   - properties: 自定义属性
+ (void)reportToShow:(NSString *)seq
            entrance:(NSString *)entrance
           placement:(NSString *)placement
          properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_TO_SHOW_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/// 展示订阅内容成功事件
/// - Parameters:
///   - seq: 系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement: 页面区分 ，不可为空
///   - properties: 自定义属性
+ (void)reportShowSuccess:(NSString *)seq
                 entrance:(NSString *)entrance
                placement:(NSString *)placement
               properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SHOW_SUCCESS_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/// 展示订阅内容失败
/// - Parameters:
///   - seq:  系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement:  页面区分 ，不可为空
///   - errorCode: 错误码
///   - errorMsg: 额外信息，可为空
///   - properties: 自定义属性
+ (void)reportShowFail:(NSString *)seq
              entrance:(NSString *)entrance
             placement:(NSString *)placement
             errorCode:(NSString *)errorCode
              errorMsg:(NSString *)errorMsg
            properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    propertiesCopy[IAS_CODE] = errorCode;
    propertiesCopy[IAS_MSG] = errorMsg;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SHOW_FAIL_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/// 点击内购事件上报
/// - Parameters:
///   - seq: 系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement: 页面区分，不可为空
///   - sku: 订阅的产品ID
///   - orderId: 订单ID
///   - price: 价格
///   - currency: 货币
///   - properties: 自定义属性
+ (void)reportSubscribe:(NSString *)seq
               entrance:(NSString *)entrance
              placement:(NSString *)placement
                    sku:(NSString *)sku
                orderId:(NSString *)orderId
                  price:(NSString *)price
               currency:(NSString *)currency
             properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    propertiesCopy[IAS_SKU] = sku;
    propertiesCopy[IAS_ORDER_ID] = orderId;
    propertiesCopy[IAS_PRICE] = price;
    propertiesCopy[IAS_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_TO_SUBSCRIBE_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/// 订阅成功事件上报
/// - Parameters:
///   - seq: 系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement: 页面区分，不可为空
///   - sku: 订阅的产品ID
///   - orderId: 订单ID
///   - originalOrderId: 原始订单订单ID
///   - price: 价格
///   - currency: 货币
///   - properties: 自定义属性
+ (void)reportSubscribeSuccess:(NSString *)seq
                      entrance:(NSString *)entrance
                     placement:(NSString *)placement
                           sku:(NSString *)sku
                       orderId:(NSString *)orderId
               originalOrderId:(NSString *)originalOrderId
                         price:(NSString *)price
                      currency:(NSString *)currency
                    properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    propertiesCopy[IAS_SKU] = sku;
    propertiesCopy[IAS_ORDER_ID] = orderId;
    propertiesCopy[IAS_ORIGINAL_ORDER_ID] = originalOrderId;
    propertiesCopy[IAS_PRICE] = price;
    propertiesCopy[IAS_CURRENCY] = currency;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SUBSCRIBE_SUCCESS_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/// 订阅失败事件上报
/// - Parameters:
///   - seq: 系列行为唯一标识
///   - entrance: 入口，可为空
///   - placement: 页面区分，不可为空
///   - sku: 订阅的产品ID
///   - orderId: 订单ID
///   - originalOrderId: 原始订单订单ID
///   - price: 价格
///   - currency: 货币
///   - errorCode: 错误码
///   - errorMsg: 额外信息
///   - properties: 自定义属性
+ (void)reportSubscribeFail:(NSString *)seq
                   entrance:(NSString *)entrance
                  placement:(NSString *)placement
                        sku:(NSString *)sku
                    orderId:(NSString *)orderId
            originalOrderId:(NSString *)originalOrderId
                      price:(NSString *)price
                   currency:(NSString *)currency
                  errorCode:(NSString *)errorCode
                   errorMsg:(NSString *)errorMsg
                 properties:(NSDictionary *)properties {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[IAS_ENTRANCE] = entrance;
    propertiesCopy[IAS_PLACEMENT] = placement;
    propertiesCopy[IAS_SEQ] = seq;
    propertiesCopy[IAS_SKU] = sku;
    propertiesCopy[IAS_ORDER_ID] = orderId;
    propertiesCopy[IAS_ORIGINAL_ORDER_ID] = originalOrderId;
    propertiesCopy[IAS_PRICE] = price;
    propertiesCopy[IAS_CURRENCY] = currency;
    propertiesCopy[IAS_CODE] = errorCode;
    propertiesCopy[IAS_MSG] = errorMsg;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:IAS_SUBSCRIBE_FAIL_EVENT];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}



@end
