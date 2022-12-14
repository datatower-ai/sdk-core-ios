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
    }
    return self;
}

@end
