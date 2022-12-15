//
//  UserEventSetOnce.m
//
//
//
//

#import "DTUserEventSetOnce.h"

@implementation DTUserEventSetOnce

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserSetOnce;
        self.eventName = DT_EVENT_TYPE_USER_SETONCE;

    }
    return self;
}


@end
