//
//  UUPReceiver.m
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import "UUPReceiver.h"
#import "UUPItem.h"
#import "UUPHeader.h"
#import "UUPSliced.h"
#import "UUPSlicedItem.h"
#import "UUPItem+Protected.h"

@interface  UUPReceiver()
@property(nonatomic,weak) UUPItem* mItem;
@end

@implementation UUPReceiver
- (instancetype)initWith:(UUPItem*)item{
    UUPLogRetainCountO(@"UUPItem5",item)
    self = [super init];
    if(self){
        _mItem = item;
        [self completion];
    }
    return self;
}

- (void)completion{
    __weak typeof(self) weakSelf = self;
    self.completionHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        url_session_manager_create_task_safely(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error == nil) {
                if(data != nil){
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                   UUPLog(@"UUPReceiver:%@",dic);
                    
                    NSString *status = dic[@"status"];
                    status = status != nil ? status :@"FAIL";
                    NSString *code = dic[@"errorCode"];
                    int errorCode = code == nil ? -1 : [code intValue];
                    if([@"FAIL" isEqual:status]){
                        switch (errorCode) {
                            case -1001:
                                strongSelf.mItem.mError = BAD_ACCESS;
                                [strongSelf.mItem cancel];
                                break;
                                case -1:
                                strongSelf.mItem.mError = BAD_FUID;
                                [strongSelf.mItem _getFuid];
                                break;
                                case 1000:
                                strongSelf.mItem.mError = BAD_ACCESS;
                                [strongSelf.mItem cancel];
                                break;
                                case 1001:
                                strongSelf.mItem.mError = BAD_PARAMS;
                                [strongSelf.mItem cancel];
                                break;
                                case 1002:
                                strongSelf.mItem.mError = BAD_FUID;
                                [strongSelf.mItem cancel];
                                break;
                                case 1003:
                                strongSelf.mItem.mError = BAD_SLICED;
                                [strongSelf.mItem cancel];
                                break;
                            default:
                                strongSelf.mItem.mError = BAD_OTHER;
                                [strongSelf.mItem cancel];
                                break;
                        }
                    }else{
                        //如果当前上传的分片上传成功继续下一分片
                        strongSelf.mItem.mError = NONE;
                        NSDictionary *data = dic[@"data"];
                        if(data != nil){
                            NSString *current_index = data[@"current_index"] != nil ? data[@"current_index"] : @"-1";
                            NSString *save_index = data[@"save_index"] != nil ? data[@"save_index"] : @"0";
                            NSString *file_path = data[@"file_path"];
                            if([current_index isEqual:save_index] || file_path != nil){
                                strongSelf.mItem.mCurrentItem.isFinish = true;
                                strongSelf.mItem.mPProgress += strongSelf.mItem.mCurrentItem.mProgress;
                                if(file_path != nil)strongSelf.mItem.mRemoteUri = file_path;
                                [strongSelf.mItem.mSliced clean:strongSelf.mItem.mCurrentItem];
                            }else{
                                if(strongSelf.mItem.mCurrentItem!=nil){
                                    strongSelf.mItem.mCurrentItem.isSuspend = false;
                                    strongSelf.mItem.mCurrentItem.isFinish = false;
                                    strongSelf.mItem.mCurrentItem.mPProgress = 0.0;
                                }
                            }
                        }else{
                            if(strongSelf.mItem.mCurrentItem!=nil){
                                strongSelf.mItem.mCurrentItem.isSuspend = false;
                                strongSelf.mItem.mCurrentItem.isFinish = false;
                                strongSelf.mItem.mCurrentItem.mPProgress = 0.0;
                            }
                        }
                        [strongSelf.mItem _preStart];
                    }
                    
                    UUPLog(@"UUPReceiver_msg:%@",dic[@"msg"]);
                }else{
                    if(strongSelf.mItem.mCurrentItem!=nil){
                        strongSelf.mItem.mCurrentItem.isSuspend = false;
                        strongSelf.mItem.mCurrentItem.isFinish = false;
                        strongSelf.mItem.mCurrentItem.mPProgress = 0.0;
                    }
                    [strongSelf.mItem _preStart];
                }
            }else{
                if (error.code >= 400){
                    strongSelf.mItem.mError = BAD_NET;
                }else{
                    strongSelf.mItem.mError = LOW_NET;
                }
                [strongSelf.mItem cancel];
            }
        });
    };
    
    self.completionFuidHandler = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        url_session_manager_create_task_safely(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error == nil) {
                if(data != nil){
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                   UUPLog(@"UUPReceiver:%@",dic);
                    
                    NSString *status = dic[@"status"];
                    status = status != nil ? status :@"FAIL";
                    NSString *code = dic[@"errorCode"];
                    int errorCode = code == nil ? -1 : [code intValue];
                    if([@"FAIL" isEqual:status]){
                        switch (errorCode) {
                            case -1001:
                                strongSelf.mItem.mError = BAD_ACCESS;
                                break;
                                case -1:
                                strongSelf.mItem.mError = BAD_MIMETYPE;
                                break;
                                case 1000:
                                strongSelf.mItem.mError = BAD_ACCESS;
                                break;
                                case 1001:
                                strongSelf.mItem.mError = BAD_PARAMS;
                                break;
                                case 1002:
                                strongSelf.mItem.mError = BAD_FUID;
                                break;
                                case 1003:
                                strongSelf.mItem.mError = BAD_SLICED;
                                break;
                            default:
                                strongSelf.mItem.mError = BAD_OTHER;
                                break;
                        }
                        [strongSelf.mItem cancel];
                    }else{
                        NSDictionary *data = dic[@"data"];
                        if(data != nil){
                            NSString *fuid = data[@"fuid"];
//                            NSString *diff_chunk = data[@"diff_chunk"];
                            if (fuid != nil) {
                                strongSelf.mItem.mFUID = fuid;
                                strongSelf.mItem.mError = NONE;
                                [strongSelf.mItem _preStart];
                            }else{
                                strongSelf.mItem.mError = BAD_FUID;
                                [strongSelf.mItem cancel];
                            }
                        }else{
                            strongSelf.mItem.mError = BAD_OTHER;
                            [strongSelf.mItem cancel];
                        }
                    }
                    
                    UUPLog(@"UUPReceiver_msg:%@",dic[@"msg"]);
                }else{
                    if(strongSelf.mItem.mCurrentItem!=nil){
                        strongSelf.mItem.mCurrentItem.isSuspend = false;
                        strongSelf.mItem.mCurrentItem.isFinish = false;
                        strongSelf.mItem.mCurrentItem.mPProgress = 0.0;
                    }
                
                    [strongSelf.mItem _preStart];
                }
            }else{
                if (error.code >= 400){
                    strongSelf.mItem.mError = BAD_NET;
                }else{
                    strongSelf.mItem.mError = LOW_NET;
                }
                [strongSelf.mItem cancel];
            }
        });
    };
}

// 上传进度
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    // 进度 = 已发送的 / 一共需要发送的
    float process = totalBytesSent * 1.0 / totalBytesExpectedToSend;
    if(self.mItem != nil){
        self.mItem.mCurrentItem.mPProgress = process * self.mItem.mCurrentItem.mProgress;
        self.mItem.mProgress = self.mItem.mPProgress + self.mItem.mCurrentItem.mPProgress;
        [self.mItem sendMessageType:RUN_PROSESS];
    }
}

@end
