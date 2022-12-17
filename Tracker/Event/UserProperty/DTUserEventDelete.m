//
//  DTUserEventDelete.m
//
//
//  
//

#import "DTUserEventDelete.h"

@implementation DTUserEventDelete

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserDel;
        self.eventName = DT_EVENT_TYPE_USER_DEL;

    }
    return self;
}

@end
