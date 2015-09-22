//
//  TaskCell.h
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/22.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"

@interface TaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;


@property(nonatomic,copy)void (^downloadBlock)(UIButton *sender);


-(void)cellWithModel:(TaskModel *)model;


@end
