//
//  UUPSliced.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPSliced.h"
#import "UUPItem.h"
#import "UUPHeader.h"
#import "UUPUtil.h"
#import "UUPItem+Protected.h"
#import "UUPConfig.h"
#import "UUPSlicedItem.h"
#import "UUPHeader.h"

@interface UUPSliced()
@property(nonatomic,strong) NSMutableArray* mSlicedList;
@property(nonatomic,strong) UUPConfig* mConfig;
@property(nonatomic,strong) NSString* mPath;
@property(nonatomic,strong) NSString* mTempRoot;
@property(nonatomic,assign) long mTempLen;
@property(nonatomic,assign) long mCurrentLen;
@end
@implementation UUPSliced

- (instancetype)initWith:(UUPItem*)item{
    UUPLogRetainCountO(@"UUPItem2",item)
    self = [super init];
    if(self){
        _mItem = item;
        if (item != nil) {
            _mPath = item.mFilePath;
            NSString *file = [item.mUploadFileName stringByReplacingOccurrencesOfString:@"." withString:@"~"];
            _mTempRoot = [NSTemporaryDirectory() stringByAppendingPathComponent:file];
            [UUPUtil isFilesExist:_mTempRoot file:true];
            if (item.mConfig != nil) {
                _mConfig = item.mConfig;
            }else{
                _mConfig = [[UUPConfig alloc] init];
            }
            _mSlicedList = [[NSMutableArray alloc] initWithCapacity:0];
            _mTempLen = _mConfig.maxSliceds;
        }
    }
    return self;
}

- (void)makeSliced{
    UUPLogRetainCountO(@"UUPSliced_makeSliced_start", self);
    if (_mItem == nil) return;
    if (_mPath == nil) return;
    @autoreleasepool {
        long x = _mItem.mSize / _mConfig.perSlicedSize;
        long y = _mItem.mSize % _mConfig.perSlicedSize;
        _mTotalSliced = y>0 ? x+1 : x;
        long buffer = _mConfig.perSlicedSize;
        
        NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:_mPath];
        if(readHandle == nil){
            _mItem.mError = BAD_IO;
            return;
        }
        NSURL *file = [NSURL URLWithString:_mPath];
        if(file == nil){
            _mItem.mError = BAD_FILE;
            [readHandle closeFile];
            return;
        }
        NSString *ext = file.pathExtension;
        long remainCount = _mTotalSliced - _mCurrentLen;
        long tempCount  = _mTempLen < remainCount ? _mTempLen : remainCount;
        for (long i = 1+_mCurrentLen; i <= tempCount + _mCurrentLen; i++) {
            [readHandle seekToFileOffset:buffer * (i-1)];
            NSData *data = [readHandle readDataOfLength:buffer];
            NSString *path = [_mTempRoot stringByAppendingFormat:@"/%ld.%@",i,ext];
            UUPLog(@"UUPSliced_path:%@",path);
            [data writeToFile:path atomically:true];
            UUPSlicedItem *sItem = [[UUPSlicedItem alloc] init];
            sItem.mSlicedFile = path;
            sItem.mSlicedIndex = i;
            sItem.mSlicedSize = data.length;
            sItem.mProgress = data.length * 1.0 / self.mItem.mSize;
            [_mSlicedList addObject:sItem];
            data = nil;
            path = nil;
        }
        _mCurrentLen = _mCurrentLen + tempCount;
        [readHandle closeFile];
        readHandle = nil;
    }
    
    UUPLog(@"UUPSliced_item:%@",_mSlicedList);
    UUPLogRetainCountO(@"UUPSliced_makeSliced_end", self);
}

- (UUPSlicedItem*)nextSliced{
    UUPLogRetainCountO(@"UUPSliced_nextSliced", self);
    if(_mSlicedList == nil)return nil;
    if(_mSlicedList.count < 1)return nil;
    @synchronized (self) {
        UUPSlicedItem *returnSliced = nil;
        for (UUPSlicedItem *item in _mSlicedList) {
            if (!item.isSuspend && !item.isFinish) {
                returnSliced = item;
                break;
            }
        }
        return returnSliced;
    }
}

- (long)remainSliced{
    UUPLogRetainCountO(@"UUPSliced_remainSliced", self);
    if(_mSlicedList == nil)return 0;
    return _mSlicedList.count;
}

- (BOOL)clean:(UUPSlicedItem*)item{
    UUPLogRetainCountO(@"UUPSliced_clean", self);
    @synchronized (self) {
        if(_mItem == nil || item == nil) {
            [self destroy];
            return false;
        }
        if(item.mSlicedFile != nil){
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError *error = nil;
            [manager removeItemAtPath:item.mSlicedFile error:&error];
            if(error != nil)error=nil;
        }
        [_mSlicedList removeObject:item];
        
        if(_mSlicedList.count == 1 && _mCurrentLen < _mTotalSliced){
            [self makeSliced];
        }
        
        if(_mSlicedList.count < 1){
            
            [self destroy];
        }
        return true;
    }
}

- (void)destroy{
    _mItem = nil;
    _mConfig = nil;
    [_mSlicedList removeAllObjects];
    _mSlicedList = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    [manager removeItemAtPath:_mTempRoot error:&error];
    UUPLogRetainCountO(@"UUPSliced_destroy", self);
}

- (void)dealloc{
    _mSlicedList = nil;
    _mConfig = nil;
    _mPath = nil;
    _mTempRoot = nil;
    _mItem = nil;
    UUPLogRetainCountO(@"UUPSliced_dealloc", self);
}
@end
