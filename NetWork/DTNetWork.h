
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTNetWork : NSObject
typedef void (^DTFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);
typedef void (^DTNetWorkSuccess)(NSHTTPURLResponse *response, NSData *data);
typedef void (^DTNetWorkFail)(NSError *error);


//同步
+ (BOOL)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

+ (NSString *)postRequestForResponse:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers;


//异步
+ (void)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   success:(DTNetWorkSuccess)success
                    failed:(DTNetWorkFail)failed;

+ (void)fetchRemoteConfig:(NSString *)serverURL handler:(DTFlushConfigBlock)handler;
@end

NS_ASSUME_NONNULL_END
