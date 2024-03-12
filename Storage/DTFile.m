//
//  DTFile.m
//
//
//
//
//

#import "DTFile.h"
#import "DTLogging.h"


@implementation DTFile

- (instancetype)initWithAppid:(NSString*)appid
{
    self = [super init];
    if(self)
    {
        self.appid = appid;
    }
    return self;
}


- (void)archiveSuperProperties:(NSDictionary *)superProperties {
    NSString *filePath = [self superPropertiesFilePath];
    if (![self archiveObject:[superProperties copy] withFilePath:filePath]) {
        DTLogError(@"%@ unable to archive superProperties", self);
    }
}

- (NSDictionary*)unarchiveSuperProperties {
    return [self unarchiveFromFile:[self superPropertiesFilePath] asClass:[NSDictionary class]];
}

- (NSString*)unarchiveAccountId {
    return [self unarchiveFromFile:[self accountIdFilePath] asClass:[NSString class]];
}

- (void)archiveAccountId:(NSString *)accountId {
    NSString *filePath = [self accountIdFilePath];
    if (![self archiveObject:[accountId copy] withFilePath:filePath]) {
        DTLogError(@"%@ unable to archive accountID", self);
    }
}

- (void)archiveDistinctId:(NSString *)distinctId {
    NSString *filePath = [self distinctIdFilePath];
    if (![self archiveObject:[distinctId copy] withFilePath:filePath]) {
        DTLogError(@"%@ unable to archive deviceId", self);
    }
}

- (NSString *)unarchiveDistinctId {
    return [self unarchiveFromFile:[self distinctIdFilePath] asClass:[NSString class]];
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        NSError *error = nil;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:YES error:&error];
        
        if (!error)
            return NO;
        
        [data writeToFile:filePath options:0 error:&error];
        if (!error)
            return NO;
                        
    } @catch (NSException *exception) {
        DTLogError(@"Got exception: %@, reason: %@. You can only send to DT values that inherit from NSObject and implement NSCoding.", exception.name, exception.reason);
        return NO;
    }
    
    [self addSkipBackupAttributeToItemAtPath:filePath];
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        DTLogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (id)unarchiveFromFile:(NSString *)filePath asClass:(Class)class {
    id unarchivedData = nil;
    @try {
        NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:nil];
        NSError *error;
        unarchivedData = [NSKeyedUnarchiver unarchivedObjectOfClass:class fromData:data error:&error];
        if (![unarchivedData isKindOfClass:class] || !error) {
            unarchivedData = nil;
        }
    }
    @catch (NSException *exception) {
        DTLogError(@"Error unarchive in %@", filePath);
        unarchivedData = nil;
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            DTLogDebug(@"Error remove file in %@, error: %@", filePath, error);
        }
    }
    return unarchivedData;
}

- (NSString *)superPropertiesFilePath {
    return [self persistenceFilePath:@"superProperties"];
}

- (NSString *)accountIdFilePath {
    return [self persistenceFilePath:@"accountID"];
}

- (NSString *)distinctIdFilePath {
    return [self persistenceFilePath:@"distinctId"];
}

// 持久化文件
- (NSString *)persistenceFilePath:(NSString *)data{
    NSString *filename = [NSString stringWithFormat:@"datatower-%@.plist", data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}



@end
