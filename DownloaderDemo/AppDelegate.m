//
//  AppDelegate.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import "AppDelegate.h"
#import "FGGDownloader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}
//程序将要结束时，取消下载
- (void)applicationWillTerminate:(UIApplication *)application {
    [[FGGDownloader downloader] cancelDownloading];
}

@end
