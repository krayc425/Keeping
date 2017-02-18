//
//  KPUserTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPUserTableViewController.h"
#import "Utilities.h"
#import "DBManager.h"
#import <AVOSCloud/AVOSCloud.h>
#import "MBProgressHUD.h"

@interface KPUserTableViewController ()

@end

@implementation KPUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"用户信息"];
    
    [self.userNameLabel setText:self.currentUser.username];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setFont{
    for(UILabel *lbl in self.labels) {
        [lbl setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    }
}

- (void)uploadDB{
    AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
    [query whereKey:@"userID" equalTo:self.currentUser.objectId];
    if(query.countObjects == 0){
        AVObject *dbBackUp = [AVObject objectWithClassName:@"dbBackUp"];
        [dbBackUp setObject:self.currentUser.objectId forKey:@"userID"];
        AVFile *f = [AVFile fileWithName:@"" contentsAtPath:[[DBManager shareInstance] getDBPath]];
        [dbBackUp setObject:f forKey:@"db"];
        [dbBackUp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSString *msg;
            if(succeeded){
                msg = @"上传成功";
            }else{
                msg = @"上传失败";
            }
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:msg
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    }else{
        AVObject *dbBackUp = [query getFirstObject];
        
        AVFile *f2 = [dbBackUp objectForKey:@"db"];

        if(f2 != NULL){
            [AVFile getFileWithObjectId:f2.objectId withBlock:^(AVFile * _Nullable file, NSError * _Nullable error) {
                [file deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded){
                        NSLog(@"删除成功");
                    }else{
                        NSLog(@"删除失败");
                    }
                }];
            }];
        }
        
        AVFile *f = [AVFile fileWithName:@"" contentsAtPath:[[DBManager shareInstance] getDBPath]];
        [dbBackUp setObject:f forKey:@"db"];
        [dbBackUp saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            NSString *msg;
            if(succeeded){
                msg = @"上传成功";
            }else{
                msg = @"上传失败";
            }
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:msg
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    }
}

- (void)downloadDB{
    AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
    [query whereKey:@"userID" equalTo:self.currentUser.objectId];
    if(query.countObjects == 0){
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"您未上传过数据"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        AVObject *dbBackUp = [query getFirstObject];
        AVFile *file = [dbBackUp objectForKey:@"db"];
        [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            [[[DBManager shareInstance] getDB] close];
            
            [[NSFileManager defaultManager] createFileAtPath:[[DBManager shareInstance] getDBPath] contents:data attributes:nil];
            
            [[[DBManager shareInstance] getDB] open];
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"下载成功"
                                                message:nil
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2 && indexPath.row == 0){
        
        [AVUser logOut];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
        hud.label.text = @"上传中";
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            [self uploadDB];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
            
        });
        
    }else if(indexPath.section == 1 && indexPath.row == 1){
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"注意"
                                            message:@"下载后将覆盖本地所有数据，确定下载吗？"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        [alertController addAction:cancelAction];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"下载"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             
                                                             MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
                                                             hud.label.text = @"下载中";
                                                             
                                                             dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                                                 
                                                                 [self downloadDB];
                                                                 
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                 });
                                                                 
                                                             });
                                                             
                                                         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
