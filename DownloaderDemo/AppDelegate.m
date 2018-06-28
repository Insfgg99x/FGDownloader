//
//  AppDelegate.m
//  DownloaderDemo
//
//  Created by xgf on 15/9/21.
//  Copyright (c) 2015年 xgf. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navi=[[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    self.window.rootViewController=navi;
    return YES;
}


@end
