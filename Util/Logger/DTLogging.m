#import "DTLogging.h"

#import <os/log.h>
#import "DTOSLog.h"

@implementation DTLogging

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)logCallingFunction:(DTLoggingLevel)type format:(id)messageFormat, ... {
    if (messageFormat) {
        va_list formatList;
        va_start(formatList, messageFormat);
        NSString *formattedMessage = [[NSString alloc] initWithFormat:messageFormat arguments:formatList];
        va_end(formatList);
        
#ifdef __IPHONE_10_0
        if (@available(iOS 10.0, *)) {
            [DTOSLog log:NO message:formattedMessage type:type];
        }
#else
        NSLog(@"[DateTower] %@", formattedMessage);
#endif
    }
}

@end

