//
//  DTAppState.m
//
//
//
//
//

#import "DTAppState.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

NSString *_td_lastKnownState;

@implementation DTAppState

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static DTAppState *appState;
    dispatch_once(&onceToken, ^{
        appState = [DTAppState new];
    });
    return appState;
}

+ (id)sharedApplication {
    
#if TARGET_OS_IOS

    if ([self runningInAppExtension]) {
      return nil;
    }
    return [[UIApplication class] performSelector:@selector(sharedApplication)];
    
#endif
    return nil;
}

+ (BOOL)runningInAppExtension {
#if TARGET_OS_IOS
    return [[[[NSBundle mainBundle] bundlePath] pathExtension] isEqualToString:@"appex"];
#endif
    return NO;
}

@end
