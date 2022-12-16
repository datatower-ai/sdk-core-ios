
#import "DTTrackEvent.h"
#import "DTAnalyticsManager.h"

NS_ASSUME_NONNULL_BEGIN


    //预置事件名称
static NSString * const EVENT_AD_LOAD_BEGIN       =  @"#ad_load_begin";
static NSString * const EVENT_AD_LOAD_END         =  @"#ad_load_end";
static NSString * const EVENT_AD_TO_SHOW          =  @"#ad_to_show";
static NSString * const EVENT_AD_SHOW             =  @"#ad_show";
static NSString * const EVENT_AD_SHOW_FAILED      =  @"#ad_show_failed";


static NSString * const EVENT_AD_CLOSE            =  @"#ad_close";
static NSString * const EVENT_AD_CLICK            =  @"#ad_click";
static NSString * const EVENT_AD_LEFT_APP         =  @"#ad_left_app";
static NSString * const EVENT_AD_RETURN_APP       =  @"#ad_return_app";
static NSString * const EVENT_AD_REWARDED         =  @"#ad_rewarded";
static NSString * const EVENT_AD_CONVERSION       =  @"#ad_conversion";
static NSString * const EVENT_AD_PAID             =  @"#ad_paid";


static NSString * const PROPERTY_AD_ID            = @"#ad_id";
static NSString * const PROPERTY_AD_TYPE          = @"#ad_type_code";
static NSString * const PROPERTY_AD_PLATFORM      = @"#ad_platform_code";
static NSString * const PROPERTY_AD_LOCATION      = @"#ad_location";
static NSString * const PROPERTY_AD_ENTRANCE      = @"#ad_entrance";
static NSString * const PROPERTY_AD_SEQ           = @"#ad_seq";
static NSString * const PROPERTY_AD_CONVERSION_SOURCE = @"#ad_conversion_source";
static NSString * const PROPERTY_AD_CLICK_GAP     = @"#ad_click_gap";
static NSString * const PROPERTY_AD_RETURN_GAP    = @"#ad_return_gap";

static NSString * const PROPERTY_AD_MEDIAITON      = @"#ad_mediation_code";
static NSString * const PROPERTY_AD_MEDIAITON_ID   = @"#ad_mediation_id";
static NSString * const PROPERTY_AD_VALUE_MICROS   = @"#ad_value";
static NSString * const PROPERTY_AD_CURRENCY_CODE  = @"#ad_currency";
static NSString * const PROPERTY_AD_PRECISION_TYPE = @"#ad_precision";
static NSString * const PROPERTY_AD_COUNTRY        = @"#ad_country_code";

static NSString * const PROPERTY_AD_SHOW_ERROR_CODE       = @"#error_code";
static NSString * const PROPERTY_AD_SHOW_ERROR_MESSAGE    = @"#error_message";
static NSString * const PROPERTY_LOAD_RESULT              = @"#load_result";
static NSString * const PROPERTY_LOAD_DURATION            = @"#load_duration";
static NSString * const PROPERTY_ERROR_CODE               = @"#error_code";
static NSString * const PROPERTY_ERROR_MESSAGE            = @"#error_message";

@interface DTReportEvent : DTTrackEvent

@end

NS_ASSUME_NONNULL_END
