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
    NSMutableDictionary *dict = [super jsonObject];

    return dict;
}

@end
