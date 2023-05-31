//
//  PerfLogger.m
//  Pods
//
//  Created by Lilin on 2023/5/30.
//

#import "PerfLogger.h"
#import "DTLogging.h"

const NSString *SDKINITBEGIN = @"SDKINITBEGIN";
const NSString *SDKINITEND = @"SDKINITEND";
const NSString *GETDTIDBEGIN = @"GETDTIDBEGIN";
const NSString *GETDTIDEND = @"GETDTIDEND";
const NSString *GETSRVTIMEBEGIN = @"GETSRVTIMEBEGIN";
const NSString *GETSRVTIMEEND = @"GETSRVTIMEEND";
const NSString *GETCONFIGBEGIN = @"GETCONFIGBEGIN";
const NSString *GETCONFIGEND = @"GETCONFIGEND";
const NSString *TRACKBEGIN = @"TRACKBEGIN";
const NSString *WRITEEVENTTODBBEGIN = @"WRITEEVENTTODBBEGIN";
const NSString *WRITEEVENTTODBEND = @"WRITEEVENTTODBEND";
const NSString *READEVENTDATAFROMDBBEGIN = @"READEVENTDATAFROMDBBEGIN";
const NSString *READEVENTDATAFROMDBEND = @"READEVENTDATAFROMDBEND";
const NSString *UPLOADDATABEGIN = @"UPLOADDATABEGIN";
const NSString *UPLOADDATAEND = @"UPLOADDATAEND";
const NSString *DELETEDBBEGIN = @"DELETEDBBEGIN";
const NSString *DELETEDBEND = @"DELETEDBEND";
const NSString *TRACKEND = @"TRACKEND";

static const NSString *tag = @"PerfLog";

@interface PerfLogger ()

@property (nonatomic) NSMutableDictionary *timeRecord;

@end

@implementation PerfLogger

static PerfLogger *_instance = nil;

+ (PerfLogger *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[PerfLogger alloc] init];
    });
    return _instance;
}

- (void)doLog:(const NSString *)action time:(NSTimeInterval)happenTime {
    
    if ([action hasSuffix:@"END"]) {
        NSString *substr = [action substringToIndex:[action length] - 3];
        substr = [NSString stringWithFormat:@"%@BEGIN", substr];
        if (self.timeRecord[substr]) {
            NSTimeInterval start = [self.timeRecord[substr] doubleValue];
            NSTimeInterval cost = [NSDate timeIntervalSinceReferenceDate] - start;
            
            DTLogError(@"[%@] action %@ cost %d", tag, action, (int)(cost * 1000));
            
            [self.timeRecord removeObjectForKey:substr];

        } else {
            DTLogError(@"[%@] Error, no log action %@", tag, substr);
        }
    } else if ([action hasSuffix:@"BEGIN"]) {
        if (self.timeRecord[action]) {
            DTLogError(@"[%@] Error, duplicate log action %@", tag, action);
        }
        
        self.timeRecord[action] = @([NSDate timeIntervalSinceReferenceDate]);
    }
    
    DTLogError(@"[%@] %@", tag, action);
}

#pragma Getter

- (NSMutableDictionary *)timeRecord {
    if (!_timeRecord) {
        _timeRecord = [NSMutableDictionary dictionary];
    }
    
    return _timeRecord;
}

@end
