//
//  UUPUtil.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UUPUtil : NSObject
+ (NSString*)getMimeType:(NSString*)file;
+ (void)isFilesExist:(NSString*)file file:(BOOL)direct;
+ (NSString*)randomName;
+ (NSString*)getThumbnailsPath:(NSString*)file image:(UIImage*)image;
+ (BOOL)deleteThumbnail:(NSString*)file;
+ (NSString*)calculateSpeed:(double)speed;
+ (NSString*)calculateSize:(long)size;
+ (BOOL)isNetworkConnected;
@end

NS_ASSUME_NONNULL_END
