#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTConfig : NSObject

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, assign) BOOL enabledDebug;
@property (nonatomic, assign) DTLoggingLevel logLevel;
@property (nonatomic, strong) NSDictionary *commonProperties;
@property (nonatomic, assign) NSInteger maxNumEvents;
@property(copy,nonatomic) NSString* sdkVersion;
@property(copy,nonatomic) NSString* sdkType;
@property(assign,nonatomic) BOOL enableUpload;

+ (DTConfig *)shareInstance;

@end

NS_ASSUME_NONNULL_END
