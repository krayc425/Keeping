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
@import SafariServices;

@interface KPSettingsTableViewController () <SFSafariViewControllerDelegate>

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
    NSString *version = [NSString stringWithFormat:@"%@ · %@ v%@ (%@)", NSLocalizedString(@"Keeping", nil), NSLocalizedString(@"Version", nil),  infoDic[@"CFBundleShortVersionString"], infoDic[@"CFBundleVersion"]];
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Clear success", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
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
    NSString *showBackupDateString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Last backup", nil), backUpDateString == nil ? NSLocalizedString(@"None", nil) : backUpDateString];
                                  
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"iCloud backup", nil) message:showBackupDateString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Upload backup", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading", nil)];
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"IDname"];
        
        __weak __typeof__(self) weakSelf = self;
        
        [[CKContainer defaultContainer].privateCloudDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            KPSettingsTableViewController *strongSelf = weakSelf;
            
            NSURL *url = [NSURL fileURLWithPath:[[DBManager shareInstance] getDBPath]];
            CKAsset *asset = [[CKAsset alloc] initWithFileURL:url];
            if (record == nil) {
                // 没找到记录，新建一个
                record = [[CKRecord alloc] initWithRecordType:@"KeepingDB" recordID:recordID];
            }
            record[@"db"] = asset;
            
            [[CKContainer defaultContainer].privateCloudDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                if(!error){
                    [strongSelf alert:NSLocalizedString(@"Upload success", nil)];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[DateUtil getBackupDateStringOfDate:record.modificationDate] forKey:@"Backup_date_string"];
                }else{
                    [strongSelf alert:NSLocalizedString(@"Upload failed", nil) subMessage:error.description];
                }
                [SVProgressHUD dismiss];
            }];
        }];
    }];
    [alert addAction:uploadAction];
    
    UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Download backup", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading", nil)];
        
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"KeepingDB" predicate:predicate];
        [[CKContainer defaultContainer].privateCloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            if(!error){
                [self alert:NSLocalizedString(@"Download success", nil)];
                CKRecord *record = (CKRecord *)[results firstObject];
                
                [[[DBManager shareInstance] getDB] close];
                
                CKAsset *asset = (CKAsset *)record[@"db"];
                
                [[DBManager shareInstance] establishDBWithPreviousPath:asset.fileURL];
            }else{
                [self alert:NSLocalizedString(@"Download failed", nil) subMessage:error.description];
            }
            [SVProgressHUD dismiss];
        }];
    }];
    [alert addAction:downloadAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)contactMe{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Contact me", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *iMsgAction = [UIAlertAction actionWithTitle:@"iMessage" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:krayc425@gmail.com"] options:@{} completionHandler:^(BOOL success) {
            
        }];
    }];
    UIAlertAction *weixinAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"WeChat", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = @"krayc425";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"WeChat account copied", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *wechatAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Jump to WeChat", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]
                                               options:@{}
                                     completionHandler:nil];
        }];
        [alert addAction:wechatAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    UIAlertAction *weiboAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Weibo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sinaweibo://userinfo?uid=1634553604"]
                                           options:@{}
                                 completionHandler:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
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
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
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
    switch (section) {
        case 0:
        case 1:
        case 2:
            return 2;
        case 3:
            return 4;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"数据";
        case 1:
            return @"外观";
        case 2:
            return @"偏好";
        case 3:
            return @"其他";
        default:
            return @"";
    }
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
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://songkuixi.github.io/2017/03/02/Keeping-Q-A/"] entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        [self presentViewController:safariVC animated:YES completion:nil];
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
