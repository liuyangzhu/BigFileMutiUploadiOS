//
//  UUPManager.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPManager.h"
#import "UUPItem.h"
#import "UUPConfig.h"
#import "UUPItf.h"
#import "UUPItem+Protected.h"
#import "UUPHeader.h"

@interface UUPManager()<UUPItf>
@property(nonatomic,assign) id<UUPItf> mDelegate;
@property(nonatomic,strong) UUPConfig* mConfig;
@property(nonatomic,strong) NSOperationQueue* mUploading;
@property(nonatomic,strong) NSMutableDictionary<UUPItem*,id<UUPItf>>* mRecords;
@end

@implementation UUPManager

+ (instancetype)shareInstance:(id<UUPItf>)delegate{
    UUPManager *instance = [UUPManager sharedSingleton];
    [instance reset:delegate];
    return instance;
}

+ (void)destory
{
    UUPManager *instance = [UUPManager sharedSingleton];
    if (instance.mRecords != nil) {
        for (UUPItem* item in instance.mRecords.allKeys) {
            if(!item.isCancelled)[item cancel];
        }
        [instance.mRecords removeAllObjects];
    }
    
    if(instance.mUploading != nil){
        for (UUPItem* item in instance.mUploading.operations) {
            if(!item.isCancelled)[item cancel];
        }
        [instance.mUploading cancelAllOperations];
    }
    instance.mConfig = nil;
    instance.mDelegate = nil;
}

- (UUPConfig*)getConfig
{
    return self.mConfig;
}

- (void)destory:(id<UUPItf>)delegate
{
    if (self.mRecords != nil) {
        NSDictionary<UUPItem*,id<UUPItf>>* mTemp = self.mRecords;
        for (UUPItem* item in mTemp.allKeys) {
            id<UUPItf> obj = [self.mRecords objectForKey:item];
            if (obj == nil || obj == self.mDelegate) {
                if(!item.isCancelled)[item cancel];
                [self.mRecords removeObjectForKey:item];
            }
        }
        mTemp = nil;
    }
}

- (void)start:(UUPItem*)item immediately:(BOOL)immediately
{
    if(item == nil) return;
    item.mDelegate = self;
    UUPLogRetainCountO(@"UUPItem01",item);
    if (immediately) {
        [item setQueuePriority:NSOperationQueuePriorityHigh];
        if (![self.mUploading.operations containsObject:item]) {
            [self.mUploading addOperation:item];
        }
    }else{
        [item setQueuePriority:NSOperationQueuePriorityNormal];
        if(![self.mUploading.operations containsObject:item]){
            [self.mUploading addOperation:item];
        }
    }
    UUPLogRetainCountO(@"UUPItem02",item);
    [self.mRecords setObject:self.mDelegate forKey:item];
    UUPLogRetainCountO(@"UUPItem03",item);
    if(self.mUploading.suspended){
        [self.mUploading setSuspended:false];
    }
}

- (void)cancel:(UUPItem*)item{
    UUPLogRetainCountO(@"UUPItem04",item)
    if (self.mUploading.operations.count > 0) {
        NSArray<UUPItem*>* mTemp = self.mUploading.operations;
        for (UUPItem* tItem in mTemp) {
            if ([tItem isEqual:item]) {
                if(!tItem.isFinished || !item.isCancelled)[tItem cancel];
            }
        }
        mTemp = nil;
    }
    UUPLogRetainCountO(@"UUPItem05",item)
    if (self.mRecords != nil) {
        NSDictionary<UUPItem*,id<UUPItf>>* mTemp = self.mRecords;
        for (UUPItem* tItem in mTemp.allKeys) {
            if ([tItem isEqual:item]) {
                [self.mRecords removeObjectForKey:tItem];
            }
        }
        mTemp = nil;
    }
    UUPLogRetainCountO(@"UUPItem06",item)
}

- (id<UUPItf>)getDelegate:(UUPItem*)item{
    id<UUPItf> delegate = nil;
    if (self.mRecords != nil) {
        NSMutableDictionary<UUPItem*,id<UUPItf>>* mTemp = [self.mRecords mutableCopy];
        for (UUPItem* tItem in mTemp.allKeys) {
            if ([tItem isEqual:item]) {
                delegate = tItem.mDelegate;
            }
        }
        [mTemp removeAllObjects];
        mTemp = nil;
    }
    return delegate;
}

///
+ (instancetype)sharedSingleton {
    static UUPManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
        _sharedInstance.mRecords = [NSMutableDictionary<UUPItem*,id<UUPItf>> dictionaryWithCapacity:0];
        _sharedInstance.mUploading = [[NSOperationQueue alloc] init];
        _sharedInstance.mUploading.suspended = true;
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [UUPManager sharedSingleton];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [UUPManager sharedSingleton];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [UUPManager sharedSingleton];
}

- (void)reset:(id<UUPItf>)delegate{
    if (self.mDelegate == nil || delegate != self.mDelegate) {
        NSDictionary<UUPItem*,id<UUPItf>>* mTemp = self.mRecords;
        for (UUPItem* item in mTemp.allKeys) {
            id<UUPItf> obj = [self.mRecords objectForKey:item];
            if (obj == nil || obj == self.mDelegate) {
                [self.mRecords removeObjectForKey:item];
                if(!item.isCancelled)[item cancel];
            }
        }
        mTemp = nil;
    }
    if (self.mDelegate != nil) self.mDelegate = nil;
    self.mDelegate = delegate;
    self.mConfig = [delegate performSelector:@selector(onConfigure)];
    self.mUploading.maxConcurrentOperationCount = self.mConfig.maxLive;
}

- (nonnull UUPConfig *)onConfigure {
    return self.mConfig;
}

- (void)onUPCancel:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
    [self cancel:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPCancel:)]) {
            [_mDelegate performSelector:@selector(onUPCancel:) withObject:item];
        }
    }
}

- (void)onUPError:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
//    [self cancel:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPError:)]) {
            [_mDelegate performSelector:@selector(onUPError:) withObject:item];
        }
    }
}

- (void)onUPFinish:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
    [self cancel:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPFinish:)]) {
            [_mDelegate performSelector:@selector(onUPFinish:) withObject:item];
        }
    }
}

- (void)onUPProgress:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPProgress:)]) {
            [_mDelegate performSelector:@selector(onUPProgress:) withObject:item];
        }
    }
}

- (void)onUPPause:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPPause:)]) {
            [_mDelegate performSelector:@selector(onUPPause:) withObject:item];
        }
    }
}

- (void)onUPStart:(nonnull UUPItem *)item {
//    id<UUPItf> delegate = [self getDelegate:item];
    if (_mDelegate!=nil) {
        if (_mDelegate != nil && [_mDelegate respondsToSelector:@selector(onUPStart:)]) {
            [_mDelegate performSelector:@selector(onUPStart:) withObject:item];
        }
    }
}


@end
