//
//  FGDownloader.h
//  DownloaderDemo
//
//  Created by xgf on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FGCommon.h"

/**请使用FGDownloadManager*/
@interface FGDownloader : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property(nonatomic,strong)NSURLConnection         *con;
@property(nonatomic,copy,readonly)ProcessHandle    process;//下载进度回调(会多次调用)
@property(nonatomic,copy,readonly)CompletionHandle completion;
@property(nonatomic,copy,readonly)FailureHandle    failure;

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
- (void)downloadWithUrlString:(NSString *)urlString
                       toPath:(NSString *)destinationPath
                      process:(ProcessHandle)process
                   completion:(CompletionHandle)completion
                      failure:(FailureHandle)failure;
/**取消下载*/
- (void)cancel;
/**获取上一次的下载进度*/
+ (float)lastProgress:(NSString *)url;
/**已下载的大小/文件总大小,如：12.00M/100.00M*/
+ (NSString *)filesSize:(NSString *)url;

@end
