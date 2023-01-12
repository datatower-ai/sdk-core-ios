//
//  DTAppStartEvent.m
//
//
//
//

#import "DTDeviceInfo.h"
#import "DTAppStartEvent.h"
#import <CoreGraphics/CoreGraphics.h>
#import "DTPresetProperties+DTDisProperties.h"

@implementation DTAppStartEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];

    
    if (self.startReason && self.startReason.length > 0 && ![self.startReason isEqual: @"{}"]) {
        self.properties[DT_START_REASON] = self.startReason;
    }
    self.properties[DT_RESUME_FROM_BACKGROUND] = @(self.resumeFromBackground);
    
    self.properties[@"#is_first_time"] = @([[DTDeviceInfo sharedManager] isFirstOpen]);
    
    return dict;
}

@end
