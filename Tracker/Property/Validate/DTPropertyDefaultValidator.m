

#import "DTPropertyDefaultValidator.h"
#import "DTPropertyValidator.h"

@implementation DTPropertyDefaultValidator

- (void)dt_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [DTPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

@end
