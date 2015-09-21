//
//  ViewController.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import "ViewController.h"
#import "FGGDownloader.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kurl @"http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar"
#define filePath ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"1.jar"])


@interface ViewController ()
{
    UIButton        *_downloadBtn;
    UIProgressView  *_progressView;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",filePath);
    [self createUI];
}
-(void)createUI
{
    _progressView=[[UIProgressView alloc]initWithFrame:CGRectMake(50, 200, kWidth-100, 2)];
    BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if(exist)
    {
        _progressView.progress=[[FGGDownloader downloader] lastProgress];
    }
    [self.view addSubview:_progressView];
    
    _downloadBtn=[[UIButton alloc]initWithFrame:CGRectMake(kWidth/2-40, kHeight/2-20, 80, 40)];
    if(_progressView.progress==1.0)
    {
        [_downloadBtn setTitle:@"下载完成" forState:UIControlStateNormal];
        _downloadBtn.enabled=NO;
    }
    else if(_progressView.progress>0.0)
        [_downloadBtn setTitle:@"恢复下载" forState:UIControlStateNormal];
    else
        [_downloadBtn setTitle:@"开始下载" forState:UIControlStateNormal];
    [_downloadBtn addTarget:self action:@selector(downloadFile:) forControlEvents:UIControlEventTouchUpInside];
    _downloadBtn.backgroundColor=[UIColor yellowColor];
    [_downloadBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.view addSubview:_downloadBtn];
}
//下载
-(void)downloadFile:(UIButton *)sender
{
    if([sender.currentTitle isEqualToString:@"开始下载"]||[sender.currentTitle isEqualToString:@"恢复下载"])
    {
        [sender setTitle:@"暂停下载" forState:UIControlStateNormal];
        [[FGGDownloader downloader] downloadWithUrlString:kurl toPath:filePath process:^(float progress) {
            _progressView.progress=progress;
        } completion:^{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"下载完成✅" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
            [sender setTitle:@"下载完成" forState:UIControlStateNormal];
            sender.enabled=NO;
        } failure:^(NSError *error) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
    else if([sender.currentTitle isEqualToString:@"暂停下载"])
    {
        [sender setTitle:@"恢复下载" forState:UIControlStateNormal];
        [[FGGDownloader downloader] cancelDownloading];
    }
}
@end
