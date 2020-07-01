//
//  UUPSlicedItem.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUPSlicedItem : NSObject
@property(nonatomic,strong) NSString* mSlicedFile;
@property(nonatomic,assign) long mSlicedIndex;
@property(nonatomic,assign) long mSlicedSize;
@property(nonatomic,assign) float mProgress;
@property(nonatomic,assign) float mPProgress;
@property(nonatomic,assign) BOOL isFinish;
@property(nonatomic,assign) BOOL isSuspend;
@end

NS_ASSUME_NONNULL_END
