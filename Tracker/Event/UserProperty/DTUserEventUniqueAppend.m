//
//  DTUserEventUniqueAppend.m
//
//
//
//

#import "DTUserEventUniqueAppend.h"

@implementation DTUserEventUniqueAppend

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserUniqueAppend;
        self.eventName = DT_EVENT_TYPE_USER_UNIQ_APPEND;
    }
    return self;
}

@end
