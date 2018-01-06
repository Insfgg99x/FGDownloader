//
//  TaskCell.h
//  DownloaderDemo
//
//  Created by xgf on 15/9/22.
//  Copyright (c) 2015年 xgf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskModel.h"

@interface TaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;


@property(nonatomic,copy)void (^downloadBlock)(UIButton *sender);


-(void)cellWithModel:(TaskModel *)model;


@end
