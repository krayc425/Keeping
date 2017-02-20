//
//  KPSettingsTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSettingsTableViewController.h"
#import "Utilities.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "KPTabBar+BadgeTabBar.h"
#import "KPTabBar.h"
#import "KPUserTableViewController.h"

// 静态库方式引入
#import <LeanCloudSocial/AVOSCloudSNS.h>
#import <LeanCloudSocial/AVUser+SNS.h>

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
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSSinaWeibo withAppKey:@"2794847636" andAppSecret:@"ea8dc38d68732d3920f17a9c997862a9" andRedirectURI:@"http://www.baidu.com"];
    [AVOSCloudSNS setupPlatform:AVOSCloudSNSQQ withAppKey:@"1105994496" andAppSecret:@"uWY42qyXpNMvzovb" andRedirectURI:@"http://www.baidu.com"];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];

    if([AVUser currentUser]){
        
        AVQuery *query = [AVQuery queryWithClassName:@"username"];
        [query whereKey:@"userId" equalTo:[AVUser currentUser].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if(query.countObjects > 0){
                    AVObject *user = objects[0];
                    [self.userNameLabel setText:[user objectForKey:@"username"]];
                }else{
                    [self.userNameLabel setText:[[AVUser currentUser] valueForKey:@"username"]];
                }
            }else{
                NSLog(@"错误：%@",error.description);
            }
        }];
        
        [self.appButtonStack setHidden:YES];
    }else{
        [self.userNameLabel setText:@"登录"];
        [self.appButtonStack setHidden:NO];
    }
}

- (void)checkMessage:(id)sender{
    //检查有没有未读消息
    [[LCUserFeedbackAgent sharedInstance] countUnreadFeedbackThreadsWithBlock:^(NSInteger number, NSError *error) {
        if (error) {
            KPTabBar *tabBar = (KPTabBar *)self.tabBarController.tabBar;
            // 网络出错了，不设置红点
            [self.unreadMsgLabel setText:@""];
            [tabBar hideBadgeOnItemIndex:3];
        } else {
            KPTabBar *tabBar = (KPTabBar *)self.tabBarController.tabBar;
            // 根据未读数 number，设置红点，提醒用户
            if(number > 0){
                [self.unreadMsgLabel setText:[NSString stringWithFormat:@"%ld 条消息", (long)number]];
                [tabBar showBadgeOnItemIndex:3];
            }else{
                [self.unreadMsgLabel setText:@""];
                [tabBar hideBadgeOnItemIndex:3];
            }
        }
    }];
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
    for(UILabel *lbl in self.labels) {
        [lbl setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    }
}

- (IBAction)qqLoginAction:(id)sender{
    if(![AVUser currentUser]){
        // 如果安装了，则跳转至应用，否则跳转至网页
        [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
            if (error) {
                NSLog(@"failed to get authentication from weibo. error: %@", error.description);
            } else {
                [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformQQ block:^(AVUser *user, NSError *error) {
                    if ([self filterError:error]) {
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
    if(![AVUser currentUser]){
        // 如果安装了，则跳转至应用，否则跳转至网页
        [AVOSCloudSNS loginWithCallback:^(id object, NSError *error) {
            if (error) {
                NSLog(@"failed to get authentication from weibo. error: %@", error.description);
            } else {
                [AVUser loginWithAuthData:object platform:AVOSCloudSNSPlatformWeiBo block:^(AVUser *user, NSError *error) {
                    if ([self filterError:error]) {
                        [self loginSucceedWithUser:user authData:object onPlatform:AVOSCloudSNSPlatformWeiBo];
                    }
                }];
            }
        } toPlatform:AVOSCloudSNSSinaWeibo];
    }else{
        [self performSegueWithIdentifier:@"userSegue" sender:[AVUser currentUser]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"userSegue"]) {
        AVUser *u = (AVUser *)sender;
        KPUserTableViewController *kputvc = (KPUserTableViewController *)segue.destinationViewController;
        [kputvc setCurrentUser:u];
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
            return 2;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"账号";
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
    
    if(indexPath.section == 3 && indexPath.row == 0){
        LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
        [agent showConversations:self title:nil contact:nil];
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
        } else {
            [self performSegueWithIdentifier:@"userSegue" sender:user];
        }
    }];
}

@end
