//
//  DTUserEvent.m
//
//
//  
//

#import "DTUserEvent.h"

@implementation DTUserEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeValueType = DTEventTimeValueTypeNone;
    }
    return self;
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [DTPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

//MARK: - Setter & Getter

- (void)setTime:(NSTimeInterval)time {
    [super setTime:time];
    
    self.timeValueType = DTEventTimeValueTypeNone ;
}

@end
