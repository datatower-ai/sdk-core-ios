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
