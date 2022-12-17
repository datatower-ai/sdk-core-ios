//
//  DataTower.m
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import "DT.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
@implementation DT

+ (void)initSDK:(NSString *)appid
               serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
             logLevel:(DTLoggingLevel)logLevel {
     
    [self initSDK:appid
        serverUrl:url
          channel:channel
          isDebug:debug
         logLevel:logLevel
        commonProperties:nil];
}

+ (void)initSDK:(NSString *)appid
               serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
       logLevel:(DTLoggingLevel)logLevel
        commonProperties:(NSDictionary *)commonProperties {
    DTConfig *config = [DTConfig shareInstance];
    config.appid = appid;
    config.enabledDebug = debug;
    config.logLevel = logLevel;
    config.serverUrl = url;
    config.commonProperties = [commonProperties copy];
    [DTAnalytics initializeWithConfig:config];
}

+ (NSString *)channelTextWithChannel:(DTChannel)channel {
    switch (channel) {
        case DTChannelDefault:
            return @"";
        case DTChannelAppStore:
            return @"app_store";
        case DTChannelGooglePlay:
            return @"gp";
        default:
            return @"";
            break;
    }
    return @"";
}

@end
