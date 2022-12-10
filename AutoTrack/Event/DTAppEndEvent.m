//
//  DTAppEndEvent.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/17.
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
