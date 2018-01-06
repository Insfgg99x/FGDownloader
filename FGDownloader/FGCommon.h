//
//  FGCommon.h
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 夏桂峰. All rights reserved.
//

#ifndef FCCommon_h
#define FCCommon_h

typedef void (^ProcessHandle)(float progress,NSString *sizeString,NSString *speedString);
typedef void (^CompletionHandle)();
typedef void (^FailureHandle)(NSError *error);

static NSString *const FGDownloadTaskDidFinishNotification   = @"FGDownloadTaskDidFinishNotification";
static NSString *const FGUploadTaskDidFinishNotification     = @"FGUploadTaskDidFinishNotification";
static NSString *const FGInsufficientSystemSpaceNotification = @"FGInsufficientSystemSpaceNotification";
static NSString *const FGProgressDidChangeNotificaiton       = @"FGProgressDidChangeNotificaiton";

#endif /* FCCommon_h */
