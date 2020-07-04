//
//  UUPItem.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPItem.h"
#import "UUPSlicedItem.h"
#import "UUPReceiver.h"
#import "UUPItf.h"
#import "UUPConfig.h"
#import "UUPSliced.h"
#import <Photos/Photos.h>
#import "UUPUtil.h"
#import "UUPReceiver.h"
#import "UUPHeader.h"
#import "UUPItemProxy.h"
#import "UUPItem+Protected.h"

#define kBoundary @"----WebKitFormBoundaryXGAyMbuVkeaFc916"

@interface UUPItem()
@property(nonatomic,assign) BOOL ismStartting;
@property(nonatomic,assign) BOOL ismPaused;
@property(nonatomic,assign) BOOL ismCancel;
@property(nonatomic,assign) BOOL ismChecked;
@property(nonatomic,assign) BOOL ismFinish;
@property(nonatomic,assign) BOOL ismValidate;
@property(nonatomic,assign) BOOL ismValidateing;
@property(nonatomic,assign) float mPProgress;
@property(nonatomic,assign) float mLastProgress;
@property(nonatomic,assign) int lowTimes;
@property(nonatomic,assign) int retryTimes;
@property(nonatomic,strong) NSString* mUploadFileName;
@property(nonatomic,strong) NSTimer* mSpeedTimer;
@property(nonatomic,strong) NSString* mFUID;
@property(nonatomic,strong) UUPConfig* mConfig;
@property(nonatomic,strong) UUPSliced* mSliced;
@property(nonatomic,strong) UUPSlicedItem* mCurrentItem;
@property(nonatomic,strong) NSURLSession* mSession;
@property(nonatomic,strong) NSURLSessionTask* mTask;
@property(nonatomic,strong) UUPReceiver* mReceiver;
@property(nonatomic,assign) id<UUPItf> mDelegate;

@end

@implementation UUPItem

- (instancetype)initWith:(NSURL*)path type:(UUPItemType)type{
    self = [super init];
    if(self){
        self.mContentUri = path;
        self.mType = type;
        self.mSpeed = 0.0;
        self.mSpeedStr = @"0B/s";
        self.mProgress = 0.0;
        self.mPProgress = 0.0;
        self.mLastProgress = 0.0;
        self.ismValidate = true;
        self.mError = NONE;
        self.mConfig = [[UUPConfig alloc] init];
        if(self.mContentUri != nil){
            [self initSet];
        }else{
            _ismValidate = false;
        }
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    UUPItem *item = [[UUPItem allocWithZone:zone] init];
    item.mDelegate = self.mDelegate;
    item.mRemoteUri = self.mRemoteUri;
    item.mContentUri = self.mContentUri;
    return item;
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:UUPItem.class]) {
        if ([self.mContentUri isEqual:((UUPItem*)object).mContentUri]) {
            return true;
        }
    }
    return false;
}

- (void)start{
    while (_ismValidateing) {
       //wait
    }
    
    if (!self.ismChecked) {
        [self willChangeValueForKey:@"_ismChecked"];
        [self _check];
        [self didChangeValueForKey:@"_ismChecked"];
    }
    
    if(_ismValidate){
        
        [self willChangeValueForKey:@"isPaused"];
        _ismPaused = false;
        [self didChangeValueForKey:@"isPaused"];

        if(_mTask != nil && _mTask.state == NSURLSessionTaskStateSuspended){
            [_mTask resume];
            [self _calculateSpeed];
        }else if(self.mFUID == nil){//不作处理
            [self _getFuid];
        }else{
           [self _next];
           [self _calculateSpeed];
        }
        [self willChangeValueForKey:@"isExecuting"];
        _ismStartting = true;
        [self didChangeValueForKey:@"isExecuting"];
        
        [self sendMessageType:RUN_START];
    }else{
        [self sendMessageType:RUN_ERROR];
        [self cancel];
    }
}
- (void)pause{
    [self willChangeValueForKey:@"isPaused"];
    _ismPaused = true;
    if(_mTask != nil && _mTask.state == NSURLSessionTaskStateRunning){
        [_mTask suspend];
    }
    [self didChangeValueForKey:@"isPaused"];
    
    [self sendMessageType:RUN_PAUSE];
}
- (void)cancel{
    [self willChangeValueForKey:@"isCancelled"];
    _ismCancel = YES;
    [self didChangeValueForKey:@"isCancelled"];
    [self willChangeValueForKey:@"isFinished"];
    _ismFinish = YES;
    [self didChangeValueForKey:@"isFinished"];
    
    [self sendMessageType:RUN_ERROR];
    UUPLogRetainCount(@"UUPItem")
    [self sendMessageType:RUN_CANCEL];
    
    [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
    if(_mSpeedTimer != nil){
        [_mSpeedTimer invalidate];
        _mSpeedTimer = nil;
    }
    
    if(self.mSession != nil){
        [self.mSession finishTasksAndInvalidate];
        self.mSession = nil;
    }
}
- (void)_preStart{
    if(self.ismValidate){
       if (!_ismPaused) { //非暂停
           if([self.mSliced remainSliced]<1){
               [self _finish];
           }else{
               if(_mTask != nil && _mTask.state == NSURLSessionTaskStateSuspended){
                   [_mTask resume];
                   [self _calculateSpeed];
               }else if(self.mFUID == nil){//不作处理
                   [self _getFuid];
               }else{
                   [self _next];
                   [self _calculateSpeed];
               }
           }
       }
    }
}
- (void)_getFuid{
    __weak typeof(self) weakSelf = self;
    url_session_manager_create_task_safely(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *requestURL = strongSelf.mConfig.fuidURi;
        if(strongSelf.mFUID != nil && strongSelf.mFUID.length > 0){
            requestURL = [requestURL stringByAppendingFormat:@"?fuid=%@&total=%ld",strongSelf.mFUID,strongSelf.mSliced.mTotalSliced];
        }
        NSURL *url = [NSURL URLWithString:requestURL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0f];
        [request setHTTPMethod:@"GET"];
        [request setValue:self.mConfig.authSign forHTTPHeaderField:@"Auth-Sign"];
        [request setValue:self.mConfig.deviceToken forHTTPHeaderField:@"Device-Token"];
        strongSelf.mTask = [strongSelf.mSession dataTaskWithRequest:request completionHandler:strongSelf.mReceiver.completionFuidHandler];
        [strongSelf.mTask resume];
    });
}
- (void)_next{
    __weak typeof(self) weakSelf = self;
    url_session_manager_create_task_safely(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.mCurrentItem = [strongSelf.mSliced nextSliced];//获取下一片
        if(strongSelf.mCurrentItem != nil){//下一片不为空
            strongSelf.mCurrentItem.isSuspend = true;//挂起状态
            if(strongSelf.mConfig == nil || strongSelf.mConfig.serverURi == nil){
                strongSelf.mError = BAD_OTHER;
                return;
            }
            NSURL *url = [NSURL URLWithString:strongSelf.mConfig.serverURi];
            if(url == nil){
                strongSelf.mError = BAD_OTHER;
                return;
            }
            
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", kBoundary];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
            [request setHTTPMethod:@"POST"];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            if (strongSelf.mDelegate!=nil) {
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPStart:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPStart:) withObject:strongSelf];
                }
            }
            
            NSData *data = [strongSelf _buidData:strongSelf.mCurrentItem.mSlicedFile];
            strongSelf.mTask = [strongSelf.mSession uploadTaskWithRequest:request fromData:data completionHandler:strongSelf.mReceiver.completionHandler];
            [strongSelf.mTask resume];
        }else{
            [strongSelf _finish];
        }
    });
}

- (NSData *)_buidData:(NSString*)path{
    @autoreleasepool {
        //创建可变字符串
           NSMutableString *bodyStr = [NSMutableString string];
           
           //1 access_token
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];//\n:换行 \n:切换到行首
           [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"auth-sign\""];
           [bodyStr appendFormat:@"\r\n\r\n"];
           [bodyStr appendFormat:@"%@\r\n",self.mConfig.authSign];
           
           //2 fuid
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];//\n:换行 \n:切换到行首
           [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"fuid\""];
           [bodyStr appendFormat:@"\r\n\r\n"];
           [bodyStr appendFormat:@"%@\r\n",self.mFUID];
           
           //3 index
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];//\n:换行 \n:切换到行首
           [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"index\""];
           [bodyStr appendFormat:@"\r\n\r\n"];
           [bodyStr appendFormat:@"%ld\r\n",self.mCurrentItem.mSlicedIndex];
           
           //4 index
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];//\n:换行 \n:切换到行首
           [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"total\""];
           [bodyStr appendFormat:@"\r\n\r\n"];
           [bodyStr appendFormat:@"%ld\r\n",self.mSliced.mTotalSliced];
           
           //5 index
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];//\n:换行 \n:切换到行首
           [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"size\""];
           [bodyStr appendFormat:@"\r\n\r\n"];
           [bodyStr appendFormat:@"%ld\r\n",self.mSize];
           
           //6 file
           [bodyStr appendFormat:@"--%@\r\n",kBoundary];
           [bodyStr appendFormat:@"Content-disposition: form-data; name=\"filename\"; filename=\"%@\"",self.mDisplayName];
           [bodyStr appendFormat:@"\r\n"];
           [bodyStr appendFormat:@"Content-Type: application/octet-stream"];
           [bodyStr appendFormat:@"\r\n\r\n"];
           
           NSMutableData *bodyData = [NSMutableData data];
           
           //(1)startData
           NSData *startData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
           [bodyData appendData:startData];
           
           //(2)pic
           NSData *picdata  =[NSData dataWithContentsOfFile:path];
           [bodyData appendData:picdata];
           
           //(3)--Str--
           NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",kBoundary];
           NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
           [bodyData appendData:endData];
           
           return bodyData;
    }
}

- (void)_finish{
    [self willChangeValueForKey:@"isFinished"];
       _ismFinish = YES;
    [self didChangeValueForKey:@"isFinished"];
    if (self.mDelegate!=nil) {
        if (self.mDelegate != nil && [self.mDelegate respondsToSelector:@selector(onUPFinish:)]) {
            [self.mDelegate performSelector:@selector(onUPFinish:) withObject:self];
        }
    }
    [[NSRunLoop mainRunLoop] cancelPerformSelectorsWithTarget:self];
    if(_mSpeedTimer != nil){
        [_mSpeedTimer invalidate];
        _mSpeedTimer = nil;
    }
    
    if(self.mSession != nil){
        [self.mSession finishTasksAndInvalidate];
        self.mSession = nil;
    }
}

///
- (BOOL)isFinished{
    return _ismFinish;
}

- (BOOL)isCancelled{
    return _ismCancel;
}

- (BOOL)isPaused{
    return _ismPaused;
}

- (BOOL)isExecuting{
    return !_ismPaused;
}

- (BOOL)isReady{
    return _ismValidate;
}

///-------
- (void)initSet{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileName = [self.mContentUri lastPathComponent];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    if(![self.mContentUri isFileURL]){
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[self.mContentUri,] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        fileName = asset ? [asset valueForKey:@"filename"]: [self.mContentUri lastPathComponent];
        path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        if(![manager fileExistsAtPath:path]){
            if(asset != nil){
                self.ismValidateing = true;//检索等待
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                __weak typeof(self) weakSelf = self;
                [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                            toFile:[NSURL fileURLWithPath:path]
                                                                           options:nil
                                                                 completionHandler:^(NSError * _Nullable error) {
                                                                     __strong typeof(weakSelf)  strongSelf= weakSelf;
                                                                     if (error) {
                                                                         strongSelf.ismValidate = false;
                                                                         strongSelf.mError = BAD_IO;
                                                                     }else{
                                                                         [strongSelf initAfter:path];
                                                                     }
                                                                 }];
            }else{
                _ismValidate = false;
                self.mError = BAD_IO;
            }
        }else{
            [self initAfter:path];
        }
    }else{
       [self initAfter:path];
    }
}

- (void)initAfter:(NSString*)path{
    NSError *error = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *infoDic = [manager attributesOfItemAtPath:path error:&error];
    if(infoDic != nil && error == nil){
        self.mFilePath = path;
        self.mDisplayName = [path lastPathComponent];
        self.mMimeType = [UUPUtil getMimeType:self.mFilePath];
        self.mSize = [[infoDic valueForKey:NSFileSize] longValue];
        if (self.mType == VIDEO || self.mType == AUDIO) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:self.mContentUri];
            CMTime   time = [asset duration];
            self.mDuration = roundl(time.value * 1.0/time.timescale);
        }
    }
    
    if (self.mFilePath == nil || self.mSize < 1) {
        self.mError = BAD_FILE;
        _ismValidate = false;
    }else{
        self.mError = NONE;
        _ismValidate = true;
        self.mUploadFileName = [NSString stringWithFormat:@"%@%@",[UUPUtil randomName],self.mDisplayName];
        self.mSizeStr = [UUPUtil calculateSize:self.mSize];
    }
    self.ismValidateing = false;
}

///
- (void)_check{
    if(self.mSliced == nil){
        __weak typeof(self) weakSelf = self;
//        id obj = [UUPItemProxy proxyWithTarget:self];
        UUPLogRetainCountO(@"UUPItem1",self)
        self.mSliced = [[UUPSliced alloc] initWith:weakSelf];
        UUPLogRetainCountO(@"UUPItem3",self)
    }
    if (self.mReceiver == nil) {
        __weak typeof(self) weakSelf = self;
//        id obj = [UUPItemProxy proxyWithTarget:self];
        UUPLogRetainCountO(@"UUPItem4",self)
        self.mReceiver = [[UUPReceiver alloc] initWith:weakSelf];
        UUPLogRetainCountO(@"UUPItem6",self)
    }
    if (self.mSession == nil) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        id obj = [UUPItemProxy proxyWithTarget:self.mReceiver];
        self.mSession = [NSURLSession sessionWithConfiguration:config delegate:self.mReceiver delegateQueue:nil];
    }
    
    if(self.mSize > self.mConfig.maxSize){
        self.mError = OVER_MAXSIZE;
        _ismValidate = false;
    }else if(self.mDuration > self.mConfig.maxDuration){
        self.mError = OVER_MAXDURATION;
        _ismValidate = false;
    }else{
        if(self.ismValidate) [self.mSliced makeSliced];
    }
    
    if (self.mError != NONE) {
        if (self.mDelegate != nil && [self.mDelegate respondsToSelector:@selector(onUPError:)]) {
            [self.mDelegate performSelector:@selector(onUPError:) withObject:self];
        }
    }
    _ismChecked = true;
}

- (void)_calculateSpeed{
    if (self.mSpeedTimer == nil) {
        UUPLogRetainCount(@"UUPItem")
        id obj = [UUPItemProxy proxyWithTarget:self];
        self.mSpeedTimer = [NSTimer timerWithTimeInterval:1 target:obj selector:@selector(_timerRun:) userInfo:obj repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.mSpeedTimer forMode:NSDefaultRunLoopMode];
        UUPLogRetainCount(@"UUPItem")
    }
}

- (void)_timerRun:(NSTimer*)timer{
    
    if(timer.userInfo != nil){
        UUPItem *weakSelf = (UUPItem*)timer.userInfo;
        double tem = (weakSelf.mProgress - weakSelf.mLastProgress) * weakSelf.mSize;
        weakSelf.mSpeed = [[NSNumber numberWithDouble:tem] longValue];
        weakSelf.mSpeed = fabsl(weakSelf.mSpeed);
        weakSelf.mSpeedStr = [UUPUtil calculateSpeed:weakSelf.mSpeed];
        weakSelf.mLastProgress = weakSelf.mProgress;

        UUPLog(@"UUPItem_timerRun:%@---%f---%f",weakSelf.mSpeedStr,weakSelf.mSpeed,tem);
           
        if(weakSelf.lowTimes >= 10){
            weakSelf.mSpeedStr = [NSString stringWithFormat:@"网速缓慢 %@",weakSelf.mSpeedStr];
            if (weakSelf.lowTimes % 10 == 0 ) {
                if(weakSelf.mError != LOW_NET){
                    weakSelf.mError = LOW_NET;
                       [weakSelf sendMessageType:RUN_ERROR];
                   }
               }
           }
           
        if(weakSelf.lowTimes < 10){
            if(weakSelf.mError == LOW_NET){
                weakSelf.mError = NONE;
               }
           }
           
        if (weakSelf.mSpeed < 10) {
            weakSelf.lowTimes ++;
           }else{
               weakSelf.lowTimes = 0;
           }
           [weakSelf sendMessageType:RUN_PROSESS];
    }
}

- (void)dealloc{
    UUPLogRetainCount(@"UUPItem_dealloc")
    if(_mSpeedTimer != nil){
        [_mSpeedTimer invalidate];
        _mSpeedTimer = nil;
    }
    _mDelegate = nil;
    [self.mSession invalidateAndCancel];
    self.mSession = nil;
    if(_mSliced!=nil)[_mSliced destroy];
    _mReceiver = nil;
    _mRemoteUri = nil;
    _mContentUri = nil;
    _mDisplayName = nil;
    _mFilePath = nil;
    _mThumbnailsPath = nil;
    _mMimeType = nil;
    _mSpeedStr = nil;
    _mSizeStr = nil;
    _mUploadFileName = nil;
    _mSpeedTimer = nil;
    _mFUID = nil;
    _mConfig = nil;
    _mSliced = nil;
    _mCurrentItem = nil;
}

- (void)sendMessageType:(UUPItemRunType)tag {
    __weak typeof(self) weakSelf = self;
    url_session_manager_processing_task_safely(^{
        __strong typeof(weakSelf)  strongSelf = weakSelf;
        switch (tag) {
            case RUN_PROSESS: // progress
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPProgress:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPProgress:) withObject:strongSelf];
                }
                break;
            case RUN_START: // start
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPStart:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPStart:) withObject:strongSelf];
                }
                break;
            case RUN_FINISH: // finish
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPFinish:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPFinish:) withObject:strongSelf];
                }
                break;
            case RUN_PAUSE: // pause
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPPause:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPPause:) withObject:strongSelf];
                }
                break;
            case RUN_CANCEL: // cancel
                if (strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPCancel:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPCancel:) withObject:strongSelf];
                }
                break;
            case RUN_ERROR: // error
                if (strongSelf.mError != NONE && strongSelf.mDelegate != nil && [strongSelf.mDelegate respondsToSelector:@selector(onUPError:)]) {
                    [strongSelf.mDelegate performSelector:@selector(onUPError:) withObject:strongSelf];
                }
                break;
            default:
                break;
        }
    });
}

@end
