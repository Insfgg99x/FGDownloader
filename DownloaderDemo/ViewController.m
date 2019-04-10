//
//  ViewController.m
//  DownloaderDemo
//
//  Created by xgf on 15/9/21.
//  Copyright (c) 2015年 xgf. All rights reserved.
//

#import "ViewController.h"
#import "FGHeader.h"
#import "TaskCell.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kCachePath (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0])

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray  *_dataArray;
}
@property(nonatomic,strong)UITableView  *tbView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self prepareData];
    [self createUI];
}
- (void)setup {
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationController.navigationBar.barStyle=UIBarStyleBlackOpaque;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.title=@"Demo";
    _dataArray=[NSMutableArray array];
}
//添加3个任务模型
- (void)prepareData {
    TaskModel *model=[TaskModel model];
    model.name=@"GDTSDK.zip";
    model.url=@"http://imgcache.qq.com/qzone/biz/gdt/dev/sdk/ios/release/GDT_iOS_SDK.zip";
    model.destinationPath=[kCachePath stringByAppendingPathComponent:model.name];
    [_dataArray addObject:model];
    
    TaskModel *anotherModel=[TaskModel model];
    anotherModel.name=@"CONTENT.jar";
    anotherModel.url=@"http://android-mirror.bugly.qq.com:8080/eclipse_mirror/juno/content.jar";
    anotherModel.destinationPath=[kCachePath stringByAppendingPathComponent:anotherModel.name];
    [_dataArray addObject:anotherModel];
    
    TaskModel *third=[TaskModel model];
    third.name=@"Dota2";
    third.url=@"http://dota2.dl.wanmei.com/dota2/client/DOTA2Setup20160329.zip";
    third.destinationPath=[kCachePath stringByAppendingString:third.name];
    [_dataArray addObject:third];
}

- (void)createUI {
    _tbView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64) style:UITableViewStylePlain];
    _tbView.delegate=self;
    _tbView.dataSource=self;
    [self.view addSubview:_tbView];
    
    UIButton *uploadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    uploadBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [uploadBtn setTitle:@"测试上传" forState:UIControlStateNormal];
    [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    uploadBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [uploadBtn addTarget:self action:@selector(testUpload:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *uploadItem = [[UIBarButtonItem alloc] initWithCustomView:uploadBtn];
    self.navigationItem.rightBarButtonItem = uploadItem;
}

//MARK: - test upload
- (void)testUpload:(UIButton *)sender {
    sender.enabled = NO;
    NSString *host = @"http://games.kmbopai.com/Services/UserInfoService.asmx/UploadFile";
    NSDictionary *paramaters = nil;
    NSString *name = @"media";
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    [[FGUploadManager shared] upload:host
                              parama:paramaters
                                file:data
                            mimeType:@"image/jpeg"
                            fileName:@"1.jpg"
                                name:name
                             process:^(float progress, NSString *sizeString, NSString *speedString) {
                                   NSLog(@"上传中... 进度: %.2f",progress);
                            } completion:^(NSData *resultData) {
                                NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                                NSLog(@"上传成功:\n%@",result);
                                sender.enabled = YES;
                            } failure:^(NSError *error) {
                                NSLog(@"上传失败");
                                sender.enabled = YES;
                            }];
}
//MARK: - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId=@"TaskCellID";
    TaskCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(!cell)
        cell=[[[NSBundle mainBundle] loadNibNamed:@"TaskCell" owner:nil options:nil] lastObject];  
    TaskModel *model=_dataArray[indexPath.row];
    [cell cellWithModel:model];
    //点击下载按钮时回调的代码块
    __weak typeof(cell) weakCell = cell;
    cell.downloadBlock = ^(UIButton *sender) {
        if([sender.currentTitle isEqualToString:@"开始"]||[sender.currentTitle isEqualToString:@"恢复"]) {
            [sender setTitle:@"暂停" forState:UIControlStateNormal];
            //添加下载任务
            [[FGDownloadManager shredManager] downloadUrl:model.url toPath:model.destinationPath process:^(float progress, NSString *sizeString, NSString *speedString) {
                //更新进度条的进度值
                weakCell.progressView.progress = progress;
                //更新进度值文字
                weakCell.progressLabel.text = [NSString stringWithFormat:@"%.2f%%",progress*100];
                //更新文件已下载的大小
                weakCell.sizeLabel.text = sizeString;
                //显示网速
                weakCell.speedLabel.text = speedString;
                if(speedString)
                    weakCell.speedLabel.hidden = NO;
            } completion:^{
                [sender setTitle:@"完成" forState:UIControlStateNormal];
                sender.enabled = NO;
                weakCell.speedLabel.hidden = YES;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@下载完成✅",model.name] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [alert show];
            } failure:^(NSError *error) {
                [[FGDownloadManager shredManager] cancelDownloadTask:model.url];
                [sender setTitle:@"恢复" forState:UIControlStateNormal];
                weakCell.speedLabel.hidden=YES;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];

            }];
        } else if([sender.currentTitle isEqualToString:@"暂停"]) {
            [sender setTitle:@"恢复" forState:UIControlStateNormal];
            [[FGDownloadManager shredManager] cancelDownloadTask:model.url];
            TaskCell *cell=(TaskCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.speedLabel.hidden = YES;
        }
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskModel *model = [_dataArray objectAtIndex:indexPath.row];
    [[FGDownloadManager shredManager] removeForUrl:model.url file:model.destinationPath];
    [_dataArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"移除";
}
@end
