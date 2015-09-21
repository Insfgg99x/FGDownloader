//
//  FGGDownloader.h
//  大文件下载(断点续传)
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//
/*
 FGGDownloader简介
----------------------------------------------------------------------------------------------------
 基于UNSURLConnection封装的断点续传类，用于大文件下载，退出程序后，下次接着下载。
 用法简介：
 -->1.在项目中导入FGGDownloader.h头文件；
 -->2.搭建UI时，设置显示进度的UIProgressView的进度值：[[FGGDownloader downloader] lastProgress];
      这个方法的返回值是float类型的；
 -->3.开始下载任务：[[FGGDownloader downloader] downloadWithUrlString:(NSString *)urlString
                                                        toPath:(NSString *)destinationPath
                                                       process:(ProcessHandle)process
                                                    completion:(CompletionHandle)completion
                                                       failure:(FailureHandle)failure];
-->4.取消/暂停下载：[[FGGDownloader downloader] cancelDownloading];
-->5.AppDelegate的程序将要退出的-(void)applicationWillTerminate:(UIApplication *)application方法中，
     取消下载：[[FGGDownloader downloader] cancelDownloading];
---------------------------------------------------------------------------------------------------
*/

#import <Foundation/Foundation.h>

typedef void (^ProcessHandle)(float progress);
typedef void (^CompletionHandle)();
typedef void (^FailureHandle)(NSError *error);

@interface FGGDownloader : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property(nonatomic,copy,readonly)ProcessHandle process;
@property(nonatomic,copy,readonly)CompletionHandle completion;
@property(nonatomic,copy,readonly)FailureHandle failure;
/**
 * 获取danli对象的类方法
 */
+(instancetype)downloader;
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
 * 取消下载
 */
-(void)cancelDownloading;
/**
 * 获取上一次的下载进度
 */
-(float)lastProgress;

@end
