//
//  DTASDKQualityHelper.m
//  DTSDK
//
//  Created by neo on 2022/12/13.
//

#import "DTASDKQualityHelper.h"
#import "DTNetwork.h"
#import "DTLogging.h"
static NSString *dt_quality_app_id            = @"app_id";
static NSString *dt_quality_instance_id       = @"instance_id";
static NSString *dt_quality_sdk_type          = @"sdk_type";
static NSString *dt_quality_sdk_version_name  = @"sdk_version_name";
static NSString *dt_quality_app_version_name  = @"app_version_name";
static NSString *dt_quality_os_version_name   = @"os_version_name";
static NSString *dt_quality_device_model      = @"device_model";
static NSString *dt_quality_error_code        = @"error_code";
static NSString *dt_quality_error_level       = @"error_level";
static NSString *dt_quality_error_message     = @"error_message";


@implementation DTASDKQualityHelper

+ (void)reportQualityCode:(DTQualityErrorCode)code
                 errorMsg:(DTQualityErrorMSG)errorMsg
                      msg:(NSString *)msg {
    NSURL *url = [NSURL URLWithString:@"https://debug.roiquery.com/debug"];
    NSDictionary *header = @{
        @"Accept-Encoding": @"gzip"
    };
    
    [DTNetWork postRequestWithURL:url
                      requestBody:[self mergeQualityDataWithLevel:DTQualityLevel_TYPE_ERROR code:code errorMsg:errorMsg msg:msg]
                          headers:header
                          success:^(NSHTTPURLResponse * _Nullable response,NSData * _Nullable data){
        DTLogInfo(@"reportQualityMessageLevelSuccess");
    } failed:^(NSError * _Nonnull error) {
        DTLogError(@"reportQualityMessageLevelFail %@", error);
    }];
}


+ (NSData *)mergeQualityDataWithLevel:(DTQualityLevel)level
                                 code:(DTQualityErrorCode)code
                             errorMsg:(DTQualityErrorMSG)errorMsg
                                  msg:(NSString *)msg {
    NSMutableDictionary *errorCommomData = [[self errorCommomData] mutableCopy];
    errorCommomData[dt_quality_error_code] = @(code);
    errorCommomData[dt_quality_error_level] = @(level);
    errorCommomData[dt_quality_error_message] = [NSString stringWithFormat:@"%@%@",[self errorMsgWithMsg:errorMsg],msg ?:@""];
    return [NSJSONSerialization dataWithJSONObject:errorCommomData
                                           options:NSJSONWritingPrettyPrinted
                                             error:NULL];;
}


+ (NSDictionary *)errorCommomData {
    NSMutableDictionary *commonData = [NSMutableDictionary dictionary];
    //TODO: 这里需要填充属性
    commonData[dt_quality_app_id] = [@"aaaa"] ?: @"";
    commonData[dt_quality_instance_id] = @"aaaa" ?: @"";
    commonData[dt_quality_sdk_type] = @"aaaa" ?: @"";
    commonData[dt_quality_sdk_version_name] = @"aaaa" ?: @"";
    commonData[dt_quality_app_version_name] = @"aaaa" ?: @"";
    commonData[dt_quality_os_version_name] = @"aaaa" ?: @"";
    commonData[dt_quality_device_model] = @"aaaa" ?: @"";
    return commonData;
}

+ (NSString *)errorMsgWithMsg:(DTQualityErrorMSG)errorMsg {

    switch (errorMsg) {
        case MSG_INIT_DB_ERROR:
            return @"can not get db instance, ";
        case MSG_INSERT_DB_NORMAL_ERROR:
            return @"insert data failed, ";
        case MSG_INSERT_DB_EXCEPTION:
            return @"throw exception when insert data, ";
        case MSG_INSERT_OLD_DATA_EXCEPTION:
            return @"throw exception when try to insert old data, ";
        case MSG_DELETE_DB_EXCEPTION:
            return @"throw exception when delete data,";
        case MSG_UPDATE_DB_EXCEPTION :
            return @"update db data failed,";
        case MSG_ILLEGAL_TIME_ERROR :
            return @"illegal time,";
        default:
            return @"default";
    }
    return @"default";
}


@end
