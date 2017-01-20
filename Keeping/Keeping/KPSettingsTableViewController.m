//
//  KPSettingsTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSettingsTableViewController.h"
#import "Utilities.h"

@interface KPSettingsTableViewController ()

@end

@implementation KPSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置版本号
    self.versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 3;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"";
        case 1:
            return @"其他";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 0){
        [self scoreApp];
    }else if(indexPath.section == 1 && indexPath.row == 1){
        [self sendBugEmail];
    }
}

#pragma mark - Send Email

- (void)sendBugEmail{
    if(![MFMailComposeViewController canSendMail]){
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"错误"
                                            message:@"不能发送邮件，请前往设置->邮件添加邮箱"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    MFMailComposeViewController *wMailViewController = [[MFMailComposeViewController alloc] init];
    wMailViewController.mailComposeDelegate = self;
    
    NSString *title = [NSString stringWithFormat:@"Keeping! Feedbacks"];
    [wMailViewController setSubject:title];
    
    [wMailViewController setToRecipients:[NSArray arrayWithObject:@"krayc@foxmail.com"]];
    
    NSString *phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString *phoneModel  = [[UIDevice currentDevice] model];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *emailBody = [NSMutableString stringWithFormat:@"Keeping!\n\nBug提交:\n\n意见或建议:\n\n您的大名:\n\n"];
    emailBody = [emailBody stringByAppendingString: @"Phone Model:"];
    emailBody = [emailBody stringByAppendingString: phoneModel.description];
    emailBody = [emailBody stringByAppendingString: @"\niOS Version:"];
    emailBody = [emailBody stringByAppendingString: phoneVersion.description];
    emailBody = [emailBody stringByAppendingString: @"\nApp Version:"];
    emailBody = [emailBody stringByAppendingString: appVersion.description];
    
    [wMailViewController setMessageBody:emailBody isHTML:NO];
    [self presentViewController:wMailViewController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSString *msg;
    NSString *tle;
    BOOL flag = false;;
    switch (result) {
        case MFMailComposeResultSent:
            flag = true;
            tle = @"谢谢";
            msg = @"发送成功！感谢您的反馈！";
            break;
        case MFMailComposeResultSaved:
            flag = true;
            msg = @"您保存了这封邮件的草稿";
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            flag = true;
            tle = @"失败";
            msg = @"非常抱歉！发送失败！";
            break;
    }
    if(flag){
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:tle
                                            message:msg
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Go to Score

- (void)scoreApp{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [Utilities getAPPID]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]
                                       options:@{}
                             completionHandler:nil];
}

@end
