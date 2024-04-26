#import <Foundation/Foundation.h>


#import "DTCalibratedTime.h"


NS_ASSUME_NONNULL_BEGIN

@interface DTCalibratedTimeWithDTServer : DTCalibratedTime

- (instancetype)initWithNetworkQueue:(dispatch_queue_t)queue url:(NSString *)serverUrl appId:(NSString *)appId;

- (void)recalibrationWithDTServer;

- (BOOL)enable;

- (BOOL)isDeviceTimeCorrect;

@end

NS_ASSUME_NONNULL_END
