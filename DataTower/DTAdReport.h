
#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTAdReport : NSObject

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
         properties:(NSDictionary *)properties;


/**
 * 广告展示上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 */
+ (void) reportShow:(NSString *)adid
               type:(DTAdType)type
           platform:(DTAdPlatform)platform;

/**
 * 自定义转化上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 * @param properties 自定义属性
 */
+ (void) reportConversion:(NSString *)adid
                     type:(DTAdType)type
                 platform:(DTAdPlatform)platform
               properties:(NSDictionary *)properties;


/**
 * 自定义转化上报
 *
 * @param adid 广告最小单元id
 * @param type 广告类型
 * @param platform 广告平台
 */
+ (void) reportConversion:(NSString *)adid
                     type:(DTAdType)type
                 platform:(DTAdPlatform)platform;

@end
NS_ASSUME_NONNULL_END
