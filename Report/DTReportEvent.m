
#import "DTReportEvent.h"

@implementation DTReportEvent



//MARK: - Delegate

- (void)dt_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
//    [DTPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

//MARK: - Setter & Getter

- (void)setTime:(NSTimeInterval)time {
    [super setTime:time];
    
    self.timeValueType = DTEventTimeValueTypeNone ;
}

@end
