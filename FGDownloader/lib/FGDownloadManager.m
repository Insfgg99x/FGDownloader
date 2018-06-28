//
//  FGDownloadManager.m
//  DownloaderDemo
//
//  Created by xgf on 15/9/23.
//  Copyright © 2015年 xgf. All rights reserved.
//

#import "FGDownloadManager.h"

/**最大同时下载任务数，超过将自动存入排队对列中*/
#define kFGDwonloadMaxTaskCount 2

static FGDownloadManager *mgr=nil;

@implementation FGDownloadManager {
    NSMutableDictionary         *_taskDict;
    /**排队对列*/
    NSMutableArray              *_queue;
    /**  后台进程id*/
    UIBackgroundTaskIdentifier  _backgroudTaskId;
}

-(instancetype)init {
    if(self=[super init]) {
        _taskDict=[NSMutableDictionary dictionary];
        _queue=[NSMutableArray array];
        _backgroudTaskId=UIBackgroundTaskInvalid;
        //注册系统内存不足的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemSpaceInsufficient:) name:FGInsufficientSystemSpaceNotification object:nil];
        //注册程序下载完成的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskDidFinishDownloading:) name:FGDownloadTaskDidFinishNotification object:nil];
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
    [[FGDownloadManager shredManager] cancelDownloadTask:urlString];
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
    
    [[FGDownloadManager shredManager] cancelAllTasks];
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
    if(_taskDict.count<kFGDwonloadMaxTaskCount){
        
        if(_queue.count>0){
            
            @synchronized(_queue){
                NSDictionary *first=[_queue objectAtIndex:0];
                
                [self downloadUrl:first[@"urlString"]
                                     toPath:first[@"destinationPath"]
                                    process:first[@"process"]
                                 completion:first[@"completion"]
                                    failure:first[@"failure"]];
                //从排队对列中移除一个下载任务
                [_queue removeObjectAtIndex:0];
            }
        }
    }
}
+(instancetype)shredManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr=[[FGDownloadManager alloc]init];
    });
    return mgr;
}
-(void)downloadUrl:(NSString *)urlString toPath:(NSString *)destinationPath process:(FGProcessHandle)process completion:(FGDownloadCompletionHandle)completion failure:(FGFailureHandle)failure
{
    //若同时下载的任务数超过最大同时下载任务数，
    //则把下载任务存入对列，在下载完成后，自动进入下载。
    if(_taskDict.count>=kFGDwonloadMaxTaskCount){
        
        NSDictionary *dict=@{@"urlString":urlString,
                             @"destinationPath":destinationPath,
                             @"process":process,
                             @"completion":completion,
                             @"failure":failure};
        [_queue addObject:dict];
        
        return;
    }
    FGDownloader *downloader=[FGDownloader downloader];
    @synchronized (self) {
        [_taskDict setObject:downloader forKey:urlString];
    }
    [downloader downloadUrl:urlString
                               toPath:destinationPath
                              process:process
                           completion:completion
                              failure:failure];
}
- (void)downloadHost:(NSString *)host
               param:(NSString *)p
              toPath:(NSString *)destinationPath
             process:(FGProcessHandle)process
          completion:(FGDownloadCompletionHandle)completion
             failure:(FGFailureHandle)failure {
    
    //若同时下载的任务数超过最大同时下载任务数，
    //则把下载任务存入对列，在下载完成后，自动进入下载。
    NSString *tmpUrl = @"";
    if(p != nil){
        tmpUrl=[NSString stringWithFormat:@"%@?%@",host,p];
    }else{
        tmpUrl = host;
    }
    if(_taskDict.count>=kFGDwonloadMaxTaskCount){
    
        NSDictionary *dict=@{@"urlString":tmpUrl,
                             @"destinationPath":destinationPath,
                             @"process":process,
                             @"completion":completion,
                             @"failure":failure};
        [_queue addObject:dict];
        
        return;
    }
    FGDownloader *downloader=[FGDownloader downloader];
    @synchronized (self) {
        [_taskDict setObject:downloader forKey:tmpUrl];
    }
    [downloader downloadHost:host
                       param:p
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
    FGDownloader *downloader=[_taskDict objectForKey:url];
    [downloader cancel];
    @synchronized (self) {
        [_taskDict removeObjectForKey:url];
    }
    if(_queue.count>0){
        
        NSDictionary *first=[_queue objectAtIndex:0];
        
        [self downloadUrl:first[@"urlString"]
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
    
    FGDownloader *downloader=[_taskDict objectForKey:url];
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
    NSMutableArray *keys = [NSMutableArray array];
    @synchronized(_taskDict) {
        [_taskDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FGDownloader *downloader=obj;
            [downloader cancel];
            [keys addObject:key];
        }];
        [_taskDict removeObjectsForKeys:keys];
    }
}
-(float)lastProgress:(NSString *)url
{
    return [FGDownloader lastProgress:url];
}
-(NSString *)filesSize:(NSString *)url
{
    return [FGDownloader filesSize:url];
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
