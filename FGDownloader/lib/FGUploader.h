//
//  FGUploader.h
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGCommon.h"

/**请使用FGUploadManager*/
@interface FGUploader : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property(nonatomic,strong)NSURLConnection           *con;
@property(nonatomic,copy,readonly)FGProcessHandle    process;//下载进度回调(会多次调用)
@property(nonatomic,copy,readonly)FGUploadCompletionHandle completion;
@property(nonatomic,copy,readonly)FGFailureHandle    failure;

+ (instancetype)uploader;
/**
 *  上传
 *  @param  host        服务器地址
 *  @param  data        文件二进制数据
 *  @param  p           post请求的参数
 *  @param  fileName    文件名(如1.jpg)
 *  @param  name        服务器文件的变量名
 *  @param  mimeType    文件的mimeType(如image/jpeg)
 *  @param  process     进度的回调(会多次调用)
 *  @param  completion  成功的回调
 *  @param  failure     失败的回调
 */
- (void)upload:(NSString *)host
        parama:(NSDictionary *)p
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(FGProcessHandle)process
    completion:(FGUploadCompletionHandle)completion
       failure:(FGFailureHandle)failure;
/**取消上传*/
- (void)cancel;

@end

