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

@end
