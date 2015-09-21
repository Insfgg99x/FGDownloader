//
//  FGGDownloader.m
//  大文件下载(断点续传)
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//

#import "FGGDownloader.h"
#import <UIKit/UIKit.h>

static FGGDownloader *downloader=nil;

@implementation FGGDownloader
{
    NSString *_url_string;
    NSString *_destination_path;
    NSInteger _total_length;
    NSURLConnection *_connection;
    NSFileHandle *_writeHandle;
}
/**
 * 获取对象的类方法
 */
+(instancetype)downloader
{
    @synchronized(self)
    {
        if(!downloader)
            downloader=[[FGGDownloader alloc]init];
    }
    return downloader;
}
/**
 *  断点下载
 *
 *  @param urlString        下载的链接
 *  @param destinationPath  下载的文件的保存路径
 *  @param  process         下载过程中回调的代码块，会多次调用
 *  @param  completion      下载完成回调的代码块
 *  @param  failure         下载失败的回调代码块
 */
-(void)downloadWithUrlString:(NSString *)urlString toPath:(NSString *)destinationPath process:(ProcessHandle)process completion:(CompletionHandle)completion failure:(FailureHandle)failure
{
    if(urlString&&destinationPath)
    {
        _url_string=urlString;
        _destination_path=destinationPath;
        _process=process;
        _completion=completion;
        _failure=failure;
        
        NSURL *url=[NSURL URLWithString:urlString];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL fileExist=[fileManager fileExistsAtPath:destinationPath];
        if(fileExist)
        {
            NSInteger length=[[[fileManager attributesOfItemAtPath:destinationPath error:nil] objectForKey:NSFileSize] integerValue];
            NSString *rangeString=[NSString stringWithFormat:@"bytes=%ld-",length];
            [request setValue:rangeString forHTTPHeaderField:@"Range"];
        }
        _connection=[NSURLConnection connectionWithRequest:request delegate:self];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
/**
 * 取消下载
 */
-(void)cancelDownloading
{
    [_connection cancel];
    _connection=nil;
}
/**
 * 获取上一次的下载进度
 */
-(float)lastProgress
{
    NSString *urlSting=[[NSUserDefaults standardUserDefaults]objectForKey:@"urlString"];
    if(urlSting)
        return [[NSUserDefaults standardUserDefaults]floatForKey:[NSString stringWithFormat:@"%@progress",urlSting]];
    return 0.0;
}
#pragma mark - NSURLConnection
/**
 * 下载失败
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(_failure)
        _failure(error);
}
/**
 * 接收到响应请求
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _total_length=response.expectedContentLength;
    NSLog(@"%@",response.suggestedFilename);
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    [usd setInteger:_total_length forKey:_url_string];
    [usd setObject:_url_string forKey:@"urlString"];
    [usd synchronize];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL fileExist=[fileManager fileExistsAtPath:_destination_path];
    if(!fileExist)
        [fileManager createFileAtPath:_destination_path contents:nil attributes:nil];
    _writeHandle=[NSFileHandle fileHandleForWritingAtPath:_destination_path];
}
/**
 * 下载过程，会多次调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_writeHandle seekToEndOfFile];
    [_writeHandle writeData:data];
    NSInteger length=[[[[NSFileManager defaultManager] attributesOfItemAtPath:_destination_path error:nil] objectForKey:NSFileSize] integerValue];
    float progress=(float)length/_total_length;
    [[NSUserDefaults standardUserDefaults]setFloat:progress forKey:[NSString stringWithFormat:@"%@progress",_url_string]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(_process)
        _process(progress);
    
}
/**
 * 下载完成
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cancelDownloading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(_completion)
        _completion();
}
@end
