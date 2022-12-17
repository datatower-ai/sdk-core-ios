//
//  DTUserEventSet.m
//
//
//  
//

#import "DTUserEventSet.h"

@implementation DTUserEventSet

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserSet;
        self.eventName = DT_EVENT_TYPE_USER_SET;
    }
    return self;
}

@end
