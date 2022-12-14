//
//  AnalyticsConfig.m
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import "DTConfig.h"

static DTConfig * _defaultTDConfig;

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
    }
    return self;
}

+ (NSString*)version{
    return @"1.3.2";
}



@end
