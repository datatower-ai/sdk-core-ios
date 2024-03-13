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
       logLevel:(DTLoggingLevel)logLevel
    enableTrack:(BOOL)enableTrack {
    
    [self initSDK:appid
        serverUrl:url
          channel:DTChannelAppStore
          isDebug:debug
         logLevel:logLevel
 commonProperties:nil
      enableTrack:enableTrack];
}

+ (void)initSDK:(NSString *)appid
      serverUrl:(NSString *)url
        channel:(DTChannel)channel
        isDebug:(BOOL)debug
       logLevel:(DTLoggingLevel)logLevel
commonProperties:(NSDictionary *)commonProperties
    enableTrack:(BOOL)enableTrack; {
    
    [[DTPerfLogger shareInstance] doLog:SDKINITBEGIN time:[NSDate timeIntervalSinceReferenceDate]];
    
    DTConfig *config = [DTConfig shareInstance];
    config.appid = appid;
    config.serverUrl = url;
    config.channel = [self channelTextWithChannel:channel];
    config.enabledDebug = debug;
    config.logLevel = logLevel;
    config.commonProperties = [commonProperties copy];
    config.enableUpload = enableTrack;
    [[DTAnalyticsManager shareInstance] initializeWithConfig:config];
    
    [[DTPerfLogger shareInstance] doLog:SDKINITEND time:[NSDate timeIntervalSinceReferenceDate]];
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
