//
//  TAPropertyValidator.m
//
//
//
//

#import "DTPropertyValidator.h"
#import "NSString+DTProperty.h"
#import "DTPropertyDefaultValidator.h"

@implementation DTPropertyValidator

/// 自定义属性名字格式验证
static NSString *const kTANormalTrackProperNameValidateRegularExpression = @"^[a-zA-Z][a-zA-Z\\d_]*$";
/// 自定义属性名字正则
static NSRegularExpression *_regexForNormalTrackValidateKey;

/// 自动采集，自定义属性名字格式验证。所有自动采集自定义属性，需要满足如下正则
static NSString *const kTAAutoTrackProperNameValidateRegularExpression = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|session_id|is_foreground|ad_id|url|element_id|element_type|element_content|element_position|background_duration|start_reason))$";
/// 自动采集，自定义属性名字正则
static NSRegularExpression *_regexForAutoTrackValidateKey;

+ (void)validateEventOrPropertyName:(NSString *)name withError:(NSError *__autoreleasing  _Nullable *)error {
    if (!name) {
        NSString *errorMsg = @"Property key or Event name is empty";
        DTLogError(errorMsg);
        *error = DTPropertyError(10003, errorMsg);
        return;
    }
    if (![name isKindOfClass:NSString.class]) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property key or Event name is not NSString: [%@]", name];
        DTLogError(errorMsg);
        *error = DTPropertyError(10007, errorMsg);
        return;
    }
    // 满足属性名字一样的验证格式
    [name dt_validatePropertyKeyWithError:error];
}

+ (void)validateBaseEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    // 验证 key
//    if (![key conformsToProtocol:@protocol(DTPropertyKeyValidating)]) {
    if (![key isKindOfClass:NSString.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"The property KEY must be NSString. got: %@ %@", [key class], key];
        DTLogError(errMsg);
        *error = DTPropertyError(10001, errMsg);
        return;
    }
    [(id <DTPropertyKeyValidating>)key dt_validatePropertyKeyWithError:error];
    if (*error) {
        return;
    }

    // 验证 value
//    if (![value conformsToProtocol:@protocol(DTPropertyValueValidating)]) {
    if (![value isKindOfClass:NSString.class]
        && ![value isKindOfClass:NSNumber.class]
        && ![value isKindOfClass:NSDate.class]
        && ![value isKindOfClass:NSDictionary.class]
        && ![value isKindOfClass:NSArray.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSString, NSNumber, NSDate, NSDictionary or NSArray. got: %@ %@. ", [value class], value];
        DTLogError(errMsg);
        *error = DTPropertyError(10002, errMsg);
        return;
    }
    [(id <DTPropertyValueValidating>)value dt_validatePropertyValueWithError:error];
}

+ (void)validateNormalTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForNormalTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTANormalTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForNormalTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        DTLogError(errorMsg);
        *error = DTPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForNormalTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        DTLogError(errorMsg);
        *error = DTPropertyError(10005, errorMsg);
        return;
    }
}

+ (void)validateAutoTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error {
    [self validateBaseEventPropertyKey:key value:value error:error];
    if (*error) {
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regexForAutoTrackValidateKey = [NSRegularExpression regularExpressionWithPattern:kTAAutoTrackProperNameValidateRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    });
    if (!_regexForAutoTrackValidateKey) {
        NSString *errorMsg = @"Property Key validate regular expression init failed";
        DTLogError(errorMsg);
        *error = DTPropertyError(10004, errorMsg);
        return;
    }
    NSRange range = NSMakeRange(0, key.length);
    if ([_regexForAutoTrackValidateKey numberOfMatchesInString:key options:0 range:range] < 1) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property Key or Event name: [%@] is invalid.", key];
        DTLogError(errorMsg);
        *error = DTPropertyError(10005, errorMsg);
        return;
    }
}

/// 验证属性
/// @param properties 属性
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties {
    return [self validateProperties:properties validator:[[DTPropertyDefaultValidator alloc] init]];
}

/// 验证属性，提供一个自定义的验证器
/// @param properties 属性
/// @param validator 验证器
+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties validator:(id<DTEventPropertyValidating>)validator {
    if (![properties isKindOfClass:[NSDictionary class]] || ![validator conformsToProtocol:@protocol(DTEventPropertyValidating)]) {
        return nil;
    }
    
    NSMutableDictionary *propertiesCopy = [NSMutableDictionary dictionaryWithDictionary:properties];
    NSMutableArray *invalidKeys = [NSMutableArray arrayWithCapacity:0];
    
    for (id key in propertiesCopy.allKeys) {
        NSError *error = nil;
        id value = propertiesCopy[key];
        
        // 验证key-value
        [validator dt_validateKey:key value:value error:&error];
        
        if (error) {
            [invalidKeys addObject:key];
        }
    }
    if(invalidKeys.count > 0){
        [propertiesCopy removeObjectsForKeys:invalidKeys];
    }
    return propertiesCopy;
}

@end
