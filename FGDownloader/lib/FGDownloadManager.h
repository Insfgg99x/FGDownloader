//
//  FGDownloadManager.h
//  DownloaderDemo
//
//  Created by xgf on 15/9/23.
//  Copyright © 2015年 xgf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FGDownloader.h"

/**
 * 轻量级断点续传下载管理类
 */
@interface FGDownloadManager : NSObject

+ (instancetype)shredManager;

/**
 *  断点下载(get)
 *
 *  @param  urlString        下载的链接
 *  @param  destinationPath  下载的文件的保存路径
 *  @param  process          进度的回调，会多次调用
 *  @param  completion       下载完成的回调
 *  @param  failure          下载失败的回调
 */
- (void)downloadUrl:(NSString *)urlString
                       toPath:(NSString *)destinationPath
                      process:(FGProcessHandle)process
                   completion:(FGDownloadCompletionHandle)completion
                      failure:(FGFailureHandle)failure;
/**
 *  断点下载(post)
 *
 *  @param  host             下载的链接
 *  @param  p                post参数
 *  @param  destinationPath  下载的文件的保存路径
 *  @param  process          进度的回调，会多次调用
 *  @param  completion       下载完成的回调
 *  @param  failure          下载失败的回调
 */
- (void)downloadHost:(NSString *)host
               param:(NSString *)p
             toPath:(NSString *)destinationPath
            process:(FGProcessHandle)process
         completion:(FGDownloadCompletionHandle)completion
            failure:(FGFailureHandle)failure;
/**
 *  暂停下载
 *
 *  @param url 下载的链接
 */
- (void)cancelDownloadTask:(NSString *)url;
/**
 *  暂停所有下载
 */
- (void)cancelAllTasks;
/**
 *  彻底移除下载任务
 *
 *  @param url  下载链接
 *  @param path 文件路径
 */
- (void)removeForUrl:(NSString *)url file:(NSString *)path;
/**
 *  获取上一次的下载进度
 *
 *  @param url 下载链接
 *
 *  @return 下载进度
 */
- (float)lastProgress:(NSString *)url;
/**
 *  获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M。
 *
 *  @param url 下载链接
 *
 *  @return 有文件大小及总大小组成的字符串
 */
- (NSString *)filesSize:(NSString *)url;


@end
