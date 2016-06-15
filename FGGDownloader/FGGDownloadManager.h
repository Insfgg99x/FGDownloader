//
//  FGGDownloadManager.h
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/23.
//  Copyright © 2015年 夏桂峰. All rights reserved.
//
/*
 FGGDownloadManager用法简介
 ---------------------------------------------------------------------------------------------
 基于UNSURLConnection封装的断点续传类，用于大文件下载，退出程序后，下次接着下载。
 
 -->1.在项目中导入FGGDownloadManager.h头文件；
 -->2.搭建UI时，设置显示进度的UIProgressView的进度值:[[FGGDownloadManager sharedManager] lastProgressWithUrl:url],
     这个方法的返回值是float类型的；
     设置显示文件大小/文件总大小的Label的文字：[[FGGDownloadManager sharedManager]fileSize:url]；
 
 -->3.开始或恢复下载任务的方法：[FGGDownloadManager sharedManager] downloadWithUrlString:(NSString *)urlString
     toPath:(NSString *)destinationPath
     process:(ProcessHandle)process
     completion:(CompletionHandle)completion
     failure:(FailureHandle)failure];
     
     这个方法包含三个回调代码块，分别是：
     
     1)下载过程中的回调代码块，带3个参数：下载进度参数progress，已下载文件大小sizeString，文件下载速度speedString；
     2)下载成功回调的代码块，没有参数；
     3)下载失败的回调代码块，带一个下载错误参数error。
 
 -->4.在下载出错的回调代码块中处理出错信息。在出错的回调代码块中或者暂停下载任务时，
      调用[[FGGDownloadManager sharedManager] cancelDownloadTask:url]方法取消/暂停下载任务；
 
 ==============================================================================================
 Copyright (c) 2015年 夏桂峰. All rights reserved.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FGGDownloader.h"

@interface FGGDownloadManager : NSObject

+(instancetype)shredManager;

/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调的代码块，会多次调用
 *  @param  completion      下载完成回调的代码块
 *  @param  failure         下载失败的回调代码块
 */
-(void)downloadWithUrlString:(NSString *)urlString
                      toPath:(NSString *)destinationPath
                     process:(ProcessHandle)process
                  completion:(CompletionHandle)completion
                     failure:(FailureHandle)failure;

/**
 *  暂停下载
 *
 *  @param url 下载的链接
 */
-(void)cancelDownloadTask:(NSString *)url;
/**
 *  暂停所有下载
 */
-(void)cancelAllTasks;
/**
 *  彻底移除下载任务
 *
 *  @param url  下载链接
 *  @param path 文件路径
 */
-(void)removeForUrl:(NSString *)url file:(NSString *)path;
/**
 *  获取上一次的下载进度
 *
 *  @param url 下载链接
 *
 *  @return 下载进度
 */
-(float)lastProgress:(NSString *)url;
/**
 *  获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M。
 *
 *  @param url 下载链接
 *
 *  @return 有文件大小及总大小组成的字符串
 */
-(NSString *)filesSize:(NSString *)url;


@end
