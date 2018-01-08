
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
    
    NSString        *_url_string;
    NSURLConnection *_con;
    int64_t         _writenLength;
    NSDate          *_refrenceDate;
}
+ (instancetype)uploader {
    return [[[self class] alloc]init];
}
/**
 *  断点上传
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
        parama:(NSString *)p
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(FGProcessHandle)process
    completion:(FGCompletionHandle)completion
       failure:(FGFailureHandle)failure {
    if(host) {
        if(p != nil){
            _url_string=[NSString stringWithFormat:@"%@?%@",host,p];
        }else{
            _url_string = host;
        }
        _process=process;
        _completion=completion;
        _failure=failure;
        
        //固定拼接格式第一部分
        NSMutableString *top = [NSMutableString string];
        [top appendFormat:@"%@%@\n", boundary, randomId];
        [top appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\n", n1, n2];
        [top appendFormat:@"Content-Type: %@\n\n", type];
        
        //固定拼接第二部分
        NSMutableString *buttom = [NSMutableString string];
        [buttom appendFormat:@"%@%@\n", boundary, randomId];
        [buttom appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
        [buttom appendString:@"Submit\n"];
        [buttom appendFormat:@"%@%@--\n", boundary, randomId];
        
        //容器
        NSMutableData *fromData=[NSMutableData data];
        //非文件参数
        if(p != nil) {
            [fromData appendData:[p dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [fromData appendData:[top dataUsingEncoding:NSUTF8StringEncoding]];
        //文件数据部分
        [fromData appendData:data];
        [fromData appendData:[buttom dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURL *url=[NSURL URLWithString:host];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        request.HTTPBody=fromData;
        [request addValue:@(fromData.length).stringValue forHTTPHeaderField:@"Content-Length"];
        NSString *strContentType=[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
        _con=[NSURLConnection connectionWithRequest:request delegate:self];
    }
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
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if(_refrenceDate == nil){
        _refrenceDate = [NSDate date];
    }else{//计算大致网速
        NSTimeInterval gap = [[NSDate date] timeIntervalSinceDate:_refrenceDate];
        long long grow = bytesWritten - _writenLength;
        CGFloat speed = grow/gap;//bytes per seconds
        NSString *speedExpress = [FGTool convertSize:speed];
        NSString *progressExpress=[NSString stringWithFormat:@"%@/s",speedExpress];
        
        NSString *progressInfo = [NSString stringWithFormat:@"%@/%@", [FGTool convertSize:bytesWritten], [FGTool convertSize:totalBytesExpectedToWrite]];
        CGFloat progress = bytesWritten / totalBytesExpectedToWrite;
        //发送进度改变的通知(一般情况下不需要用到，只有在触发下载与显示下载进度在不同界面的时候才会用到)
        NSDictionary *userInfo=@{@"url":_url_string,@"progress":@(progress),@"sizeString":progressInfo};
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
    [[NSNotificationCenter defaultCenter] postNotificationName:FGUploadTaskDidFinishNotification object:nil userInfo:@{@"urlString":_url_string}];
    if(_completion){
        _completion();
    }
}

@end

