//
//  UUPManager.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

@protocol UUPItf;
@class UUPItem;
@class UUPConfig;

NS_ASSUME_NONNULL_BEGIN

@interface UUPManager : NSObject
+ (instancetype)shareInstance:(id<UUPItf>)delegate;
+ (void)destory;
- (UUPConfig*)getConfig;
- (void)destory:(id<UUPItf>)delegate;
- (void)cancel:(UUPItem*)item;
- (void)start:(UUPItem*)item immediately:(BOOL)immediately;
@end

NS_ASSUME_NONNULL_END
