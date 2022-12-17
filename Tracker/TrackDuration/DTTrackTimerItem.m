//
//  DTTrackTimerItem.m
//
//
//
//
//

#import "DTTrackTimerItem.h"

@implementation DTTrackTimerItem

-(NSString *)description {
    return [NSString stringWithFormat:@"beginTime: %lf, foregroundDuration: %lf, enterBackgroundTime: %lf, backgroundDuration: %lf", _beginTime, _foregroundDuration, _enterBackgroundTime, _backgroundDuration];;
}

- (void)setTimerState:(BOOL)isPaused upTime:(NSTimeInterval)time {
    self.isPaused = isPaused;
    if(isPaused){
        self.duration = self.duration + time - self.beginTime;
    }else {
        self.beginTime = time;
    }
}

@end
