# FGGDownloader
用于断点续传，退出程序后，下次启动后，恢复下载从上次下载位置开始下载
----------------------------------------------------------------------------------------------------
 基于UNSURLConnection封装的断点续传类，用于大文件下载，退出程序后，下次接着下载。
 用法简介：
 -->1.在项目中导入FGGDownloader.h头文件；
 -->2.搭建UI时，设置显示进度的UIProgressView的进度值：[[FGGDownloader downloader] lastProgress];
      这个方法的返回值是float类型的；
 -->3.开始下载任务：[[FGGDownloader downloader] downloadWithUrlString:(NSString *)urlString
                                                        toPath:(NSString *)destinationPath
                                                       process:(ProcessHandle)process
                                                    completion:(CompletionHandle)completion
                                                       failure:(FailureHandle)failure];
-->4.取消/暂停下载：[[FGGDownloader downloader] cancelDownloading];
-->5.AppDelegate的程序将要退出的-(void)applicationWillTerminate:(UIApplication *)application方法中，
     取消下载：[[FGGDownloader downloader] cancelDownloading];
---------------------------------------------------------------------------------------------------
