//
//  FGGDownloadManager.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/23.
//  Copyright © 2015年 夏桂峰. All rights reserved.
//

#import "FGGDownloadManager.h"

/**
 *  最大同时下载任务数，超过将自动存入排队对列中
 */
#define kFGGDwonloadMaxTaskCount 2

static FGGDownloadManager *mgr=nil;

@implementation FGGDownloadManager
{
    NSMutableDictionary         *_taskDict;
    /**
     *  排队对列
     */
    NSMutableArray              *_queue;
    /**
     *  后台进程id
     */
    UIBackgroundTaskIdentifier  _backgroudTaskId;
}

-(instancetype)init
{
    if(self=[super init])
    {
        _taskDict=[NSMutableDictionary dictionary];
        _queue=[NSMutableArray array];
        _backgroudTaskId=UIBackgroundTaskInvalid;
        //注册系统内存不足的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemSpaceInsufficient:) name:FGGInsufficientSystemSpaceNotification object:nil];
        //注册程序下载完成的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidFinishDownloading:) name:FGGDownloadTaskDidFinishDownloadingNotification object:nil];
        //注册程序即将失去焦点的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
        //注册程序获得焦点的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        //注册程序即将被终结的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskWillBeTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
    }
    return self;
}
/**
 *  收到系统存储空间不足的通知调用的方法
 *
 *  @param sender 系统存储空间不足的通知
 */
-(void)systemSpaceInsufficient:(NSNotification *)sender{
    
    NSString *urlString=[sender.userInfo objectForKey:@"urlString"];
    [[FGGDownloadManager shredManager] cancelDownloadTask:urlString];
}
/**
 *  收到程序即将失去焦点的通知，开启后台运行
 *
 *  @param sender 通知
 */
-(void)downloadTaskWillResign:(NSNotification *)sender{
    
    if(_taskDict.count>0){
        
        _backgroudTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            
        }];
    }
}
/**
 *  收到程序重新得到焦点的通知，关闭后台
 *
 *  @param sender 通知
 */
-(void)downloadTaskDidBecomActive:(NSNotification *)sender{
    
    if(_backgroudTaskId!=UIBackgroundTaskInvalid){
        
        [[UIApplication sharedApplication] endBackgroundTask:_backgroudTaskId];
        _backgroudTaskId=UIBackgroundTaskInvalid;
    }
}
/**
 *  程序将要结束时，取消下载
 *
 *  @param sender 通知
 */
-(void)downloadTaskWillBeTerminate:(NSNotification *)sender{
    
    [[FGGDownloadManager shredManager] cancelAllTasks];
}
/**
 *  下载完成通知调用的方法
 *
 *  @param sender 通知
 */
-(void)downloadTaskDidFinishDownloading:(NSNotification *)sender{
    
    //下载完成后，从任务列表中移除下载任务，若总任务数小于最大同时下载任务数，
    //则从排队对列中取出一个任务，进入下载
    NSString *urlString=[sender.userInfo objectForKey:@"urlString"];
    [_taskDict removeObjectForKey:urlString];
    if(_taskDict.count<kFGGDwonloadMaxTaskCount){
        
        if(_queue.count>0){
            
            NSDictionary *first=[_queue objectAtIndex:0];
            
            [self downloadWithUrlString:first[@"urlString"]
                                 toPath:first[@"destinationPath"]
                                process:first[@"process"]
                             completion:first[@"completion"]
                                failure:first[@"failure"]];
            //从排队对列中移除一个下载任务
            [_queue removeObjectAtIndex:0];
        }
    }
}
+(instancetype)shredManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr=[[FGGDownloadManager alloc]init];
    });
    return mgr;
}
-(void)downloadWithUrlString:(NSString *)urlString toPath:(NSString *)destinationPath process:(ProcessHandle)process completion:(CompletionHandle)completion failure:(FailureHandle)failure
{
    //若同时下载的任务数超过最大同时下载任务数，
    //则把下载任务存入对列，在下载完成后，自动进入下载。
    if(_taskDict.count>=kFGGDwonloadMaxTaskCount){
        
        NSDictionary *dict=@{@"urlString":urlString,
                             @"destinationPath":destinationPath,
                             @"process":process,
                             @"completion":completion,
                             @"failure":failure};
        [_queue addObject:dict];
        
        return;
    }
    FGGDownloader *downloader=[FGGDownloader downloader];
    @synchronized (self) {
        [_taskDict setObject:downloader forKey:urlString];
    }
    [downloader downloadWithUrlString:urlString
                               toPath:destinationPath
                              process:process
                           completion:completion
                              failure:failure];
}
/**
 *  取消下载任务
 *
 *  @param url 下载的链接
 */
-(void)cancelDownloadTask:(NSString *)url
{
    FGGDownloader *downloader=[_taskDict objectForKey:url];
    [downloader cancel];
    @synchronized (self) {
        [_taskDict removeObjectForKey:url];
    }
    if(_queue.count>0){
        
        NSDictionary *first=[_queue objectAtIndex:0];
        
        [self downloadWithUrlString:first[@"urlString"]
                             toPath:first[@"destinationPath"]
                            process:first[@"process"]
                         completion:first[@"completion"]
                            failure:first[@"failure"]];
        //从排队对列中移除一个下载任务
        [_queue removeObjectAtIndex:0];
    }
}
/**
 *  彻底移除下载任务
 *
 *  @param url  下载链接
 *  @param path 文件路径
 */
-(void)removeForUrl:(NSString *)url file:(NSString *)path{
    
    FGGDownloader *downloader=[_taskDict objectForKey:url];
    if(downloader){
        [downloader cancel];
    }
    @synchronized (self) {
        [_taskDict removeObjectForKey:url];
    }
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    NSString *totalLebgthKey=[NSString stringWithFormat:@"%@totalLength",url];
    NSString *progressKey=[NSString stringWithFormat:@"%@progress",url];
    [usd removeObjectForKey:totalLebgthKey];
    [usd removeObjectForKey:progressKey];
    [usd synchronize];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL fileExist=[fileManager fileExistsAtPath:path];
    if(fileExist){
        
        [fileManager removeItemAtPath:path error:nil];
    }
}
-(void)cancelAllTasks
{
    [_taskDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FGGDownloader *downloader=obj;
        [downloader cancel];
        [_taskDict removeObjectForKey:key];
    }];
}
-(float)lastProgress:(NSString *)url
{
    return [FGGDownloader lastProgress:url];
}
-(NSString *)filesSize:(NSString *)url
{
    return [FGGDownloader filesSize:url];
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
