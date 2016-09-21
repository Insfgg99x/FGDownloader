# FGGDownloadManager<br>
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/SnapKit.svg)](https://img.shields.io/cocoapods/v/SnapKit.svg)
[![Pod Version](http://img.shields.io/cocoapods/v/SDWebImage.svg?style=flat)](http://cocoadocs.org/docsets/XGFDownloader/)
[![Pod Platform](http://img.shields.io/cocoapods/p/SDWebImage.svg?style=flat)](http://cocoadocs.org/docsets/XGFDownloader/)

用于断点续传，退出程序后，下次启动后，恢复下载从上次下载位置开始下载<br>
<br>
![演示](https://github.com/Insfgg99x/FGGDownloader/blob/master/demo.gif)<br>
<br>
##FGGDownloadManager用法简介<br>
---------------------------------------------------------------------------------------------<br>
##基于UNSURLConnection封装的断点续传类，用于大文件下载，退出程序后，下次启动接着下载。<br>
<br>
#Install:
##Cocopods:
`pod 'FGGDownloader', '~> 1.1'`
##Manual:
download [FGGDownloader](https://github.com/Insfgg99x/FGGDownloader.git) and drag it into project。
#Useage:
-->1.在项目中导入FGGDownloadManager.h头文件；<br>
-->2.搭建UI时，设置显示进度的UIProgressView的进度值:[[FGGDownloadManager sharedManager] lastProgressWithUrl:url],<br>
这个方法的返回值是float类型的；<br>
设置显示文件大小/文件总大小的Label的文字：[[FGGDownloadManager sharedManager]fileSize:url]；<br>
<br>
-->3.开始或恢复下载任务的方法：[FGGDownloadManager sharedManager] downloadWithUrlString:(NSString *)urlString<br>
toPath:(NSString *)destinationPath<br>
process:(ProcessHandle)process<br>
completion:(CompletionHandle)completion<br>
failure:(FailureHandle)failure];<br>
<br>
#Explain
这个方法包含三个回调代码块，分别是：<br>
<br>
1)下载过程中的回调代码块，带3个参数：下载进度参数progress，已下载文件大小sizeString，文件下载速度speedString；<br>
2)下载成功回调的代码块，没有参数；<br>
3)下载失败的回调代码块，带一个下载错误参数error。<br>

-->4.在下载出错的回调代码块中处理出错信息。在出错的回调代码块中或者暂停下载任务时，<br>
调用[[FGGDownloadManager sharedManager] cancelDownloadTask:url]方法取消/暂停下载任务；<br>
<br>
================================================================================<br>
Copyright(c) 2016 CGPointZero. All rights reserved.<br>


