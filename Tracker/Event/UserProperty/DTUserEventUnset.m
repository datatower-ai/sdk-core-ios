//
//  DTUserEventUnset.m
//
//
//  
//

#import "DTUserEventUnset.h"

@implementation DTUserEventUnset

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserUnset;
        self.eventName = DT_EVENT_TYPE_USER_UNSET;

    }
    return self;
}

@end
