//
//  AppDelegate.m
//  DownloaderDemo
//
//  Created by 夏桂峰 on 15/9/21.
//  Copyright (c) 2015年 夏桂峰. All rights reserved.
//

#import "AppDelegate.h"
//#import "FGDownloadManager.h"
#import "ViewController.h"

@interface AppDelegate ()
{
    ViewController *_vc;
    UIBackgroundTaskIdentifier _bgTaskId;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _vc=[ViewController new];
    UINavigationController *navi=[[UINavigationController alloc] initWithRootViewController:_vc];
    self.window.rootViewController=navi;
    return YES;
}
////程序将要结束时，取消下载
//- (void)applicationWillTerminate:(UIApplication *)application {
//    
//    [[FGDownloadManager shredManager] cancelAllTasks];
//}

@end
