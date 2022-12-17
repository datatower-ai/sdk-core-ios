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
@synthesize serverTime = _serverTime;

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
    NSString *networkType = [[DTReachability shareInstance] networkState];
    if (![DTReachability convertNetworkType:networkType]) {
        return;
    }
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    header[@"Content-Type"] = @"text/plain";
    
    NSString *jsonString = @"[{}]";
    NSData *postBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *dateString = [DTNetWork postRequestForResponse:self.sendURL requestBody:postBody headers:header];
    
    [DTNetWork postRequestWithURL:self.sendURL
                      requestBody:postBody
                          headers:header
                          success:^(NSHTTPURLResponse * _Nullable response,NSData * _Nullable data){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *dateString = [NSString stringWithString:[httpResponse allHeaderFields][@"Date"]];
        
        if (dateString && [dateString length] > 0){
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"EEE, dd MM yyyy HH:mm:ss ZZZ";
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
            self.serverTime = [[formatter dateFromString:dateString] timeIntervalSince1970];
            self.stopCalibrate = NO;
            DTLogDebug(@"calibration time succeed");
            [[DTAnalyticsManager shareInstance] flush];
        } else {
            self.stopCalibrate = YES;
            DTLogDebug(@"calibration time failed");
        }
        
    } failed:^(NSError * _Nonnull error) {
        DTLogError(@"calibration time failed %@", error);
        self.stopCalibrate = YES;
    }];
}

- (NSTimeInterval)serverTime {
//
//    if (_ta_ntpGroup) {
//        TDLogDebug(@"ntp _ntpGroup serverTime wait start");
//        long ret = dispatch_group_wait(_ta_ntpGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
//        TDLogDebug(@"ntp _ntpGroup serverTime wait end");
//        if (ret != 0) {
//            self.stopCalibrate = YES;
//            TDLogDebug(@"wait ntp time timeout");
//        }
//        return _serverTime;
//    } else {
//        self.stopCalibrate = YES;
//        TDLogDebug(@"ntp _ntpGroup is nil !!!");
//    }
//
    return _serverTime;
    
}



@end
