//
//  UUPItf.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UUPItem;
@class UUPConfig;
@protocol UUPItf <NSObject>

@optional
-(void)onUPStart:(UUPItem *)item;
-(void)onUPPause:(UUPItem *)item;
-(void)onUPCancel:(UUPItem *)item;

@required
-(void)onUPFinish:(UUPItem *)item;
-(void)onUPProgress:(UUPItem *)item;
-(void)onUPError:(UUPItem *)item;

@required
-(UUPConfig*)onConfigure;

@end

NS_ASSUME_NONNULL_END
