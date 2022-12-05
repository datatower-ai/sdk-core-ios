//
//  DTNetWork.m
//  Pods
//
//  Created by NEO on 2022/12/5.
//

#import "DTNetWork.h"

@implementation DTNetWork


+ (void)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   success:(DTNetWorkSuccess *)success
                    failed:(DTNetWorkFail *)failed {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = requestBody;
    for (NSString *key in [headers allKeys]) {
        NSString *value = [headers objectForKey:key];
        if (key && value) {
            [req addValue:value forHTTPHeaderField:key];
        }
    }
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:req
                                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            if (failed) {
                failed([NSError errorWithDomain:@"not NSHTTPURLResponse" code:-100 userInfo:nil]);
            }
            return;
        }
        
        if (error) {
            if (failed) {
                failed(error);
            }
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            if (success) {
                success (data);
            }
        } else {
            if (failed) {
                failed([NSError errorWithDomain:@"http code not 200" code:-200 userInfo:nil]);
            }
            return;
        }
    }];
    [dataTask resume];
}

@end
