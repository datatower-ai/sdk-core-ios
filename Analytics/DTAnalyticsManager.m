//
//  DTAnalyticsManager.m
//  report
//
//  Created by neo on 2022/12/5.
//

#import "DTAnalyticsManager.h"

@interface DTAnalyticsManager ()

@property (nonatomic, strong)DTAnalyticsConfig *config;

@end

@implementation DTAnalyticsManager

static DTAnalyticsManager *_manager = nil;
+ (DTAnalyticsManager *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _manager = [[DTAnalyticsManager alloc] init];
    });
    return _manager;
}

- (void)initializeWithConfig:(DTAnalyticsConfig *)config {
    self.config = config;
    // 日志模块
    [self initLog];
    // 网络变化监听
    [self networkStateObserver];
    // 用户属性管理器
    [self initProperties];
    //TODO: 这里需要梳理下都需要哪些能力。
    
    
}

- (void)initLog {
    
}

- (void)networkStateObserver {
    
}

//
- (void)initProperties {
    
}





@end
