//
//  DTTrackTimer.h
//
//
//
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTTrackTimer : NSObject

/// 开始记录某个事件的时间
/// @param eventName 事件名字
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (void)trackEvent:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime;

/// app 进入前台，更新时间
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (void)enterForegroundWithSystemUptime:(NSTimeInterval)systemUptime;

/// app 进入后台，更新时间
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (void)enterBackgroundWithSystemUptime:(NSTimeInterval)systemUptime;

/// 获取某个事件对应的前台累计时长
/// @param eventName 事件名
/// @param isActive  app是否在前台
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (NSTimeInterval)foregroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

/// 获取某个事件对应的后台累计时长
/// @param eventName 事件名
/// @param isActive  app是否在前台
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (NSTimeInterval)backgroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

/// 删除某个事件的时间统计
/// @param eventName 事件名
- (void)removeEvent:(NSString * _Nonnull)eventName;

/// 是否包含某个事件
/// @param eventName 事件名字
- (BOOL)isExistEvent:(NSString * _Nonnull)eventName;

/// 清空所有事件的时间统计
- (void)clear;

- (void) updateTimerState:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime withState:(BOOL)state;

- (NSTimeInterval)durationOfEvent:(NSString *)eventName systemUptime:(NSTimeInterval)systemUptime;

@end

NS_ASSUME_NONNULL_END
