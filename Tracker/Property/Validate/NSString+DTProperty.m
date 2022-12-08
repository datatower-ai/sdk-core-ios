

#import "NSString+DTProperty.h"

/// 自定义属性名字长度限制
static NSInteger kTAPropertyNameMaxLength = 50;

@implementation NSString (DTProperty)

- (void)dt_validatePropertyKeyWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (self.length == 0) {
        NSString *errorMsg = @"Property key or Event name is empty";
        DTLogError(errorMsg);
        *error = DTPropertyError(10003, errorMsg);
        return;
    }

    if (self.length > kTAPropertyNameMaxLength) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property key or Event name %@'s length is longer than %ld", self, kTAPropertyNameMaxLength];
        DTLogError(errorMsg);
        *error = DTPropertyError(10006, errorMsg);
        return;
    }
    *error = nil;
}

- (void)dt_validatePropertyValueWithError:(NSError *__autoreleasing  _Nullable *)error {
    
}

@end
