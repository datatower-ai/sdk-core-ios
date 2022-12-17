
#import "DTAppInitializeEvent.h"


@implementation DTAppInitializeEvent

- (NSMutableDictionary *)jsonObject {
    self.time = self.time - 0.2;
    if (self.time <0 ){
        self.systemUpTime = self.systemUpTime - 0.2;
    }
    NSMutableDictionary *dict = [super jsonObject];
    return dict;
}

@end
