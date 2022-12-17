//
//  DTUserEventAppend.m
//
//
//
//

#import "DTUserEventAppend.h"

@implementation DTUserEventAppend

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = DTEventTypeUserAppend;
        self.eventName = DT_EVENT_TYPE_USER_APPEND;

    }
    return self;
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [super dt_validateKey:key value:value error:error];
    if (*error) {
        return;
    }
    if (![value isKindOfClass:NSArray.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSArray. got: %@ %@. ", [value class], value];
        *error = DTPropertyError(10009, errMsg);
    }
}

@end
