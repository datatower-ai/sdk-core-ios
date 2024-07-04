//
//  DTSuperProperty.m
//
//
//
//

#import "DTSuperProperty.h"
#import "DTPropertyValidator.h"
#import "DTLogging.h"
#import "DTFile.h"
#import "DTBaseEvent.h"

#define ThirePartySaveKey @"ThirePartySaveKey"

@interface DTSuperProperty ()
/// 多实例的标识符
@property (nonatomic, copy) NSString *token;
/// 静态公共属性
@property (atomic, strong) NSDictionary *superProperties;
/// 动态公共属性
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
/// 文件存储
@property (nonatomic, strong) DTFile *file;
/// 是否是轻实例
@property (nonatomic, assign) BOOL isLight;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *thirdPartyProperties;

@end

@implementation DTSuperProperty

- (instancetype)initWithToken:(NSString *)token isLight:(BOOL)isLight {
    if (self = [super init]) {
        NSAssert(token.length > 0, @"token 不能为空");
        self.token = token;
        self.isLight = isLight;
        if (!isLight) {
            // 非轻实例才需要用到持久化
            self.file = [[DTFile alloc] initWithAppid:token];
            self.superProperties = [self.file unarchiveSuperProperties];
        }
        
        [self loadThirdPartyProperties];
    }
    return self;
}

/// 外部传入的
- (void)registerSuperProperties:(NSDictionary *)properties {
    properties = [properties copy];
    // 验证属性
//    properties = [DTPropertyValidator validateProperties:properties];
    if (properties.count <= 0) {
        DTLogError(@"%@ propertieDict error.", properties);
        return;
    }

    // 先获取之前设置的属性
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    // 追加新的属性，会覆盖旧的属性
    [tmp addEntriesFromDictionary:properties];
    @synchronized (self) {
        
        self.superProperties = tmp;
        
        // 持久化
        [self.file archiveSuperProperties:self.superProperties];
    }
}

- (void)unregisterSuperProperty:(NSString *)property {
    NSError *error = nil;
//    [DTPropertyValidator validateEventOrPropertyName:property withError:&error];
    if (error) {
        return;
    }

    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    tmp[property] = nil;
    @synchronized (self) {
        self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        
        [self.file archiveSuperProperties:self.superProperties];
    }
}

- (void)clearSuperProperties {
    @synchronized (self) {
        self.superProperties = @{};
        [self.file archiveSuperProperties:self.superProperties];
    }
}

- (NSDictionary *)currentSuperProperties {
    @synchronized (self) {
        NSMutableDictionary *ret = [NSMutableDictionary new];
        if (self.superProperties) {
            [ret addEntriesFromDictionary:[self.superProperties copy]];
          
        }
        if(self.thirdPartyProperties.count) {
            [ret addEntriesFromDictionary:[self.thirdPartyProperties copy]];
        }
        
        return ret;
    }
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    @synchronized (self) {
        self.dynamicSuperProperties = dynamicSuperProperties;
    }
}

/// 获取动态公共属性
- (NSDictionary *)obtainDynamicSuperProperties {
    @synchronized (self) {
        if (self.dynamicSuperProperties) {
            NSDictionary *properties = self.dynamicSuperProperties();
            // 验证属性
            NSDictionary *validProperties = [DTPropertyValidator validateProperties:[properties copy]];
            return validProperties;
        }
        return nil;
    }
}

- (void)setThirdPartyId:(NSString *)key value:(NSString *)value {
    if(value && ![value isEqualToString:@""]) {
        self.thirdPartyProperties[key] = value;
    } else {
        [self.thirdPartyProperties removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.thirdPartyProperties forKey:ThirePartySaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadThirdPartyProperties {
    self.thirdPartyProperties = [NSMutableDictionary new];
    
    NSDictionary *cache = [[NSUserDefaults standardUserDefaults] objectForKey:ThirePartySaveKey];
    if(cache) {
        [self.thirdPartyProperties addEntriesFromDictionary:cache];
    }
}

@end
