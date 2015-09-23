//
//  FGGDownloader.m
//  大文件下载(断点续传)
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 峰哥哥. All rights reserved.
//

#import "FGGDownloader.h"
#import <UIKit/UIKit.h>

@implementation FGGDownloader
{
    NSString *_url_string;
    NSString *_destination_path;
    NSFileHandle *_writeHandle;
    NSURLConnection *_con;
}
/**
 * 获取对象的类方法
 */
+(instancetype)downloader
{
    return [[[self class] alloc]init];
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
        _con=[NSURLConnection connectionWithRequest:request delegate:self];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
/**
 *  取消下载
 */
+(void)cancelDownloadTask:(FGGDownloader *)downloader
{
    [downloader.con cancel];
    downloader.con=nil;
}
/**
 * 获取上一次的下载进度
 */
+(float)lastProgress:(NSString *)url
{
    if(url)
        return [[NSUserDefaults standardUserDefaults]floatForKey:[NSString stringWithFormat:@"%@progress",url]];
    return 0.0;
}
/**获取文件已下载的大小和总大小,格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
 */
+(NSString *)filesSize:(NSString *)url
{
    NSString *totalLebgthKey=[NSString stringWithFormat:@"%@totalLength",url];
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    NSInteger totalLength=[usd integerForKey:totalLebgthKey];
    if(totalLength==0)
    {
        return @"0.00K/0.00K";
    }
    NSString *progressKey=[NSString stringWithFormat:@"%@progress",url];
    float progress=[[NSUserDefaults standardUserDefaults] floatForKey:progressKey];
    NSInteger currentLength=progress*totalLength;
    
    NSString *currentSize=[self convertSize:currentLength];
    NSString *totalSize=[self convertSize:totalLength];
    return [NSString stringWithFormat:@"%@/%@",currentSize,totalSize];
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
    NSString *key=[NSString stringWithFormat:@"%@totalLength",_url_string];
    NSUserDefaults *usd=[NSUserDefaults standardUserDefaults];
    NSInteger totalLength=[usd integerForKey:key];
    if(totalLength==0)
    {
        [usd setInteger:response.expectedContentLength forKey:key];
        [usd synchronize];
    }
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
    NSString *key=[NSString stringWithFormat:@"%@totalLength",_url_string];
    NSInteger totalLength=[[NSUserDefaults standardUserDefaults] integerForKey:key];
    
    //计算下载进度
    float progress=(float)length/totalLength;
    [[NSUserDefaults standardUserDefaults]setFloat:progress forKey:[NSString stringWithFormat:@"%@progress",_url_string]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //获取文件大小，格式为：格式为:已经下载的大小/文件总大小,如：12.00M/100.00M
    NSString *sizeString=[FGGDownloader filesSize:_url_string];
    //回调下载过程中的代码块
    if(_process)
        _process(progress,sizeString);
}
/**
 * 下载完成
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if(_completion)
        _completion();
}
/**
 * 计算缓存的占用存储大小
 *
 * @prama length  文件大小
 */
+(NSString *)convertSize:(NSInteger)length
{
    if(length<1024)
        return [NSString stringWithFormat:@"%ldB",(long)length];
    else if(length>=1024&&length<1024*1024)
        return [NSString stringWithFormat:@"%.2fK",(float)length/1024];
    else if(length >=1024*1024&&length<1024*1024*1024)
        return [NSString stringWithFormat:@"%.2fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.2fG",(float)length/(1024*1024*1024)];
}
@end
