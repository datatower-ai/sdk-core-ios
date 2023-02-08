#import "DTCalibratedTimeWithDTServer.h"
#import "DTLogging.h"
#import "DTJSONUtil.h"
#import "DTNetWork.h"
#import "DTReachability.h"
#import "DTAnalyticsManager.h"

@interface DTCalibratedTimeWithDTServer()

@property (atomic, strong) dispatch_queue_t dt_networkQueue;
@property (atomic, copy) NSURL *sendURL;

@end

@implementation DTCalibratedTimeWithDTServer
//@synthesize serverTime = _serverTime;

+ (void)initialize {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
    });
}

- (instancetype)initWithNetworkQueue:(dispatch_queue_t)queue url:(NSString *)serverUrl{
    if (self = [self init]) {
        self.dt_networkQueue = queue;
        self.sendURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/report", serverUrl]];
        self.stopCalibrate = YES;
    }
    return self;
}

- (void)recalibrationWithDTServer{
    if (!self.stopCalibrate) {
        return;
    }
    self.stopCalibrate = NO;
    NSString *networkType = [[DTReachability shareInstance] networkState];
    if (![DTReachability convertNetworkType:networkType]) {
        return;
    }
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    header[@"Content-Type"] = @"text/plain";
    
    NSString *jsonString = @"[{}]";
    NSData *postBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [DTNetWork postRequestWithURL:self.sendURL
                      requestBody:postBody
                          headers:header
                          success:^(NSHTTPURLResponse * _Nullable response,NSData * _Nullable data){
        if ([self enable]){
            return;
        }
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *dateString = [NSString stringWithString:[httpResponse allHeaderFields][@"Date"]];
        
        if (dateString && [dateString length] > 0){
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"EEE, dd MM yyyy HH:mm:ss ZZZ";
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
            self.serverTime = [[formatter dateFromString:dateString] timeIntervalSince1970];
            DTLogDebug(@"calibration time succeed");
            [[DTAnalyticsManager shareInstance] flush];
        } else {
            DTLogDebug(@"calibration time failed");
        }
        self.stopCalibrate = YES;
    } failed:^(NSError * _Nonnull error) {
        DTLogError(@"calibration time failed %@", error);
        self.stopCalibrate = YES;
    }];
}

//- (NSTimeInterval)serverTime {
//    return self.serverTime;
//}

- (BOOL)enable{
    return (self.stopCalibrate == YES) && (self.serverTime != 0) && (self.systemUptime != 0);
}

@end
