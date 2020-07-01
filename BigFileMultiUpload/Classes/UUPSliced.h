//
//  UUPSliced.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UUPConfig;
@class UUPItem;
@class UUPSlicedItem;
@interface UUPSliced : NSObject
@property(nonatomic,assign) long mTotalSliced;
@property(nonatomic,weak) UUPItem* mItem;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWith:(UUPItem*)item;
- (void)makeSliced;
- (UUPSlicedItem*)nextSliced;
- (void)destroy;
- (long)remainSliced;
- (BOOL)clean:(UUPSlicedItem*)item;
@end

NS_ASSUME_NONNULL_END
