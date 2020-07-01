//
//  UUPReceiver.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UUPItem;
@interface UUPReceiver : NSObject<NSURLSessionTaskDelegate>
@property(nonatomic,copy)void (^completionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
@property(nonatomic,copy)void (^completionFuidHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWith:(UUPItem*)item;
@end

NS_ASSUME_NONNULL_END
