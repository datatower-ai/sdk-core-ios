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

//#define EnablePerfLog

@interface DTPerfLogger ()

@property (nonatomic) NSMutableDictionary *timeRecord;

@end

@implementation DTPerfLogger

static DTPerfLogger *_instance = nil;

+ (DTPerfLogger *)shareInstance {
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _instance = [[DTPerfLogger alloc] init];
    });
    return _instance;
}

- (void)doLog:(const NSString *)action time:(NSTimeInterval)happenTime {
#ifdef EnablePerfLog
    
    if ([action hasSuffix:@"END"]) {
        NSString *substr = [action substringToIndex:[action length] - 3];
        substr = [NSString stringWithFormat:@"%@BEGIN", substr];
        if (self.timeRecord[substr]) {
            NSTimeInterval start = [self.timeRecord[substr] doubleValue];
            NSTimeInterval cost = [NSDate timeIntervalSinceReferenceDate] - start;
            
            DTLogInfo(@"[%@] action %@ cost %d", tag, action, (int)(cost * 1000));
            
            [self.timeRecord removeObjectForKey:substr];

        } else {
            DTLogInfo(@"[%@] Error, no log action %@", tag, substr);
        }
    } else if ([action hasSuffix:@"BEGIN"]) {
        if (self.timeRecord[action]) {
            DTLogInfo(@"[%@] Error, duplicate log action %@", tag, action);
        }
        
        self.timeRecord[action] = @([NSDate timeIntervalSinceReferenceDate]);
    }
    
    DTLogInfo(@"[%@] %@", tag, action);
    
#endif
}

- (void)clean {
    [self.timeRecord removeAllObjects];
}

#pragma Getter

- (NSMutableDictionary *)timeRecord {
    if (!_timeRecord) {
        _timeRecord = [NSMutableDictionary dictionary];
    }
    
    return _timeRecord;
}

@end
