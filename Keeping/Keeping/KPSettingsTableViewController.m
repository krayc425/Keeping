//
//  KPSettingsTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSettingsTableViewController.h"
#import "Utilities.h"
#import "KPTabBar.h"
#import "AppKeys.h"
#import <AVOSCloud/AVOSCloud.h>
#import <StoreKit/StoreKit.h>
#import "VTAcknowledgementsViewController.h"
#import <CloudKit/CloudKit.h>
#import "DBManager.h"
#import "DateUtil.h"
#import "SVProgressHUD.h"

@interface KPSettingsTableViewController ()

@end

@implementation KPSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")){
        [SKStoreReviewController requestReview];
    }
    
    [self.animationSwitch setOnTintColor:[Utilities getColor]];
    [self.animationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]];
    
    [self.badgeSwitch setOnTintColor:[Utilities getColor]];
    [self.badgeSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]];
    
    //动画开关
    [self.animationSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.badgeSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    
    //版本号
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"今日打卡 · 版本号 v%@ (%@)",infoDic[@"CFBundleShortVersionString"],infoDic[@"CFBundleVersion"]];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    versionLabel.text = version;
    versionLabel.textColor = [UIColor lightGrayColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.font = [UIFont systemFontOfSize:12.0];
    [footerView addSubview:versionLabel];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LOGO_1024"]];
    [logoView setFrame:CGRectMake(0, 0, 30, 30)];
    [logoView setCenter:CGPointMake(SCREEN_WIDTH / 2.0, 50)];
    [logoView.layer setCornerRadius:7.5];
    [logoView setClipsToBounds:YES];
    [footerView addSubview:logoView];
    self.tableView.tableFooterView = footerView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setFont];
    
    [self getCacheSize];
}

- (void)getCacheSize {
    NSUInteger size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:cachePath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    [self.cacheLabel setText:[NSString stringWithFormat:@"%.2f MB", size / 1024 / 1024.0]];
}

- (void)clearDisk {
    [SVProgressHUD showWithStatus:@"清理中"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        [fileManager removeItemAtPath:cachePath error:nil];
        [fileManager createDirectoryAtPath:cachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清理成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{
                [self getCacheSize];
            }];
        });
        
    });
}

- (void)switchChange:(id)sender{
    switch ([sender tag]){
            //tag == 0: 动画开关
        case 0:
        {
            [[NSUserDefaults standardUserDefaults] setBool:self.animationSwitch.isOn forKey:@"animation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
            //tag == 1: 角标开关
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setBool:self.badgeSwitch.isOn forKey:@"badgeCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_Badge"
                                                                object:nil
                                                              userInfo:nil];
        }
            break;
        default:
            break;
    }
}

- (void)setFont{
    [self.labels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *lbl = (UILabel *)obj;
        [lbl setFont:[UIFont systemFontOfSize:17.0]];
    }];
}

- (void)goBackup{
    NSString *backUpDateString = [[NSUserDefaults standardUserDefaults] valueForKey:@"Backup_date_string"];
    NSString *showBackupDateString = [NSString stringWithFormat:@"上次备份：%@", backUpDateString == nil ? @"无" : backUpDateString];
                                  
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"备份" message:showBackupDateString preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"上传备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:@"上传中"];
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"IDname"];
        
        __weak __typeof__(self) weakSelf = self;
        
        [[CKContainer defaultContainer].privateCloudDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            KPSettingsTableViewController *strongSelf = weakSelf;
            
            if (record != nil) {
                NSLog(@"获取备份信息成功");
            }
            
            NSURL *url = [NSURL fileURLWithPath:[[DBManager shareInstance] getDBPath]];
            CKAsset *asset = [[CKAsset alloc] initWithFileURL:url];
            if (record == nil) {
                // 没找到记录，新建一个
                record = [[CKRecord alloc] initWithRecordType:@"KeepingDB" recordID:recordID];
            }
            record[@"db"] = asset;
            
            [[CKContainer defaultContainer].privateCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                if(!error){
                    [strongSelf alert:@"上传备份成功"];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[DateUtil getBackupDateStringOfDate:record.modificationDate] forKey:@"Backup_date_string"];
                }else{
                    [strongSelf alert:@"上传备份失败" subMessage:error.description];
                }
                [SVProgressHUD dismiss];
            }];
        }];
    }];
    [alert addAction:uploadAction];
    
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:@"下载备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:@"下载中"];
        
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"KeepingDB" predicate:predicate];
        [[CKContainer defaultContainer].privateCloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if(!error){
                [self alert:@"下载备份成功"];
                CKRecord *record = (CKRecord *)[results firstObject];
                
                [[[DBManager shareInstance] getDB] close];
                
                CKAsset *asset = (CKAsset *)record[@"db"];
                
                [[DBManager shareInstance] establishDBWithPreviousPath:asset.fileURL];
            }else{
                [self alert:@"下载备份失败" subMessage:error.description];
            }
            [SVProgressHUD dismiss];
        }];
    }];
    [alert addAction:downloadAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)contactMe{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"联系作者" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *iMsgAction = [UIAlertAction actionWithTitle:@"iMessage" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:krayc425@gmail.com"] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    UIAlertAction *weixinAction = [UIAlertAction actionWithTitle:@"微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = @"krayc425";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"微信号已复制" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *wechatAction = [UIAlertAction actionWithTitle:@"跳转到微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]
                                               options:@{}
                                     completionHandler:nil];
        }];
        [alert addAction:wechatAction];
        [self presentViewController:alert animated:YES completion:^{
            [self performSegueWithIdentifier:@"userSegue" sender:nil];
        }];
    }];
    UIAlertAction *weiboAction = [UIAlertAction actionWithTitle:@"微博" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sinaweibo://userinfo?uid=1634553604"]
                                           options:@{}
                                 completionHandler:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:iMsgAction];
    [alert addAction:weixinAction];
    [alert addAction:weiboAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Login Actions

- (void)alert:(NSString *)message {
    [self alert:message subMessage:nil];
}

- (void)alert:(NSString *)message subMessage:(NSString *_Nullable)subMessage {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:message
                                        message:subMessage
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)filterError:(NSError *)error {
    if (error) {
        [self alert:[error localizedDescription]];
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [@[@(2), @(2), @(2), @(4)][section] integerValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @[@"数据", @"外观", @"偏好", @"其他"][section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0 && indexPath.row == 0){
        [self goBackup];
    }else if(indexPath.section == 0 && indexPath.row == 1){
        [self clearDisk];
    }
    
    if(indexPath.section == 3 && indexPath.row == 0){
        [self contactMe];
    }else if(indexPath.section == 3 && indexPath.row == 2){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://songkuixi.github.io/2017/03/02/Keeping-Q-A/"]
                                           options:@{}
                                 completionHandler:nil];
        
    }else if(indexPath.section == 3 && indexPath.row == 1){
        NSString *str;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")){
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", [Utilities getAPPID]];
        }else{
            str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [Utilities getAPPID]];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]
                                           options:@{}
                                 completionHandler:nil];
        
        
    }else if(indexPath.section == 3 && indexPath.row == 3){
        VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
