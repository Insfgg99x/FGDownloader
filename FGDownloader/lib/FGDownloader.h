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

@property(nonatomic,strong)NSURLConnection           *con;
@property(nonatomic,copy,readonly)FGProcessHandle    process;//下载进度回调(会多次调用)
@property(nonatomic,copy,readonly)FGDownloadCompletionHandle completion;
@property(nonatomic,copy,readonly)FGFailureHandle    failure;

+ (instancetype)downloader;
/**
 *  断点下载(get)
 *
 *  @param  urlString        下载的链接
 *  @param  destinationPath  下载的文件的保存路径
 *  @param  process         进度的回调，会多次调用
 *  @param  completion      下载完成的回调
 *  @param  failure         下载失败的回调
 */
- (void)downloadUrl:(NSString *)urlString
             toPath:(NSString *)destinationPath
            process:(FGProcessHandle)process
         completion:(FGDownloadCompletionHandle)completion
            failure:(FGFailureHandle)failure;

/**
 *  断点下载(post)
 *
 *  @param  host            下载的链接
 *  @param  p               post参数
 *  @param  destinationPath 下载的文件的保存路径
 *  @param  process         进度的回调，会多次调用
 *  @param  completion      下载完成的回调
 *  @param  failure         下载失败的回调
 */
- (void)downloadHost:(NSString *)host
               param:(NSString *)p
              toPath:(NSString *)destinationPath
             process:(FGProcessHandle)process
          completion:(FGDownloadCompletionHandle)completion
             failure:(FGFailureHandle)failure;
/**取消下载*/
- (void)cancel;
/**获取上一次的下载进度*/
+ (float)lastProgress:(NSString *)url;
/**已下载的大小/文件总大小,如：12.00M/100.00M*/
+ (NSString *)filesSize:(NSString *)url;

@end
