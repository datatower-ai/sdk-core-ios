//
//  DTNetWork.h
//  Pods
//
//  Created by NEO on 2022/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTNetWork : NSObject

typedef void (DTNetWorkSuccess)(NSData *data);
typedef void (DTNetWorkFail)(NSError *error);

+ (BOOL)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers;

@end

NS_ASSUME_NONNULL_END
