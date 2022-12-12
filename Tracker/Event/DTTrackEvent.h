//
//  DTTrackEvent.h
//  数据入库
//
//
//

#import "DTBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN


@interface DTTrackEvent : DTBaseEvent
/// 事件名字
@property (nonatomic, copy) NSString *eventName;
/// 累计前台时长
@property (nonatomic, assign) NSTimeInterval foregroundDuration;
/// 累计后台时长
@property (nonatomic, assign) NSTimeInterval backgroundDuration;

/// 记录事件发生时的开机时间节点。用于统计事件累计时长
@property (nonatomic, assign) NSTimeInterval systemUpTime;

/// 记录事件发生时时间节点。
@property (nonatomic, assign) NSTimeInterval timeInterval;

/// 用于记录动态公共属性，动态公共属性需要在事件发生的当前线程获取
@property (nonatomic, strong) NSDictionary *dynamicSuperProperties;

/// 用于记录静态公共属性
@property (nonatomic, strong) NSDictionary *superProperties;

- (instancetype)initWithName:(NSString *)eventName;

@end

NS_ASSUME_NONNULL_END
