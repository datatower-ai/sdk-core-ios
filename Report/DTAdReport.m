//
//  DataTower.m
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import "DTAdReport.h"
#import "DTConfig.h"
@implementation DTAdReport


/**
 * 上报 广告开始加载
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param seq 系列行为标识
 * @param properties 自定义属性
 */

+ (void) reportLoadBegin:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties {
    
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    DTReportEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_LOAD_BEGIN];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 广告结束加载
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param duration 广告加载时长
 * @param result 广告加载结果
 * @param seq 系列行为标识
 * @param errorCode 失败错误码
 * @param errorMessage 失败错误信息
 * @param properties 自定义属性
 */
+ (void) reportLoadEnd:(NSString *)adid
                  type:(DTAdType)type
              platform:(DTAdPlatform)platform
              duration:(NSNumber *)duration
                result:(BOOL)result
                   seq:(NSString *)seq
             errorCode:(NSInteger)errorCode
          errorMessage:(NSString *)errorMessage
            properties:(NSDictionary *)properties {
    
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_LOAD_DURATION] = duration;
    propertiesCopy[PROPERTY_LOAD_RESULT] = @(result);
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_ERROR_CODE] = [NSNumber numberWithInteger:errorCode];
    propertiesCopy[PROPERTY_ERROR_MESSAGE] = errorMessage;
    DTReportEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_LOAD_END];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 广告展示请求
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportToShow:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
             entrance:(NSString *)entrance {
    
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_TO_SHOW];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}



/**
 * 上报 广告展示
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportShow:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
           entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_SHOW];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 上报 广告展示失败
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param errorCode 失败错误码
 * @param errorMessage 失败错误信息
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportAdShowFail:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
                errorCode:(NSInteger)errorCode
             errorMessage:(NSString *)errorMessage
              properties:(NSDictionary *)properties
                entrance:(NSString *)entrance {
    
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_ERROR_CODE] = [NSNumber numberWithInteger:errorCode];
    propertiesCopy[PROPERTY_ERROR_MESSAGE] = errorMessage;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_SHOW_FAILED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
    
}

/**
 * 上报 广告点击
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportClick:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
                entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CLICK];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 自定义转化，通过点击
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportConversionByClick:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
                entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_AD_CONVERSION_SOURCE] = @"by_click";
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CONVERSION];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 上报 激励广告已获得奖励
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportRewarded:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
               entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_REWARDED];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 上报 自定义转化事件，通过获得激励
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportConversionByRewarded:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
                           entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_AD_CONVERSION_SOURCE] = @"by_rewarded";
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CONVERSION];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 访问广告链接，离开当前app(页面)
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportLeftApp:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
              entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_LEFT_APP];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 自定义转化，通过跳出app
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportConversionByLeftApp:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
                          entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_AD_CONVERSION_SOURCE] = @"by_left_app";
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CONVERSION];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 上报 访问广告链接，离开当前app(页面)
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportReturnApp:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                clickGap:(NSNumber *)clickGap
                returnGap:(NSNumber *)returnGap
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
                entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_CLICK_GAP] = clickGap;
    propertiesCopy[PROPERTY_AD_RETURN_GAP] = returnGap;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_RETURN_APP];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报广告展示价值
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param value 价值
 * @param currency 货币
 * @param precision 精确度
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportPaid:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
                    value:(NSString *)value
                currency:(NSString *)currency
                precision:(NSString *)precision
              properties:(NSDictionary *)properties
                entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_AD_VALUE_MICROS] = value;
    propertiesCopy[PROPERTY_AD_CURRENCY_CODE] = currency;
    propertiesCopy[PROPERTY_AD_PRECISION_TYPE] = precision;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_PAID];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报广告展示价值（聚合广告）
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param value 价值
 * @param precision 精确度
 * @param country 国家
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportPaid:(NSString *)adid
               type:(DTAdType)type
           platform:(DTAdPlatform)platform
           location:(NSString *)location
                seq:(NSString *)seq
          mediation:(DTAdMediation)mediation
        mediationId:(NSString *)mediationId
              value:(NSString *)value
          precision:(NSString *)precision
            country:(NSString *)country
         properties:(NSDictionary *)properties
           entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    propertiesCopy[PROPERTY_AD_MEDIAITON] = [NSNumber numberWithInteger:mediation];
    propertiesCopy[PROPERTY_AD_MEDIAITON_ID] = mediationId;
    propertiesCopy[PROPERTY_AD_VALUE_MICROS] = value;
    propertiesCopy[PROPERTY_AD_COUNTRY] = country;
    propertiesCopy[PROPERTY_AD_PRECISION_TYPE] = precision;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_PAID];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}

/**
 * 上报 广告关闭
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param location 广告位
 * @param seq 系列行为标识
 * @param properties 自定义属性
 * @param entrance 广告入口
 */
+ (void) reportClose:(NSString *)adid
                    type:(DTAdType)type
                platform:(DTAdPlatform)platform
                location:(NSString *)location
                     seq:(NSString *)seq
              properties:(NSDictionary *)properties
            entrance:(NSString *)entrance {
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    propertiesCopy[PROPERTY_AD_LOCATION] = location;
    propertiesCopy[PROPERTY_AD_SEQ] = seq;
    propertiesCopy[PROPERTY_AD_ENTRANCE] = entrance;
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CLOSE];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


@end
