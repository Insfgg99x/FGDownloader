//
//  FGTool.h
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 夏桂峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FGTool : NSObject
/**将文件大小(bytes)转换成string*/
+ (NSString *)convertSize:(long long)length;

@end
