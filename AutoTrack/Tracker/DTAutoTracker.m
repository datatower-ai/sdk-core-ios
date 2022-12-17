//
//  DTAutoTracker.m
//
//
//
//
//

#import "DTAutoTracker.h"
#import "DTAnalyticsManager.h"


@interface DTAutoTracker ()
/// 采集SDK实例对象的token的映射关系：key: 唯一标识。value: 事件可以执行的次数
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *trackCounts;

@end

@implementation DTAutoTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOneTime = NO;
        _autoFlush = YES;
        _additionalCondition = YES;
        
        self.trackCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)trackWithInstanceTag:(NSString *)instanceName event:(DTAutoTrackEvent *)event params:(NSDictionary *)params {
    if ([self canTrackWithInstanceToken:instanceName]) {
        DTAnalyticsManager *instance = [DTAnalyticsManager shareInstance];
#ifdef DEBUG
        if (!instance) {
            @throw [NSException exceptionWithName:@"DataTower Exception" reason:[NSString stringWithFormat:@"check this  instance, instanceTag: %@", instanceName] userInfo:nil];
        }
#endif
        [instance autoTrackWithEvent:event properties:params];
    }
}

- (BOOL)canTrackWithInstanceToken:(NSString *)token {
    
    if (!self.additionalCondition) {
        return NO;
    }
    
    NSInteger trackCount = [self.trackCounts[token] integerValue];
    
    if (self.isOneTime && trackCount >= 1) {
        return NO;
    }
    
    if (self.isOneTime) {
        trackCount++;
        self.trackCounts[token] = @(trackCount);
    }
    
    return YES;
}

@end
