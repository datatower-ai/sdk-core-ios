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
        
    }
    return self;
}


@end
