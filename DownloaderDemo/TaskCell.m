//
//  TaskCell.m
//  DownloaderDemo
//
//  Created by xgf on 15/9/22.
//  Copyright (c) 2015年 xgf. All rights reserved.
//

#import "TaskCell.h"
#import "FGDownloadManager.h"

@implementation TaskCell

- (IBAction)downloadAction:(UIButton *)sender {
    if(self.downloadBlock)
        self.downloadBlock(sender);
}
-(void)cellWithModel:(TaskModel *)model
{
    _nameLabel.text=model.name;
    _nameLabel.adjustsFontSizeToFitWidth=YES;
    //检查之前是否已经下载，若已经下载，获取下载进度。
    BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:model.destinationPath];
    if(exist)
    {
        //获取原来的下载进度
        _progressView.progress=[[FGDownloadManager shredManager] lastProgress:model.url];
        //获取原来的文件已下载部分大小及文件总大小
        _sizeLabel.text=[[FGDownloadManager shredManager] filesSize:model.url];
        //原来的进度
        _progressLabel.text=[NSString stringWithFormat:@"%.2f%%",_progressView.progress*100];
    }
    if(_progressView.progress==1.0)
    {
        [_downloadBtn setTitle:@"完成" forState:UIControlStateNormal];
        _downloadBtn.enabled=NO;
    }
    else if(_progressView.progress>0.0)
        [_downloadBtn setTitle:@"恢复" forState:UIControlStateNormal];
    else
        [_downloadBtn setTitle:@"开始" forState:UIControlStateNormal];
}
@end
