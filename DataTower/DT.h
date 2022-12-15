//
//  DataTower.h
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DT : NSObject

+ (void)initSDKWithAppID:(NSString *)appid
                 serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
             dtLogDegree:(DTLogDegree)log;
        


///for unity
+ (void)initSDKWithAppID:(NSString *)appid
               serverUrl:(NSString *)url
                 channel:(DTChannel)channel
                 isDebug:(BOOL)debug
             dtLogDegree:(DTLogDegree)log
        commonProperties:(nullable NSDictionary *)commonProperties;

@end

NS_ASSUME_NONNULL_END
