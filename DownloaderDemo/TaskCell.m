//
//  TaskCell.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/22.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import "TaskCell.h"
#import "FGGDownloader.h"

@implementation TaskCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)downloadAction:(UIButton *)sender {
    if(self.downloadBlock)
        self.downloadBlock(sender);
}
-(void)cellWithModel:(TaskModel *)model
{
    _nameLabel.text=model.name;
    //检查之前是否已经下载，若已经下载，获取下载进度。
    BOOL exist=[[NSFileManager defaultManager] fileExistsAtPath:model.destinationPath];
    if(exist)
    {
        _progressView.progress=[FGGDownloader lastProgress:model.url];
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
