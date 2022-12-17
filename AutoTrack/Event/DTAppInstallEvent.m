//
//  DTAppStartEvent.m
//
//
//
//

#import "DTAppInstallEvent.h"


@implementation DTAppInstallEvent

- (NSMutableDictionary *)jsonObject {
    self.time = self.time - 0.2;
    if (self.time <0 ){
        self.systemUpTime = self.systemUpTime - 0.2;
    }
    NSMutableDictionary *dict = [super jsonObject];
    dict[COMMON_PROPERTY_IS_FOREGROUND] = @(NO);
    return dict;
}

@end
