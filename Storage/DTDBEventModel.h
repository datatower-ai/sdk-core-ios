//
//  DTDBEventModel.h
//  report
//
//  Created by neo on 2022/12/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTDBEventModel : NSObject

@property (nonatomic,copy)NSDictionary *data;
@property (nonatomic,copy)NSString *eventSyn;
@property (nonatomic,assign)double createAt;

@end

NS_ASSUME_NONNULL_END
