//
//  DTTrackTimer.m
//
//
//
//
//

#import "DTTrackTimer.h"
#import "DTTrackTimerItem.h"
#import "DTThreadSafeDictionary.h"

@interface DTTrackTimer ()
@property (nonatomic, strong) DTThreadSafeDictionary *events;

@end

@implementation DTTrackTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.events = [DTThreadSafeDictionary dictionary];
    }
    return self;
}

- (void)trackEvent:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return;
    }
    DTTrackTimerItem *item = [[DTTrackTimerItem alloc] init];
    item.beginTime = systemUptime ?: NSProcessInfo.processInfo.systemUptime;
    self.events[eventName] = item;
}


- (void) updateTimerState:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime withState:(BOOL)state {
    if (!eventName.length) {
        return;
    }
    DTTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return;
    }
    if (item.isPaused != state) {
        [item setTimerState:state upTime:systemUptime];
    }
}

- (NSTimeInterval)durationOfEvent:(NSString *)eventName systemUptime:(NSTimeInterval)systemUptime  {
    if (!eventName.length) {
        return 0;
    }
    DTTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return 0;
    }
    NSTimeInterval duration;
    //如果是暂停状态，
    if (item.isPaused) {
        duration = item.duration;
    }else {
        duration = systemUptime - item.beginTime + item.duration;
    }
    return [self validateDuration:duration eventName:eventName];
}

- (void)enterForegroundWithSystemUptime:(NSTimeInterval)systemUptime {
    NSArray *keys = [self.events allKeys];
    for (NSString *key in keys) {
        DTTrackTimerItem *item = self.events[key];
        // 更新事件进入前台时刻
        item.beginTime = systemUptime;
        
        // 计算后台停留的时长
        if (item.enterBackgroundTime == 0) {
            // 进入后台的时刻为0，表示是APP冷启动
            item.backgroundDuration = 0;
        } else {
            // 进入后台的时刻不为0，表示是热启动，即曾经进入过后台
            item.backgroundDuration = systemUptime - item.enterBackgroundTime + item.backgroundDuration;
        }
    }
}

- (void)enterBackgroundWithSystemUptime:(NSTimeInterval)systemUptime {
    NSArray *keys = [self.events allKeys];
    for (NSString *key in keys) {
        DTTrackTimerItem *item = self.events[key];
        // 更新每个事件进入后台时间点
        item.enterBackgroundTime = systemUptime;
        
        // 更新事件累计前台停留时长
        item.foregroundDuration = systemUptime - item.beginTime + item.foregroundDuration;
    }
}

- (NSTimeInterval)foregroundDurationOfEvent:(NSString *)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return 0;
    }
    DTTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return 0;
    }
    
    if (isActive) {
        // 如果在前台，那么需要用此次在前台的时长 + 之前累计进入前台的时间总长
        // 更新事件累计前台停留时长
        NSTimeInterval duration = systemUptime - item.beginTime + item.foregroundDuration;
        return [self validateDuration:duration eventName:eventName];
    } else {
        // 如果在后台，就直接返回累计的时长
        return [self validateDuration:item.foregroundDuration eventName:eventName];
    }
    
}

- (NSTimeInterval)backgroundDurationOfEvent:(NSString *)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return 0;
    }
    DTTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return 0;
    }
    if (isActive) {
        // 如果在前台，就直接返回累计的时长
        return [self validateDuration:item.backgroundDuration eventName:eventName];
    } else {
        // 如果在后台，那么需要用此次停留后台的时间 + 之前累计进入后台的时间总长
        // 更新事件累计后台停留时长
        NSTimeInterval duration = 0;

        // 计算后台停留的时长
        if (item.enterBackgroundTime == 0) {
            // 进入后台的时刻为0，表示是APP冷启动
            duration = 0;
        } else {
            // 进入后台的时刻不为0，表示是热启动，即曾经进入过后台
            duration = systemUptime - item.enterBackgroundTime + item.backgroundDuration;
        }
        return [self validateDuration:duration eventName:eventName];
    }
}

- (void)removeEvent:(NSString *)eventName {
    [self.events removeObjectForKey:eventName];
}

- (BOOL)isExistEvent:(NSString *)eventName {
    return self.events[eventName] != nil;
}

- (void)clear {
    [self.events removeAllObjects];
}

//MARK: - Private Methods

/// 防止时间出现错误，进行时间校验
/// @param duration 需要校验的时间
- (NSTimeInterval)validateDuration:(NSTimeInterval)duration eventName:(NSString *)eventName {
    // 异常时间，用来容错
    NSInteger max = 3600 * 24;
    if (duration >= max) {
        return max;
    }
    
    return duration;
}

@end


