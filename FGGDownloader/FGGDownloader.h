//
//  FGGDownloader.h
//  大文件下载(断点续传)
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//
/*
 使用的时候导入FGGDownloadManager.h头文件，不是FGGDownloader.h
 方便多下载任务管理
 */

#import <Foundation/Foundation.h>

/**
 *  下载完成的通知名
 */
static NSString *const FGGDownloadTaskDidFinishDownloadingNotification=@"FGGDownloadTaskDidFinishDownloadingNotification";
/**
 *  系统存储空间不足的通知名
 */
static NSString *const FGGInsufficientSystemSpaceNotification=@"FGGInsufficientSystemSpaceNotification";
/**
 *  下载进度改变的通知
 */
static NSString *const FGGProgressDidChangeNotificaiton=@"FGGProgressDidChangeNotificaiton";

//下载过程中回调的代码块，3个参数分别为：下载进度、已下载部分大小/文件大小构成的字符串(如:1.15M/5.27M)、
//以及文件下载速度字符串(如:512Kb/s)
typedef void (^ProcessHandle)(float progress,NSString *sizeString,NSString *speedString);
typedef void (^CompletionHandle)();
typedef void (^FailureHandle)(NSError *error);

@interface FGGDownloader : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

//下载过程中回调的代码块，会多次调用。
@property(nonatomic,copy,readonly)ProcessHandle process;
//下载完成回调的代码块
@property(nonatomic,copy,readonly)CompletionHandle completion;
//下载失败的回调代码块
@property(nonatomic,copy,readonly)FailureHandle failure;

@property(nonatomic,strong)NSURLConnection *con;
/**
 * 获取对象的类方法
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
 *  取消下载
 */
-(void)cancel;
/**
 * 获取上一次的下载进度
 */
+(float)lastProgress:(NSString *)url;
/**获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M。
 *
 * @param url 下载链接
 */
+(NSString *)filesSize:(NSString *)url;

@end
