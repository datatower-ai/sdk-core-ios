
#import "DTPerformance.h"
#import "DTFPSMonitor.h"
#include <mach/mach.h>
#include <malloc/malloc.h>
#import <sys/sysctl.h>
#include <mach-o/arch.h>
#import <objc/message.h>
#import "DTPresetProperties+DTDisProperties.h"
#import "DTBaseEvent.h"

#include <sys/param.h>
#include <sys/mount.h>

typedef DTPresetProperties DTAPMPresetProperty;

static const NSString *kDTPerformanceRAM  = COMMON_PROPERTY_MEMORY_USED;
static const NSString *kDTPerformanceDISK = COMMON_PROPERTY_STORAGE_USED;
static const NSString *kDTPerformanceSIM  = COMMON_PROPERTY_SIMULATOR;
static const NSString *kDTPerformanceFPS  = COMMON_PROPERTY_FPS;

#define TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY @"DTDisPresetProperties"

#define TD_PM_UNIT_KB 1024.0
#define TD_PM_UNIT_MB (1024.0 * TD_PM_UNIT_KB)
#define TD_PM_UNIT_GB (1024.0 * TD_PM_UNIT_MB)

DTFPSMonitor *fpsMonitor;

@implementation DTPerformance

+ (NSDictionary *)getPresetProperties {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    // 内存
    if (![DTAPMPresetProperty disableRAM]) {
        NSString *ram = [NSString stringWithFormat:@"%.1f/%.1f",
                         [DTPerformance dt_pm_func_getFreeMemory]*1.0/TD_PM_UNIT_GB,
                         [DTPerformance dt_pm_func_getRamSize]*1.0/TD_PM_UNIT_GB];
        if (ram && ram.length) {
            [dic setObject:ram forKey:kDTPerformanceRAM];
        }
    }
    
    // 磁盘
    if (![DTAPMPresetProperty disableDisk]) {
        NSString *disk = [NSString stringWithFormat:@"%.1f/%.1f",
                          [DTPerformance dt_get_disk_free_size]*1.0/TD_PM_UNIT_GB,
                          [DTPerformance dt_get_storage_size]*1.0/TD_PM_UNIT_GB];
        if (disk && disk.length) {
            [dic setObject:disk forKey:kDTPerformanceDISK];
        }
    }
    
    // 是否是模拟器
    if (![DTAPMPresetProperty disableSimulator]) {
        
#ifdef TARGET_OS_IPHONE
#if TARGET_IPHONE_SIMULATOR
        [dic setObject:@(YES) forKey:kDTPerformanceSIM];
#elif TARGET_OS_SIMULATOR
        [dic setObject:@(YES) forKey:kDTPerformanceSIM];
#else
        [dic setObject:@(NO) forKey:kDTPerformanceSIM];
#endif
#else
        [dic setObject:@(YES) forKey:kDTPerformanceSIM];
#endif
    }
    
    // 是否开启FPS
    if (![DTAPMPresetProperty disableFPS]) {
        if (!fpsMonitor) {
            fpsMonitor = [[DTFPSMonitor alloc] init];
            [fpsMonitor setEnable:YES];
            [dic setObject:[fpsMonitor getPFS] forKey:kDTPerformanceFPS];
        } else {
            [dic setObject:[fpsMonitor getPFS] forKey:kDTPerformanceFPS];
        }
    }
    return dic;
}

#pragma mark - memory

//返回memory空闲值，单位为Byte
+ (int64_t)dt_pm_func_getFreeMemory {
    size_t length = 0;
    int mib[6] = {0};
    
    int pagesize = 0;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0){
        return -1;
    }
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS){
        return -1;
    }
    
    int64_t freeMem = vmstat.free_count * pagesize;
    int64_t inactiveMem = vmstat.inactive_count * pagesize;
    return freeMem + inactiveMem;
}

//获取memory总大小，单位Byte
+ (int64_t)dt_pm_func_getRamSize{
    int mib[2];
    size_t length = 0;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    long ram;
    length = sizeof(ram);
    if (sysctl(mib, 2, &ram, &length, NULL, 0) < 0) {
        return -1;
    }
    return ram;
}

#pragma mark - disk

+ (NSDictionary *)dt_pm_getFileAttributeDic {
    NSError *error;
    NSDictionary *directory = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
        return nil;
    }
    return directory;
}

+ (long long)dt_get_disk_free_size {
    
    if (@available(iOS 11.0, *)) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"/"];
        NSError *error = nil;
        NSDictionary *results = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:&error];
        if (results) {
            return [results[NSURLVolumeAvailableCapacityForImportantUsageKey] unsignedLongLongValue];
        }
    } else {
        NSDictionary<NSFileAttributeKey, id> *directory = [self dt_pm_getFileAttributeDic];
        if (directory) {
            return [[directory objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
        }
    }
    
    return -1;
}

+ (long long)dt_get_storage_size {
    if (@available(iOS 11.0, *)) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"/"];
        NSError *error = nil;
        NSDictionary *results = [fileURL resourceValuesForKeys:@[NSURLVolumeTotalCapacityKey] error:&error];
        if (results) {
            return [results[NSURLVolumeTotalCapacityKey] unsignedLongLongValue];
        }
    } else {
        NSDictionary<NSFileAttributeKey, id> *directory = [self dt_pm_getFileAttributeDic];
        return directory ? ((NSNumber *)[directory objectForKey:NSFileSystemSize]).unsignedLongLongValue:-1;
    }
    
    return -1;
}

@end


@implementation DTPerformance (PresetProperty)

+ (NSArray*)disPerformancePresetProperties {
    static NSArray *arr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arr = (NSArray *)[[[NSBundle mainBundle] infoDictionary] objectForKey:TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY];
    });
    return arr;
}

+ (BOOL)needFPS {
    return ![[self disPerformancePresetProperties] containsObject:kDTPerformanceFPS];
}

+ (BOOL)needRAM {
    return ![[self disPerformancePresetProperties] containsObject:kDTPerformanceRAM];
}

+ (BOOL)needDisk {
    return ![[self disPerformancePresetProperties] containsObject:kDTPerformanceDISK];
}

+ (BOOL)needSimulator {
    return ![[self disPerformancePresetProperties] containsObject:kDTPerformanceSIM];
}


@end
