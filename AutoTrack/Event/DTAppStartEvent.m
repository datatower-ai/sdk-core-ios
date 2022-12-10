//
//  DTAppStartEvent.m
//
//
//
//

#import "DTAppStartEvent.h"
#import <CoreGraphics/CoreGraphics.h>
#import "DTPresetProperties+DTDisProperties.h"

@implementation DTAppStartEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![DTPresetProperties disableResumeFromBackground]) {
        self.properties[@"#resume_from_background"] = @(self.resumeFromBackground);
    }
    if (![DTPresetProperties disableStartReason]) {
        self.properties[@"#start_reason"] = self.startReason;
    }
    
    return dict;
}

@end
