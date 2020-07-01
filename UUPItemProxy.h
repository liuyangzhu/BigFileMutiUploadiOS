//
//  UUPItemProxy.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUPItemProxy : NSProxy
+ (instancetype)proxyWithTarget:(id)target;
@end

NS_ASSUME_NONNULL_END
