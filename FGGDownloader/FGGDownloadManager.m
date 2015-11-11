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
    [_taskDict setObject:downloader forKey:urlString];
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
    [_taskDict removeObjectForKey:url];
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
