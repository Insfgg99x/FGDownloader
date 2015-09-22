//
//  TaskModel.h
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/22.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *destinationPath;

+(instancetype)model;

@end
