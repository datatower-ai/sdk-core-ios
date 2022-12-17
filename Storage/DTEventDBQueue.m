
#import "DTEventDBQueue.h"
#import "DTDBManager.h"
#import "DTDBEventModel.h"
@interface DTEventDBQueue ()

@property (nonatomic,strong)DTDBManager *eventDBManager;
@property (nonatomic,strong)dispatch_queue_t operaQueue;

@end

@implementation DTEventDBQueue

- (id)initWithDBPath:(NSString *)dbPath {
    self = [super init];
    if (self) {
        self.eventDBManager = [[DTDBManager alloc] initWithDBPath:dbPath];
        self.operaQueue = dispatch_queue_create("com.ironmeta.datatower.dbqueue", NULL);
    }
    return self;
}

- (void)addEvent:(NSString *)data
        eventSyn:(NSString *)eventSyn
       createdAt:(double)createdAt
      completion:(void (^)(BOOL success))completion {
    if (self.eventDBManager == nil) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    dispatch_async(self.operaQueue, ^{
        BOOL success = [self.eventDBManager addEvent:data eventSyn:eventSyn];
        if (completion) {
            completion(success);
        }
    });
    
}

- (void)deleteEventsBySyn:(NSString *)eventSyn completion:(void (^)(BOOL success))completion {
    if (self.eventDBManager == nil) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    dispatch_async(self.operaQueue, ^{
        BOOL success = [self.eventDBManager deleteEventsBySyn:eventSyn];
        if (completion) {
            completion(success);
        }
    });
}

- (void)queryEventsCount:(NSUInteger)eventsCount completion:(void (^)(NSArray<DTDBEventModel *> * _Nonnull))completion {
    if (self.eventDBManager == nil) {
        if (completion) {
            completion([NSArray array]);
        }
        return;
    }
    
    dispatch_async(self.operaQueue, ^{
        NSArray *result = [self.eventDBManager queryEventsCount:eventsCount];
        if (completion) {
            completion(result);
        }
    });
}

- (void)queryEventCountWithCompletion:(void(^)(NSUInteger count))completion {
    if (self.eventDBManager == nil) {
        if (completion) {
            completion(0);
        }
        return;
    }
    
    dispatch_async(self.operaQueue, ^{
        NSUInteger count = [self.eventDBManager queryEventCount];
        if (completion) {
            completion(count);
        }
    });
}

@end
