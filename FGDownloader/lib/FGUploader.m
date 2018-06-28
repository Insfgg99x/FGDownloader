
//
//  FGUploader.m
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 xgf. All rights reserved.
//
#import "FGUploader.h"
#import "FGTool.h"
#import <UIKit/UIKit.h>

@implementation FGUploader {
    
    NSString        *_task_key;
    NSURLConnection *_con;
    int64_t         _writenLength;
    NSDate          *_refrenceDate;
    NSMutableData   *_receivedData;
}
+ (instancetype)uploader {
    return [[[self class] alloc] init];
}
static NSData * encode(NSString *s) {
    return [s dataUsingEncoding:NSUTF8StringEncoding];
}
/**
 *  上传
 *  @param  host        服务器地址
 *  @param  data        文件二进制数据
 *  @param  p           post请求的参数
 *  @param  fileName    文件名(如1.jpg)
 *  @param  name        服务器文件的变量名
 *  @param  mimeType    文件的mimeType(如image/jpeg)
 *  @param  process     进度的回调(会多次调用)
 *  @param  completion  成功的回调
 *  @param  failure     失败的回调
 */
- (void)upload:(NSString *)host
        parama:(NSDictionary *)p
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(FGProcessHandle)process
    completion:(FGUploadCompletionHandle)completion
       failure:(FGFailureHandle)failure {
    if(!host || ![host hasPrefix:@"http"]) {
        NSError *error = [NSError errorWithDomain:@"FGUploader.upload" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"--host不能为空--"}];
        if (failure) {
            failure(error);
        }
        return;
    }
    if(p != nil){
        _task_key=[NSString stringWithFormat:@"%@?%@",host,[p description]];
    }else{
        _task_key = host;
    }
    _process=process;
    _completion=completion;
    _failure=failure;
    
    NSString *bountry = @"haha";
    NSString *line = @"\r\n";
    NSMutableData *container = [NSMutableData data];
    [container appendData:encode(@"--")];
    [container appendData:encode(bountry)];
    [container appendData:encode(line)];
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"", n1,n2];
    [container appendData:encode(disposition)];
    [container appendData:encode(line)];
    NSString *typedispos = [NSString stringWithFormat:@"Content-Type: %@",type];
    [container appendData:encode(typedispos)];
    [container appendData:encode(line)];
    [container appendData:encode(line)];
    [container appendData:data];
    [container appendData:encode(line)];
    [p enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [container appendData:encode(@"--")];
        [container appendData:encode(bountry)];
        [container appendData:encode(line)];
        NSString *dipos = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", key];
        [container appendData:encode(dipos)];
        [container appendData:encode(line)];
        [container appendData:encode(line)];
        [container appendData:encode([obj description])];
        [container appendData:encode(line)];
    }];
    [container appendData:encode(@"--")];
    [container appendData:encode(bountry)];
    [container appendData:encode(@"--")];
    [container appendData:encode(line)];
    
    //可变请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:host]];
    request.HTTPBody=container;
    request.HTTPMethod=@"POST";
    [request addValue:@(container.length).stringValue forHTTPHeaderField:@"Content-Length"];
    NSString *strContentType=[NSString stringWithFormat:@"multipart/form-data; boundary=%@", bountry];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    _con=[NSURLConnection connectionWithRequest:request delegate:self];
}
/**
 *  取消下载
 */
-(void)cancel {
    [self.con cancel];
    self.con=nil;
}
#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if(_failure){
        _failure(error);
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _receivedData = [NSMutableData data];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (_refrenceDate == nil) {
        _refrenceDate = [NSDate date];
    } else {//计算大致网速
        NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:_refrenceDate];
        long long grow = bytesWritten - _writenLength;
        CGFloat speed = grow/gap;//bytes per seconds
        NSString *speedExpress = [FGTool convertSize:speed];
        NSString *progressExpress=[NSString stringWithFormat:@"%@/s",speedExpress];
        
        NSString *progressInfo = [NSString stringWithFormat:@"%@/%@", [FGTool convertSize:bytesWritten], [FGTool convertSize:totalBytesExpectedToWrite]];
        CGFloat progress = (CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
        //发送进度改变的通知(一般情况下不需要用到，只有在触发下载与显示下载进度在不同界面的时候才会用到)
        NSDictionary *userInfo=@{@"url":_task_key,@"progress":@(progress),@"sizeString":progressInfo};
        [[NSNotificationCenter defaultCenter] postNotificationName:FGProgressDidChangeNotificaiton object:nil userInfo:userInfo];
        //回调下载过程中的代码块
        if(_process){
            _process(progress,progressInfo,progressExpress);
        }
    }
    //reset
    _refrenceDate = [NSDate date];
    _writenLength = bytesWritten;
}
/**
 * 下载完成
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:FGUploadTaskDidFinishNotification object:nil userInfo:@{@"key":_task_key}];
    if(_completion){
        _completion(_receivedData);
    }
}

@end

