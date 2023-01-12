

#import "DTNetWork.h"
#import "DTLogging.h"


@implementation DTNetWork


+ (BOOL)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = requestBody;
    [req setTimeoutInterval:60.0];
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
            
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            postSuccess = NO;
            DTLogError(@"Networking error:%@", error);
            dispatch_semaphore_signal(sema);
            return;
        }

        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [urlResponse statusCode];
        if (statusCode == 200) {
            if (data) {
                NSError *error = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (jsonObject != nil && error == nil && [jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
                    NSNumber *code  = (NSNumber *)[jsonDictionary objectForKey:@"code"];
                    //code == 0 才算成功
                    if([code longValue] == 0){
                        postSuccess = YES;
                        dispatch_semaphore_signal(sema);
                        return;
                    }
                }
            }
        }
        postSuccess = NO;
        NSString *urlResponseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        DTLogDebug(@"%@", [NSString stringWithFormat:@"%@ network failed with statusCode '%ld, data '%@'.", self, (long)statusCode, urlResponseString]);
        dispatch_semaphore_signal(sema);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return postSuccess;
}


+ (void)postRequestWithURL:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers
                   success:(DTNetWorkSuccess)success
                    failed:(DTNetWorkFail)failed {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = requestBody;
    [req setTimeoutInterval:60.0];
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
                success(httpResponse, data);
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

+ (NSString *)postRequestForResponse:(NSURL *)URL
               requestBody:(NSData *)requestBody
                   headers:(nullable NSDictionary<NSString *,NSString *> *)headers {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:URL];
    req.HTTPMethod = @"POST";
    req.HTTPBody = requestBody;
    [req setTimeoutInterval:3.0];
    for (NSString *key in [headers allKeys]) {
        NSString *value = [headers objectForKey:key];
        if (key && value) {
            [req addValue:value forHTTPHeaderField:key];
        }
    }
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString * __block dataString = @"";
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:req
                                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]] && error == NULL) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            dataString = [NSString stringWithString:[httpResponse allHeaderFields][@"Date"]];
            dispatch_semaphore_signal(sema);
        } else {
            dispatch_semaphore_signal(sema);
        }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return dataString;
}

+ (void)fetchRemoteConfig:(NSString *)serverURL handler:(DTFlushConfigBlock)handler {
    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
//            DTLogError(@"Fetch remote config network failed:%@", error);
            return;
        }
        NSError *err;
        if (!data) {
            return;
        }
        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err) {
//            DTLogError(@"Fetch remote config json error:%@", err);
        } else if ([ret isKindOfClass:[NSDictionary class]]) {
//            DTLogDebug(@"Fetch remote config for %@, %@", serverURL, [ret description]);
            handler(ret, error);
        } else {
//            DTLogError(@"Fetch remote config failed");
        }
    };
//    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@", serverURL, appid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]];
    [request setHTTPMethod:@"Get"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:block];
    [task resume];
}

@end
