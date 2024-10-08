
#import "DTLogging.h"
#import "DTDBManager.h"
#import "DTASDKQualityHelper.h"
#import "DTConfig.h"
#import "DTJSONUtil.h"
#import <sqlite3.h>


//#define key_event_table_id   @"_id"
//#define key_event_table_created_at   @"created_at"
//#define key_event_table_data   @"data"
//#define key_event_syn   @"event_syn"

@implementation DTDBManager {
    sqlite3 *_database;
    NSInteger _allEventCount;
}

+ (DTDBManager *)sharedInstance{
    static DTDBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"DT-data.plist"];
        sharedInstance = [[self alloc] initWithDBPath:filepath];
        DTLogDebug(@"数据库路径：%@", filepath);
    });
    return sharedInstance;
}


- (id)initWithDBPath:(NSString *)dbPath {
    self = [super init];
    if (self) {
        if (sqlite3_initialize() != SQLITE_OK) {
            return nil;
        }
        int openCode = sqlite3_open_v2([dbPath UTF8String], &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
        if (openCode == SQLITE_OK ) {
            NSString *_sql = @"create table if not exists DTDataBase (_id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT, created_at DOUBLE,event_syn TEXT)";
            char *errorMsg;
            if (sqlite3_exec(_database, [_sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
            } else {
                NSString *errorMsgString = [[NSString alloc] initWithUTF8String:errorMsg];
                [DTASDKQualityHelper reportQualityCode:CODE_INIT_DB_ERROR errorMsg:MSG_INIT_DB_ERROR msg:errorMsgString];
                return nil;
            }
            _allEventCount = [self queryEventCount];
        } else {
            [DTASDKQualityHelper reportQualityCode:CODE_INIT_DB_ERROR errorMsg:MSG_INIT_DB_ERROR msg:[NSString stringWithFormat:@"sqlite3_open_v2 errorCode = %d",openCode]];
            return nil;
        }
    }
    return self;
}


- (BOOL)addEvent:(NSDictionary *)data eventSyn:(NSString *)eventSyn {
    NSUInteger maxCacheSize = [[DTConfig shareInstance] maxNumEvents];
    if (_allEventCount >= maxCacheSize) {
        [self deleteFirstRecords:100];
    }
    
    NSString *jsonStr = [DTJSONUtil JSONStringForObject:data];
    if (!jsonStr) {
        return NO;
    }
    NSTimeInterval createdAt = [[NSDate date] timeIntervalSince1970];

    NSString *query = @"INSERT INTO DTDataBase(data, created_at, event_syn) values(?, ?, ?)";
    sqlite3_stmt *insertStatement;
    int rc;
    BOOL success = NO;
    rc = sqlite3_prepare_v2(_database, [query UTF8String],-1, &insertStatement, nil);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(insertStatement, 1, [jsonStr UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(insertStatement, 2, createdAt);
        sqlite3_bind_text(insertStatement, 3, [eventSyn UTF8String], -1, SQLITE_TRANSIENT);
        int code = sqlite3_step(insertStatement);
        success = (code == SQLITE_DONE);
        if(success){
            _allEventCount ++;
        } else {
            [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                          errorMsg:MSG_INSERT_DB_EXCEPTION
                                               msg:[NSString stringWithUTF8String:sqlite3_errmsg(_database)]];
        }
    } else {
        [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                      errorMsg:MSG_INSERT_DB_EXCEPTION
                                           msg:[NSString stringWithUTF8String:sqlite3_errmsg(_database)]];
    }
    
    sqlite3_finalize(insertStatement);
    return success;
}

- (BOOL)deleteEventsBySyn:(NSString *)eventSyn {
    NSString *query = @"DELETE FROM DTDataBase WHERE event_syn=?";
    BOOL success = NO;
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [eventSyn UTF8String], -1, SQLITE_TRANSIENT);
        int code = sqlite3_step(stmt);
        success = (code == SQLITE_DONE);
        if(!success) {
            [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                          errorMsg:MSG_DELETE_DB_EXCEPTION
                                               msg:[NSString stringWithUTF8String:sqlite3_errmsg(_database)]];
        }
    } else {
        [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                      errorMsg:MSG_DELETE_DB_EXCEPTION
                                           msg:[NSString stringWithUTF8String:sqlite3_errmsg(_database)]];
    }
    sqlite3_finalize(stmt);
    _allEventCount = [self queryEventCount];
    return success;
}

- (BOOL)deleteEventsWithSyns:(NSArray *)syns {
    if (syns.count == 0) {
        return NO;
    }

    NSMutableArray *synsCopy = [syns mutableCopy];
    for (int i = 0; i < synsCopy.count;i++) {
        NSString *syn = synsCopy[i];
        NSString *modifySyn = [NSString stringWithFormat:@"'%@'",syn];
        synsCopy[i] = modifySyn;
    }
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM DTDataBase WHERE event_syn IN (%@);", [synsCopy componentsJoinedByString:@","]];
    sqlite3_stmt *stmt;

    if (sqlite3_prepare_v2(_database, query.UTF8String, -1, &stmt, NULL) != SQLITE_OK) {
        const char *error = sqlite3_errmsg(_database);
        DTLogError(@"Delete records Error: %s", error);
        [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                      errorMsg:MSG_DELETE_DB_EXCEPTION
                                           msg:[NSString stringWithUTF8String:error]];
        return NO;
    }
    BOOL success = YES;
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        const char *error = sqlite3_errmsg(_database);
        DTLogError(@"Delete records Error: %s", error);
        [DTASDKQualityHelper reportQualityCode:CODE_UPDATE_DB_EXCEPTION
                                      errorMsg:MSG_DELETE_DB_EXCEPTION
                                           msg:[NSString stringWithUTF8String:error]];
        success = NO;
    }
    sqlite3_finalize(stmt);
    _allEventCount = [self queryEventCount];
    return YES;
}


- (BOOL)deleteFirstRecords:(NSUInteger)recordSize{
    NSString *query = @"DELETE FROM DTDataBase WHERE _id IN (SELECT _id FROM DTDataBase ORDER BY _id ASC LIMIT ?)";
    
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, (int)recordSize);
        rc = sqlite3_step(stmt);
        if (rc != SQLITE_DONE && rc != SQLITE_OK) {
            sqlite3_finalize(stmt);
            return NO;
        }
    } else {
        sqlite3_finalize(stmt);
        return NO;
    }
    sqlite3_finalize(stmt);
    _allEventCount = [self queryEventCount];
    return YES;
}

- (NSArray <DTDBEventModel *> *)queryEventsCount:(NSUInteger)eventsCount {
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT * FROM DTDataBase ORDER BY _id ASC LIMIT ?";
    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);
    if (rc == SQLITE_OK) {
        sqlite3_bind_int(stmt, 1, (int)eventsCount);
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            char *dataChar = (char *)sqlite3_column_text(stmt, 1);
            NSString *data = [NSString stringWithUTF8String:dataChar];
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];

            double createAt = sqlite3_column_double(stmt, 2);
            char *eventSynChar = (char *)sqlite3_column_text(stmt, 3);
            NSString *eventSyn = [NSString stringWithUTF8String:eventSynChar];
            
            NSError *err;
            if (jsonData) {
                NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                          options:NSJSONReadingMutableContainers
                                                                            error:&err];
                if (!err && [eventDict isKindOfClass:[NSDictionary class]]) {
                    
                    DTDBEventModel *model = [[DTDBEventModel alloc] init];
                    model.data = [NSMutableDictionary dictionaryWithDictionary:eventDict];
                    model.createAt = createAt;
                    model.eventSyn = eventSyn;
                    [records addObject:model];
                }
            }
        }
        sqlite3_finalize(stmt);
        return records;
    } else {
        [DTASDKQualityHelper reportQualityCode:CODE_QUERY_DB_ERROR
                                      errorMsg:MSG_DEFAULT
                                           msg:[NSString stringWithUTF8String:sqlite3_errmsg(_database)]];
    }
    return nil;
}

- (NSUInteger)queryEventCount {
    NSString *query = @"select count(*) from DTDataBase";
    NSInteger count = 0;

    sqlite3_stmt *stmt = NULL;
    int rc = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, NULL);

    if (rc == SQLITE_OK) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            count = sqlite3_column_int(stmt, 0);
        }
    }
    sqlite3_finalize(stmt);
    return count;
}
@end
