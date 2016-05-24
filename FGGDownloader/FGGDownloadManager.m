//
//  FGGDownloadManager.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/23.
//  Copyright © 2015年 夏桂峰. All rights reserved.
//

#import "FGGDownloadManager.h"

static FGGDownloadManager *mgr=nil;

@implementation FGGDownloadManager
{
    NSMutableDictionary *_taskDict;
}

-(instancetype)init
{
    if(self=[super init])
    {
        _taskDict=[NSMutableDictionary dictionary];
    }
    return self;
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
-(void)cancelDownloadTask:(NSString *)url
{
    FGGDownloader *downloader=[_taskDict objectForKey:url];
    [downloader cancel];
    @synchronized (self) {
        [_taskDict removeObjectForKey:url];
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
@end
