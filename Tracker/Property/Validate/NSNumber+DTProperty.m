//
//  NSNumber+TAProperty.m
//
//
//
//

#import "NSNumber+DTProperty.h"

@implementation NSNumber (TAProperty)

- (void)dt_validatePropertyValueWithError:(NSError *__autoreleasing  _Nullable *)error {
    if ([self doubleValue] > 9999999999999.999 || [self doubleValue] < -9999999999999.999) {
        NSString *errorMsg = [NSString stringWithFormat:@"The number value [%@] is invalid.", self];
        DTLogError(errorMsg);
        *error = DTPropertyError(10009, errorMsg);
    }
}

@end
