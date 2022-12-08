//
//  DataTowerConstant.h
//  Pods-demo
//
//  Created by NEO on 2022/12/5.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    DTChannelDefault = 0,
    DTChannelGooglePlay,
    DTChannelAppStore,
} DTChannel;


typedef enum  : NSUInteger {
    DTLogDegreeVerbose = 0,//最低级log
    DTLogDegreeDebug = 1,//debug级别
    DTLogDegreeNet = 2,//用于打印网络报文，可单独关闭
    DTLogDegreeInfo = 3,//重要信息级别,比如网络层输出
    DTLogDegreeWarn = 4,//警告级别
    DTLogDegreeError = 5//错误级别
}DTLogDegree;

/**
 Log 级别

 - DTLoggingLevelNone : 默认不开启
 */
typedef NS_OPTIONS(NSInteger, DTLoggingLevel) {
    /**
     默认不开启
     */
    DTLoggingLevelNone  = 0,
    
    /**
     Error Log
     */
    DTLoggingLevelError = 1 << 0,
    
    /**
     Info  Log
     */
    DTLoggingLevelInfo  = 1 << 1,
    
    /**
     Debug Log
     */
    DTLoggingLevelDebug = 1 << 2,
};


typedef NS_OPTIONS(NSInteger, DTNetworkType) {
    DTNetworkTypeNONE     = 0,
    DTNetworkType2G       = 1 << 0,
    DTNetworkType3G       = 1 << 1,
    DTNetworkType4G       = 1 << 2,
    DTNetworkTypeWIFI     = 1 << 3,
    DTNetworkType5G       = 1 << 4,
    DTNetworkTypeALL      = 0xFF,
};



/**
 证书验证模式
*/
typedef NS_OPTIONS(NSInteger, DTSSLPinningMode) {
    /**
     默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证
    */
    DTSSLPinningModeNone          = 0,
    
    /**
     校验证书的公钥
    */
    DTSSLPinningModePublicKey     = 1 << 0,
    
    /**
     校验证书的所有内容
    */
    DTSSLPinningModeCertificate   = 1 << 1
};

/**
 自定义 HTTPS 认证
*/
typedef NSURLSessionAuthChallengeDisposition (^DTURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *_Nullable session, NSURLAuthenticationChallenge *_Nullable challenge, NSURLCredential *_Nullable __autoreleasing *_Nullable credential);


