//
//  UUPItemType.h
//  BigFileMultiUpload
//
//  Created by 殷昭 on 2020/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UUPItemType) {
    VIDEO,
    AUDIO,
    IMAGE,
};

typedef NS_ENUM(NSUInteger, UUPItemErrorType) {
    NONE                    = 0,//无错误
    BAD_UPLOAD              = 103,//上传失败
    BAD_ACCESS              = 1000,//需要重新登录
    BAD_PARAMS              = 1001,//参数错误
    BAD_FUID                = 1002,//fuid不存在
    BAD_SLICED              = 1003,//分片上传失败
    BAD_MIMETYPE            = 1004,//不支持的文件类型
    BAD_OTHER               = 1005,//未知服务器错误
    OVER_RETRY              = 1101,//超过重试次数
    OVER_MAXSIZE            = 1102,//超过大小
    OVER_MAXDURATION        = 1103,//超过时长
    SLICED_FAIL             = 1004,//分片失败
    LOW_NET                 = 1105,//网络缓慢,连续10秒网速低于10KB/s
    BAD_NET                 = 1106,//网络不通
    BAD_FILE                = 1107,//文件不存在
    BAD_IO                  = 1108,//文件读写错误，需要检查系统授权
};

typedef NS_ENUM(NSUInteger, UUPItemRunType) {
    RUN_NONE       = 0,
    RUN_WAIT       = 1,
    RUN_START      = 2,
    RUN_PAUSE      = 3,
    RUN_PROSESS    = 4,
    RUN_FINISH     = 5,
    RUN_CANCEL     = 6,
    RUN_ERROR      = 7,
};


NS_ASSUME_NONNULL_END
