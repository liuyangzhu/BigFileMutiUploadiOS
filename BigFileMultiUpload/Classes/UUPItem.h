//
//  UUPItem.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>
#import "UUPItemType.h"

NS_ASSUME_NONNULL_BEGIN
@protocol UUPItf;
@interface UUPItem : NSOperation<NSCopying>
@property(nonatomic,strong) NSString* mRemoteUri;
@property(nonatomic,strong) NSURL* mContentUri;
@property(nonatomic,strong) NSString* mDisplayName;
@property(nonatomic,strong) NSString* mFilePath;
@property(nonatomic,strong) NSString* mThumbnailsPath;
@property(nonatomic,strong) NSString* mMimeType;
@property(nonatomic,strong) NSString* mSpeedStr;
@property(nonatomic,strong) NSString* mSizeStr;
@property(nonatomic,assign) UUPItemType mType;
@property(nonatomic,assign) UUPItemErrorType mError;
@property(nonatomic,assign) long mDuration;
@property(nonatomic,assign) long mSize;
@property(nonatomic,assign) float mProgress;
@property(nonatomic,assign) float mSpeed;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWith:(NSURL*)path type:(UUPItemType)type;
- (void)start;
- (void)pause;
- (void)resume;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
