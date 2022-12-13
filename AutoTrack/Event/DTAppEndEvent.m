//
//  DTAppEndEvent.m
//  
//
//
//

#import "DTAppEndEvent.h"
#import "DTPresetProperties+DTDisProperties.h"

@implementation DTAppEndEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![DTPresetProperties disableScreenName]) {
        // 如果没有页面名字，需要传空字符串
        self.properties[@"#screen_name"] = self.screenName ?: @"";
    }
    
    return dict;
}

@end
