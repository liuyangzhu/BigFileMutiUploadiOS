//
//  UUPConfig.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPConfig.h"
#import "UUPHeader.h"

@implementation UUPConfig

+ (instancetype)sharedSingleton {
    static UUPConfig *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
        _sharedInstance.maxLive       = 3;
        _sharedInstance.maxSize       = 2L * 1024 * 1024 * 1024;
        _sharedInstance.maxDuration   = 2 * 60 * 60 ; //两个小时
        _sharedInstance.retryTimes    = 3;
        _sharedInstance.perSlicedSize = 5 * 1024 * 1024;
        _sharedInstance.authSign = @"";
        _sharedInstance.deviceToken = @"";
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [UUPConfig sharedSingleton];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [UUPConfig sharedSingleton];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [UUPConfig sharedSingleton];
}

- (void)dealloc{
    UUPLogRetainCountO(@"UUPConfig_dealloc",self);
}
@end
