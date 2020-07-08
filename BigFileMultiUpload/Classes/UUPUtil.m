//
//  UUPUtil.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UUPHeader.h"

@implementation UUPUtil
+ (NSString*)getMimeType:(NSString*)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}
+ (void)isFilesExist:(NSString*)file file:(BOOL)direct{
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:file]){
        [manager createDirectoryAtPath:file withIntermediateDirectories:direct attributes:@{NSURLIsExcludedFromBackupKey:@(YES),NSURLFileProtectionKey:NSFileProtectionNone,NSURLIsExecutableKey:@(YES),NSURLIsWritableKey:@(YES),NSURLIsReadableKey:@(YES)} error:nil];
    }
}
+ (NSString*)randomName{
    NSTimeInterval inv = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f",inv];
}
+ (NSString*)getThumbnailsPath:(NSString*)file image:(UIImage*)image{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
    return path;
}
+ (BOOL)deleteThumbnail:(NSString*)file{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:file]) {
        return true;
    }
    return [manager removeItemAtPath:file error:nil];
}
+ (NSString*)calculateSpeed:(double)mSpeed{
    NSString* mSpeedStr = @"0B/s";
    if (mSpeed > 1024 * 1024 ){
        mSpeedStr = [NSString stringWithFormat:@"%.2fMB/s",mSpeed*1.0/1024/1024];
    }else if(mSpeed > 1024){
        mSpeedStr = [NSString stringWithFormat:@"%.1fKB/s",mSpeed*1.0/1024];
    }else {
        mSpeedStr = [NSString stringWithFormat:@"%.0fB/s",mSpeed*1.0];
    }
    return mSpeedStr;
}
+ (NSString*)calculateSize:(long)mSize{
    NSString *mSizeStr = @"0B";
    if(mSize > 1024L * 1024 * 1024){
        mSizeStr = [NSString stringWithFormat:@"%.2fGB",mSize*1.0/1024/1024/1024];
    }else if (mSize > 1024L * 1024 ){
        mSizeStr = [NSString stringWithFormat:@"%.2fMB",mSize*1.0/1024/1024];
    }else if(mSize > 1024L){
        mSizeStr = [NSString stringWithFormat:@"%.1fKB",mSize*1.0/1024];
    }else {
        mSizeStr = [NSString stringWithFormat:@"%.0fB",mSize*1.0];
    }
    return mSizeStr;
}
+ (BOOL)isNetworkConnected{
    return true;
}

+ (void)removeSlicedFile{
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:SLICED_PATH]) {
        NSError *error = nil;
        [manager removeItemAtPath:SLICED_PATH error:&error];
        if(error != nil)error=nil;
    }
}

@end
