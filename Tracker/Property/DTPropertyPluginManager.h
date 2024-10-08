//
//  TAPropertyPluginManager.h
//
//
//
//

#import <Foundation/Foundation.h>
#import "DTBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DTPropertyPluginCompletion)(NSDictionary<NSString *, id> *properties);

@protocol DTPropertyPluginProtocol <NSObject>

/// 当前插件采集的属性值
- (NSDictionary<NSString *, id> *)properties;

@optional

/// 开始属性采集
///
/// 该方法在触发事件的队列中执行
- (void)start;

/// 当前插件支持的事件类型
///
/// 如果不实现则使用默认值 TAPropertyPluginEventTypeTrack
- (DTEventType)eventTypeFilter;

/// 设置属性插件回调
///
/// 如果该插件获取属性值是异步操作，那么需要实现这个方法。在异步操作结束时，调用当前回调。
///
/// @param completion 回调
- (void)asyncGetPropertyCompletion:(DTPropertyPluginCompletion)completion;

@end


@interface DTPropertyPluginManager : NSObject

/// 注册属性插件
///
/// 需要在触发事件的队列中调用
///
- (void)registerPropertyPlugin:(id<DTPropertyPluginProtocol>)plugin;

/// 获取目标插件类对应的属性值
///
/// @param classes 插件类
- (NSMutableDictionary<NSString *, id> *)currentPropertiesForPluginClasses:(NSArray<Class> *)classes;

/// 通过事件类型获取当前类型对应的属性
///
/// 需要在触发事件的队列中调用
///
- (NSMutableDictionary<NSString *, id> *)propertiesWithEventType:(DTEventType)type;

@end

NS_ASSUME_NONNULL_END
