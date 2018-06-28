//
//  FGCommon.h
//  DownloaderDemo
//
//  Created by xgf on 2018/1/6.
//  Copyright © 2018年 夏桂峰. All rights reserved.
//

#ifndef FCCommon_h
#define FCCommon_h

typedef void (^FGProcessHandle)(float progress,NSString *sizeString,NSString *speedString);
typedef void (^FGUploadCompletionHandle)(NSData *resultData);
typedef void (^FGDownloadCompletionHandle)(void);
typedef void (^FGFailureHandle)(NSError *error);

static NSString *const FGDownloadTaskDidFinishNotification   = @"FGDownloadTaskDidFinishNotification";
static NSString *const FGUploadTaskDidFinishNotification     = @"FGUploadTaskDidFinishNotification";
static NSString *const FGInsufficientSystemSpaceNotification = @"FGInsufficientSystemSpaceNotification";
static NSString *const FGProgressDidChangeNotificaiton       = @"FGProgressDidChangeNotificaiton";

static NSString *boundary = @"FGUploaderBoundary";
static NSString *randomId = @"FGUploaderRandomId";

static NSInteger kFGDwonloadMaxTaskCount = 2;
static NSInteger kFGUploaderMaxTaskCount = 2;

#endif /* FCCommon_h */
