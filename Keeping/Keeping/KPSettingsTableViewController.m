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
#import "KPUserTableViewController.h"
#import "SCLAlertView.h"
#import "DateTools.h"
#import "MBProgressHUD.h"
#import "AppKeys.h"

@interface KPSettingsTableViewController ()

@end

@implementation KPSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.unreadMsgLabel setTextColor:[UIColor redColor]];
    
    [self.animationSwitch setOnTintColor:[Utilities getColor]];
    [self.animationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]];
    
    [self.badgeSwitch setOnTintColor:[Utilities getColor]];
    [self.badgeSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]];
    
    //动画开关
    [self.animationSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.badgeSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    
    //APP 登录图标按钮
    for(UIButton *btn in self.appButtonStack.subviews){
        [btn.layer setCornerRadius:btn.layer.frame.size.width / 2];
        [btn.layer setMasksToBounds:YES];
    }
    
    //配置登录信息
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:sinaID andAppSecret:sinaKey andRedirectURI:@"http://www.baidu.com"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:qqID andAppSecret:qqKey andRedirectURI:@"http://www.baidu.com"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setFont];
    
    [self getCacheSize];

//    if([AVUser currentUser]){
//        AVQuery *query = [AVQuery queryWithClassName:@"username"];
//        [query whereKey:@"userId" equalTo:[AVUser currentUser].objectId];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                NSString *username;
//                NSInteger joinDays;
//                if(query.countObjects > 0){
//                    AVObject *user = objects[0];
//                    username = [user objectForKey:@"username"];
//                    joinDays = [[NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]] daysFrom:[NSDate dateWithYear:user.createdAt.year month:user.createdAt.month day:user.createdAt.day]];
//                }else{
//                    username = [[AVUser currentUser] valueForKey:@"username"];
//                    joinDays = [[NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]] daysFrom:[NSDate dateWithYear:[AVUser currentUser].createdAt.year month:[AVUser currentUser].createdAt.month day:[AVUser currentUser].createdAt.day]];
//                }
//                [self.userNameLabel setText:[NSString stringWithFormat:@"%@ · 已加入 %ld 天", username, (long)joinDays]];
//            }else{
//                NSLog(@"错误：%@",error.description);
//                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
//                [alert showError:@"加载失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
//            }
//        }];
//
//        [self.appButtonStack setHidden:YES];
//
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
//        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//
//    }else{
        [self.userNameLabel setText:@"登录"];
        [self.appButtonStack setHidden:NO];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
//    }
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.label.text = @"清理中";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        [fileManager removeItemAtPath:cachePath error:nil];
        [fileManager createDirectoryAtPath:cachePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showSuccess:@"清理成功" subTitle: nil closeButtonTitle:@"好的" duration:0.0];
            [alert alertIsDismissed:^{
                [self getCacheSize];
            }];
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark - Login Actions

- (IBAction)qqLoginAction:(id)sender{
    [self.appButtonStack setUserInteractionEnabled:NO];
    if(![AVUser currentUser]){
        // 如果安装了，则跳转至应用，否则跳转至网页
        [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
            if (error) {
                NSLog(@"failed to get authentication from weibo. error: %@", error.description);
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showError:@"登录失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
            } else {
                [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                    if ([self filterError:error]) {
                        [self.appButtonStack setUserInteractionEnabled:YES];
                        [self loginSucceedWithUser:user authData:object onPlatform:AVOSCloudSNSPlatformQQ];
                    }
                }];
            }
        } toPlatform:AVOSCloudSNSQQ];
    }else{
        [self performSegueWithIdentifier:@"userSegue" sender:[AVUser currentUser]];
    }
}

- (IBAction)weiboLoginAction:(id)sender{
    [self.appButtonStack setUserInteractionEnabled:NO];
    if(![AVUser currentUser]){
        // 如果安装了，则跳转至应用，否则跳转至网页
        [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
            if (error) {
                NSLog(@"failed to get authentication from weibo. error: %@", error.description);
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showError:@"登录失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
            } else {
                [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                    if ([self filterError:error]) {
                        [self.appButtonStack setUserInteractionEnabled:YES];
                        [self loginSucceedWithUser:user authData:object onPlatform:AVOSCloudSNSPlatformWeiBo];
                    }
                }];
            }
        } toPlatform:AVOSCloudSNSSinaWeibo];
    }else{
        [self performSegueWithIdentifier:@"userSegue" sender:[AVUser currentUser]];
    }
}

- (void)alert:(NSString *)message {
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:message
                                        message:nil
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

- (void)loginSucceedWithUser:(AVUser *)user authData:(NSDictionary *)authData onPlatform:(NSString *)platform{
    [AVUser loginWithAuthData:authData platform:platform block:^(AVUser *user, NSError *error) {
        if (error) {
            // 登录失败，可能为网络问题或 authData 无效
            NSLog(@"%@", error.description);
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showError:@"登录失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
        } else {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showSuccess:@"登录成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
            [alert alertIsDismissed:^{
                [self performSegueWithIdentifier:@"userSegue" sender:user];
            }];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"userSegue"]) {
        AVUser *u = (AVUser *)sender;
        KPUserTableViewController *kputvc = (KPUserTableViewController *)segue.destinationViewController;
        [kputvc setCurrentUser:u];
        [self.appButtonStack setUserInteractionEnabled:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 2;
        case 3:
            return 3;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"备份";
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
        if([AVUser currentUser]){
            [self performSegueWithIdentifier:@"userSegue" sender:[AVUser currentUser]];
        }
    }
    
    if(indexPath.section == 3 && indexPath.row == 1){
        UIAlertController *alert = [[UIAlertController alloc] init];
        UIAlertAction *iMsgAction = [UIAlertAction actionWithTitle:@"iMessage" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms:krayc425@gmail.com"] options:@{} completionHandler:^(BOOL success) {
                
            }];
        }];
        UIAlertAction *emailAction = [UIAlertAction actionWithTitle:@"微博" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sinaweibo://userinfo?uid=1634553604"]
                                               options:@{}
                                     completionHandler:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:iMsgAction];
        [alert addAction:emailAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:true completion:nil];
    }
    
    if(indexPath.section == 3 && indexPath.row == 0){
        [self clearDisk];
    }
}

@end
