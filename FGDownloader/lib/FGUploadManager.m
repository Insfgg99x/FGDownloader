//
//  FGUploadManager.m
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 xgf. All rights reserved.
//

#import "FGUploadManager.h"
#import <UIKit/UIKit.h>

static FGUploadManager *uploadMgr=nil;

@implementation FGUploadManager {
    NSMutableDictionary         *_taskDict;
    /**排队对列*/
    NSMutableArray              *_queue;
    /**  后台进程id*/
    UIBackgroundTaskIdentifier  _backgroudTaskId;
}
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadMgr = [[FGUploadManager alloc] init];
    });
    return uploadMgr;
}
- (instancetype)init {
    if(self=[super init]) {
        _taskDict=[NSMutableDictionary dictionary];
        _queue=[NSMutableArray array];
        _backgroudTaskId=UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidFinishUploading:) name:FGUploadTaskDidFinishNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskDidBecomActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWillBeTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
    }
    return self;
}
/**
 *  收到程序即将失去焦点的通知，开启后台运行
 *
 *  @param sender 通知
 */
-(void)taskWillResign:(NSNotification *)sender{
    
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
-(void)taskDidBecomActive:(NSNotification *)sender{
    
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
-(void)taskWillBeTerminate:(NSNotification *)sender{
    
    [self cancelAllTasks];
}
/**
 *  下载完成通知调用的方法
 *
 *  @param sender 通知
 */
- (void)taskDidFinishUploading:(NSNotification *)sender {
    //下载完成后，从任务列表中移除下载任务，若总任务数小于最大同时下载任务数，
    //则从排队对列中取出一个任务，进入下载
    NSString *key=[sender.userInfo objectForKey:@"key"];
    [_taskDict removeObjectForKey:key];
    if(_taskDict.count<kFGDwonloadMaxTaskCount){
        
        if(_queue.count>0){
            
            @synchronized(_queue){
                NSDictionary *first=[_queue objectAtIndex:0];
                
                [self upload:first[@"host"]
                      parama:first[@"paramaters"]
                        file:first[@"data"]
                    mimeType:first[@"type"]
                    fileName:first[@"fileName"]
                        name:first[@"name"]
                     process:first[@"process"]
                  completion:first[@"completion"]
                     failure:first[@"failure"]];
                //从排队对列中移除一个下载任务
                [_queue removeObjectAtIndex:0];
            }
        }
    }
}
+(instancetype)shred {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadMgr=[[FGUploadManager alloc]init];
    });
    return uploadMgr;
}
- (void)upload:(NSString *)host
        parama:(NSDictionary *)p
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(FGProcessHandle)process
    completion:(FGUploadCompletionHandle)completion
       failure:(FGFailureHandle)failure {
    
    if(!host ||
       ![host hasPrefix:@"http"] ||
       !type ||
       !n1 ||
       !n2) {
        return;
    }
    //若同时下载的任务数超过最大同时下载任务数，
    //则把下载任务存入对列，在下载完成后，自动进入下载。
    if(_taskDict.count>=kFGDwonloadMaxTaskCount){
        
        NSDictionary *dict=@{@"host":host,
                             @"mimeType":type,
                             @"paramaters":p == nil ? @"" : p,
                             @"data":data,
                             @"fileName":n1,
                             @"name":n2,
                             @"process":process,
                             @"completion":completion,
                             @"failure":failure};
        [_queue addObject:dict];
        
        return;
    }
    FGUploader *uploader=[FGUploader uploader];
    NSString *key = @"";
    if(p != nil){
        key=[NSString stringWithFormat:@"%@?%@",host,p];
    }else{
        key = host;
    }
    @synchronized (self) {
        [_taskDict setObject:uploader forKey:key];
    }
    [uploader upload:host
              parama:p
                file:data
            mimeType:type
            fileName:n1
                name:n2
             process:process
          completion:completion
             failure:failure];
}

-(void)cancelTask:(NSString *)url {
    FGUploader *uploader=[_taskDict objectForKey:url];
    [uploader cancel];
    @synchronized (_taskDict) {
        [_taskDict removeObjectForKey:url];
    }
    @synchronized(_queue) {
        if(_queue.count>0){
            
            NSDictionary *first=[_queue objectAtIndex:0];
            
            [self upload:first[@"host"]
                  parama:first[@"paramaters"]
                    file:first[@"data"]
                mimeType:first[@"type"]
                fileName:first[@"fileName"]
                    name:first[@"name"]
                 process:first[@"process"]
              completion:first[@"completion"]
                 failure:first[@"failure"]];
            //从排队对列中移除一个下载任务
            [_queue removeObjectAtIndex:0];
        }
    }
}
-(void)cancelAllTasks {
    
    NSMutableArray *keys = [NSMutableArray array];
    @synchronized(_taskDict) {
        [_taskDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            FGUploader *uploader=obj;
            [uploader cancel];
            [keys addObject:key];
        }];
        [_taskDict removeObjectsForKeys:keys];
    }
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

