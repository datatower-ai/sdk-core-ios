//
//  DTNetWork.m
//  Pods
//
//  Created by NEO on 2022/12/5.
//

#import "DTNetWork.h"

@implementation DTNetWork


+ (BOOL)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = requestBody;
    for (NSString *key in [headers allKeys]) {
        NSString *value = [headers objectForKey:key];
        if (key && value) {
            [req addValue:value forHTTPHeaderField:key];
        }
    }
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    BOOL __block postSuccess = NO;
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:req
                                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]] && error == NULL) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            postSuccess = (httpResponse.statusCode == 200);
            dispatch_semaphore_signal(sema);
        } else {
            dispatch_semaphore_signal(sema);
        }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return postSuccess;
}




@end
