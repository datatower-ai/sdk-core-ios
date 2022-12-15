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

+ (void)initSDKWithAppID:(NSString *)appid
               serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
             dtLogDegree:(DTLogDegree)log {
     
    [self initSDKWithAppID:appid
                 serverUrl:url
                   channel:channel
                   isDebug:debug
               dtLogDegree:log
          commonProperties:nil];
}

+ (void)initSDKWithAppID:(NSString *)appid
               serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
             dtLogDegree:(DTLogDegree)log
        commonProperties:(NSDictionary *)commonProperties {
    DTConfig *config = [DTConfig shareInstance];
    config.appid = appid;
    config.channel = [self channelTextWithChannel:channel];
    config.enabledDebug = debug;
    config.logDegree = log;
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
