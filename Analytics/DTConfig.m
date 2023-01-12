#import "DTConfig.h"
#import "DTBaseEvent.h"
#import "DTNetWork.h"
#import "DTFile.h"

#define DT_IOS_SDK_VERSION_NAME @"1.3.4-beta1"
#define DT_IOS_SDK_VERSION_TYPE @"iOS"

static DTConfig * _defaultTDConfig;

static NSString* const _configureURL = @"https://test.roiquery.com/sdk/cfg";


@implementation DTConfig

+ (DTConfig *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTDConfig = [DTConfig new];
        
    });
    return _defaultTDConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxNumEvents = 10000;
        _logLevel = DTLoggingLevelNone;
        _hasUpdateConfig = NO;
    }
    return self;
}

- (void)getRemoteConfig{
    if (self.hasUpdateConfig) {
        return;
    }
    [self initRemoteConfig];
    
    NSString *serverUrlStr = [NSString stringWithFormat:@"%@?app_id=%@&sdk_version=%@&sdk_type=%@&os=%@", _configureURL, _appid, self.sdkVersion, self.sdkType,@"iOS"];
    
    [DTNetWork fetchRemoteConfig:serverUrlStr handler:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
        if (!error && !self.hasUpdateConfig) {
            
            DTFile *file = [[DTFile alloc] initWithAppid:[self appid]];
            if ([result.allKeys containsObject:@"is_off"]) {
                BOOL isOff = [[result objectForKey:@"is_off"] boolValue];
                [file archiveSdkDisable:isOff];
                self.sdkDisable = isOff;
                DTLogDebug(@"SDK disable %@", isOff);
            }
            
            if ([result.allKeys containsObject:@"report_url"]) {
                NSString *url = [result objectForKey:@"report_url"];
                [file archiveReportUrl:url];
                if (url && url.length > 0){
                    self.reportUrl = url;
                }else {
                    self.reportUrl = self.serverUrl;
                }
            }
            [self setHasUpdateConfig:YES];
        }
    }];
}

- (void)initRemoteConfig {
    DTFile *file = [[DTFile alloc] initWithAppid:[self appid]];
    self.sdkDisable = [file unarchiveSdkDisable];
    NSString *fReportUrl = [file unarchiveReportUrl];
    if (fReportUrl && fReportUrl.length > 0){
        self.reportUrl = fReportUrl;
    }else {
        self.reportUrl = self.serverUrl;
    }
}

- (NSString*)sdkVersion{
    if (self.commonProperties) {
        //可能从 unity 侧传入 unity SDK version
        if([self.commonProperties.allKeys containsObject:COMMON_PROPERTY_SDK_VERSION]){
            NSString* version = self.commonProperties[COMMON_PROPERTY_SDK_VERSION];
            if (version && version.length > 0) {
                return version;
            }
        }
    }
    return DT_IOS_SDK_VERSION_NAME;
}

- (NSString*)sdkType{
    if (self.commonProperties) {
        //可能从 unity 侧传入 unity SDK type
        if([self.commonProperties.allKeys containsObject:COMMON_PROPERTY_SDK_TYPE]){
            NSString* type = self.commonProperties[COMMON_PROPERTY_SDK_TYPE];
            if (type && type.length > 0) {
                return type;
            }
        }
    }
    return DT_IOS_SDK_VERSION_TYPE;
}



@end
