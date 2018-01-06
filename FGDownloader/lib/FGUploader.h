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

+ (instancetype)downloader;
/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调的代码块，会多次调用
 *  @param  completion      下载完成回调的代码块
 *  @param  failure         下载失败的回调代码块
 */
- (void)upload:(NSString *)host
        parama:(NSString *)p1
     fileParam:(NSString *)p2
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(ProcessHandle)process
    completion:(CompletionHandle)completion
       failure:(FailureHandle)failure;
/**取消上传*/
- (void)cancel;
/**获取上一次的上传进度*/
+ (float)lastProgress:(NSString *)url;
/**已上传的大小/文件总大小,如：12.00M/100.00M*/
+ (NSString *)filesSize:(NSString *)url;

@end

