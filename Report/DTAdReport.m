

#import "DTAdReport.h"
#import "DTReportEvent.h"
#import "DTConfig.h"
@implementation DTAdReport

/**
 * 广告展示上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 */
+ (void) reportShow:(NSString *)adid
               type:(DTAdType)type
           platform:(DTAdPlatform)platform
{
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_SHOW];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 广告展示上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param properties 自定义属性
 */
+ (void) reportShow:(NSString *)adid
               type:(DTAdType)type
           platform:(DTAdPlatform)platform
         properties:(NSDictionary *)properties
{
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_SHOW];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 广告展示上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 */
+ (void) reportConversion:(NSString *)adid
                     type:(DTAdType)type
                 platform:(DTAdPlatform)platform
{
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionary];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CONVERSION];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}


/**
 * 广告展示上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param properties 自定义属性
 */
+ (void) reportConversion:(NSString *)adid
                     type:(DTAdType)type
                 platform:(DTAdPlatform)platform
               properties:(NSDictionary *)properties
{
    NSMutableDictionary *propertiesCopy = [DTPropertyValidator validateProperties:properties validator:[DTTrackEvent alloc]];
    propertiesCopy[PROPERTY_AD_ID] = adid;
    propertiesCopy[PROPERTY_AD_TYPE] = [NSNumber numberWithInteger:type];
    propertiesCopy[PROPERTY_AD_PLATFORM] = [NSNumber numberWithInteger:platform];
    DTTrackEvent *event = [[DTReportEvent alloc] initWithName:EVENT_AD_CONVERSION];
    [[DTAnalyticsManager shareInstance] asyncTrackEventObject:event properties:propertiesCopy];
}




@end
