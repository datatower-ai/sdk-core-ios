//
//  DTDBManager.h
//  report
//
//  Created by NEO on 2022/12/5.
//

#import <Foundation/Foundation.h>
#import "DTDBEventModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DTDBManager : NSObject

/*
  初始化数据库，建议在主线程完成。
 */
- (id)initWithDBPath:(NSString *)dbPath;


/*
  增加一条数据，返回值是否操作成功
 */
- (BOOL)addEvent:(NSString *)data
         eventSyn:(NSString *)eventSyn
        createdAt:(double)createdAt;

/*
  根据eventSyn删除数据
 */

- (BOOL)deleteEventsBySyn:(NSString *)eventSyn;

/*
  从数据库读取数据
 */

- (NSArray <DTDBEventModel *> *)queryEventsCount:(NSUInteger)eventsCount;

/*
  从数据库读取数量
 */

- (NSUInteger)queryEventCount;

@end

NS_ASSUME_NONNULL_END
