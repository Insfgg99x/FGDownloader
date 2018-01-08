//
//  FGTool.m
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 夏桂峰. All rights reserved.
//

#import "FGTool.h"

@implementation FGTool
+ (NSString *)convertSize:(long long)length {
    if(length<1024) {
        return [NSString stringWithFormat:@"%lldB",length];
    }else if(length>=1024&&length<1024*1024) {
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    }else if(length >=1024*1024&&length<1024*1024*1024) {
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    }else {
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
    }
}
@end
