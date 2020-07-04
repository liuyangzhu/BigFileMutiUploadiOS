//
//  UUPItem+Protected.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/30.
//

#import <Foundation/Foundation.h>
#import "UUPItem.h"

NS_ASSUME_NONNULL_BEGIN
@class UUPSlicedItem;
@class UUPReceiver;
@class UUPConfig;
@class UUPSliced;
@protocol UUPItf;
@interface UUPItem (Protected)
@property(nonatomic,assign) id<UUPItf> mDelegate;
@property(nonatomic,strong) NSString* mUploadFileName;
@property(nonatomic,strong) NSTimer* mSpeedTimer;
@property(nonatomic,strong) NSString* mFUID;
@property(nonatomic,strong) UUPConfig* mConfig;
@property(nonatomic,strong) UUPSliced* mSliced;
@property(nonatomic,strong) UUPSlicedItem* mCurrentItem;
@property(nonatomic,strong) NSURLSession* mRequest;
@property(nonatomic,strong) UUPReceiver* mReceiver;
@property(nonatomic,assign) float mPProgress;
@property(nonatomic,assign) int retryTimes;
- (void)_preStart;
- (void)_next;
- (void)_finish;
- (void)_getFuid;
- (void)sendMessageType:(UUPItemRunType)tag;
@end

NS_ASSUME_NONNULL_END
