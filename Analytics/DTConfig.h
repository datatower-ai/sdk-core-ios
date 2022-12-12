//
//  AnalyticsConfig.h
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface DTConfig : NSObject

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *channel;
@property (nonatomic, assign) BOOL enabledDebug;
@property (nonatomic, assign) DTLogDegree logDegree;
@property (nonatomic, strong) NSDictionary *commonProperties;
@property (nonatomic, assign) NSInteger maxNumEvents;
@property(copy,nonatomic) NSString* version;


+ (DTConfig *)shareInstance;

+ (NSString*)version;


@end

NS_ASSUME_NONNULL_END
