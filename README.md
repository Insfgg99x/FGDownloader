# FGGDownloadManager<br>

***断点续传，文件上传***

![演示](https://github.com/Insfgg99x/FGGDownloader/blob/master/demo.gif)

### Usage
- download
```
/**
*  断点下载(get)
*
*  @param  urlString        下载的链接
*  @param  destinationPath  下载的文件的保存路径
*  @param  process         进度的回调，会多次调用
*  @param  completion      下载完成的回调
*  @param  failure         下载失败的回调
*/
- (void)downloadUrl:(NSString *)urlString
             toPath:(NSString *)destinationPath
            process:(FGProcessHandle)process
         completion:(FGCompletionHandle)completion
            failure:(FGFailureHandle)failure;

/**
*  断点下载(post)
*
*  @param  host            下载的链接
*  @param  p               post参数
*  @param  destinationPath 下载的文件的保存路径
*  @param  process         进度的回调，会多次调用
*  @param  completion      下载完成的回调
*  @param  failure         下载失败的回调
*/
- (void)downloadHost:(NSString *)host
               param:(NSString *)p
              toPath:(NSString *)destinationPath
             process:(FGProcessHandle)process
          completion:(FGCompletionHandle)completion
             failure:(FGFailureHandle)failure;
```
- upload
```
/**
*  上传
*  @param  host        服务器地址
*  @param  data        文件二进制数据
*  @param  p           post请求的参数
*  @param  fileName    文件名(如1.jpg)
*  @param  name        服务器文件的变量名
*  @param  mimeType    文件的mimeType(如image/jpeg)
*  @param  process     进度的回调(会多次调用)
*  @param  completion  成功的回调
*  @param  failure     失败的回调
*/
- (void)upload:(NSString *)host
        parama:(NSDictionary *)p
          file:(NSData *)data
      mimeType:(NSString *)type
      fileName:(NSString *)n1
          name:(NSString *)n2
       process:(FGProcessHandle)process
    completion:(FGCompletionHandle)completion
       failure:(FGFailureHandle)failure;
```
### Install
- Cocopods
`pod 'FGGDownloader', '~> 2.1'`
- Manual
下载 [FGGDownloader](https://github.com/Insfgg99x/FGGDownloader.git) 并引入项目，导入`FGHeader.h`文件

