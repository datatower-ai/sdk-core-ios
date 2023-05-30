//
//  PerfLogger.h
//  Pods
//
//  Created by Lilin on 2023/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSString *SDKINITBEGIN;
extern const NSString *SDKINITEND;
extern const NSString *GETDTIDBEGIN;
extern const NSString *GETDTIDEND;
extern const NSString *GETSRVTIMEBEGIN;
extern const NSString *GETSRVTIMEEND;
extern const NSString *GETCONFIGBEGIN;
extern const NSString *GETCONFIGEND;
extern const NSString *TRACKBEGIN;
extern const NSString *WRITEEVENTTODBBEGIN;
extern const NSString *WRITEEVENTTODBEND;
extern const NSString *READEVENTDATAFROMDBBEGIN;
extern const NSString *READEVENTDATAFROMDBEND;
extern const NSString *UPLOADDATABEGIN;
extern const NSString *UPLOADDATAEND;
extern const NSString *DELETEDBBEGIN;
extern const NSString *DELETEDBEND;
extern const NSString *TRACKEND;

@interface PerfLogger : NSObject

+ (PerfLogger *)shareInstance;

- (void)doLog:(const NSString *)action time:(NSTimeInterval)happenTime;

@end

NS_ASSUME_NONNULL_END
