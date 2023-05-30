#import "DT.h"
#import "DTConfig.h"
#import "DTAnalytics.h"
#import "DTAnalyticsManager.h"
#import "PerfLogger.h"
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
    
    [[PerfLogger shareInstance] doLog:SDKINITBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    DTConfig *config = [DTConfig shareInstance];
    config.appid = appid;
    config.serverUrl = url;
    config.channel = [self channelTextWithChannel:channel];
    config.enabledDebug = debug;
    config.logLevel = logLevel;
    config.commonProperties = [commonProperties copy];
    [[DTAnalyticsManager shareInstance] initializeWithConfig:config];
    
    [[PerfLogger shareInstance] doLog:SDKINITEND time:[NSDate timeIntervalSinceReferenceDate]];
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
