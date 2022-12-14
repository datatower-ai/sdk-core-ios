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
    }
    return self;
}

@end
