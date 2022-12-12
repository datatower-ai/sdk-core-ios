//
//  TDFile.h
//
//
//
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTFile : NSObject

@property(strong,nonatomic) NSString* appid;

- (instancetype)initWithAppid:(NSString*)appid;

- (void)archiveAccountID:(nullable NSString *)accountID;
- (NSString*)unarchiveAccountID ;

- (void)archiveDeviceId:(NSString *)deviceId;
- (NSString *)unarchiveDeviceId;

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath;

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;


@end;

NS_ASSUME_NONNULL_END
