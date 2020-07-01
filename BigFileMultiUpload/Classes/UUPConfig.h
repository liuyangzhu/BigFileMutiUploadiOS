//
//  UUPConfig.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUPConfig : NSObject
@property(nonatomic,assign) long maxLive; //最大并发
@property(nonatomic,assign) long maxSize; //最大字节限制，单位字节B
@property(nonatomic,assign) long maxDuration; //最大时长限制，单位秒 s
@property(nonatomic,assign) long perSlicedSize; //单个分片大小，单位字节B
@property(nonatomic,assign) int retryTimes; //单个分片失败后尝试次数
@property(nonatomic,strong) NSString* fuidURi; //单个分片失败后尝试次数
@property(nonatomic,strong) NSString* serverURi; //单个分片失败后尝试次数
@property(nonatomic,strong) NSString* authSign;
@property(nonatomic,strong) NSString* deviceToken;

@end

NS_ASSUME_NONNULL_END
