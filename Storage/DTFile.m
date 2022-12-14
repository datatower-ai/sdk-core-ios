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

- (NSString*)unarchiveAccountID {
    return [self unarchiveFromFile:[self accountIDFilePath] asClass:[NSString class]];
}

- (void)archiveAccountID:(NSString *)accountID {
    NSString *filePath = [self accountIDFilePath];
    if (![self archiveObject:[accountID copy] withFilePath:filePath]) {
        DTLogError(@"%@ unable to archive accountID", self);
    }
}

- (void)archiveDeviceId:(NSString *)deviceId {
    NSString *filePath = [self deviceIdFilePath];
    if (![self archiveObject:[deviceId copy] withFilePath:filePath]) {
        DTLogError(@"%@ unable to archive deviceId", self);
    }
}

- (NSString *)unarchiveDeviceId {
    return [self unarchiveFromFile:[self deviceIdFilePath] asClass:[NSString class]];
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
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
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (![unarchivedData isKindOfClass:class]) {
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

- (NSString *)accountIDFilePath {
    return [self persistenceFilePath:@"accountID"];
}


- (NSString *)deviceIdFilePath {
    return [self persistenceFilePath:@"deviceId"];
}

// 持久化文件
- (NSString *)persistenceFilePath:(NSString *)data{
    NSString *filename = [NSString stringWithFormat:@"datatower-%@.plist", data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}



@end
