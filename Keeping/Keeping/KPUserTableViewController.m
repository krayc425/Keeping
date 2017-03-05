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
#import "SCLAlertView.h"
#import "DateUtil.h"

@interface KPUserTableViewController ()

@end

@implementation KPUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"用户信息"];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
    
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
    
    [self setLatestLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setFont{
    for(UILabel *lbl in self.labels) {
        [lbl setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    }
}

#pragma mark - DB Actions

- (void)uploadDB{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.label.text = @"上传中";
    
    __block BOOL succeeded;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //备份任务数据库
        AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
        [query whereKey:@"userID" equalTo:self.currentUser.objectId];
        
        if(query.countObjects == 0){
            
            AVObject *dbBackUp = [AVObject objectWithClassName:@"dbBackUp"];
            [dbBackUp setObject:self.currentUser.objectId forKey:@"userID"];
            AVFile *f = [AVFile fileWithName:@"" contentsAtPath:[[DBManager shareInstance] getDBPath]];
            [dbBackUp setObject:f forKey:@"db"];
            
            succeeded = [dbBackUp save];
            
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
            
            succeeded = [dbBackUp save];
        }
        //备份类别
        
        AVQuery *typeQuery = [AVQuery queryWithClassName:@"typeBackUp"];
        [typeQuery whereKey:@"userID" equalTo:self.currentUser.objectId];
        if(typeQuery.countObjects == 0){
            
            AVObject *types = [AVObject objectWithClassName:@"typeBackUp"];
            [types setObject:self.currentUser.objectId forKey:@"userID"];
            [types setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"typeTextArr"] forKey:@"types"];
            [types save];

        }else{
            
            AVObject *types = [typeQuery getFirstObject];
            [types setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"typeTextArr"] forKey:@"types"];
            [types save];

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            if(succeeded){
                [alert showSuccess:@"上传成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
                [self setLatestLabel];
            }else{
                [alert showError:@"上传失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
            }
        });
        
    });
}

- (BOOL)hasDBOnline{
    AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
    [query whereKey:@"userID" equalTo:self.currentUser.objectId];
    return query.countObjects != 0;
}

- (long long)getDBOnlineFileSize{
    AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
    [query whereKey:@"userID" equalTo:self.currentUser.objectId];
    AVObject *dbBackUp = [query getFirstObject];
    AVFile *file = [dbBackUp objectForKey:@"db"];
    return file.size;
}

- (void)downloadDB{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    hud.label.text = @"下载中";
    
    __block BOOL succeeded;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        //任务数据库
        AVQuery *query = [AVQuery queryWithClassName:@"dbBackUp"];
        [query whereKey:@"userID" equalTo:self.currentUser.objectId];
        AVObject *dbBackUp = [query getFirstObject];
        AVFile *file = [dbBackUp objectForKey:@"db"];
        [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            [[[DBManager shareInstance] getDB] close];
            
            [[NSFileManager defaultManager] createFileAtPath:[[DBManager shareInstance] getDBPath] contents:data attributes:nil];
            
            [[DBManager shareInstance] establishDB];
            
            succeeded = !error;
        }];
        
        //任务类别
        AVQuery *typeQuery = [AVQuery queryWithClassName:@"typeBackUp"];
        [typeQuery whereKey:@"userID" equalTo:self.currentUser.objectId];
        if(typeQuery.countObjects > 0){
            AVObject *type = [typeQuery getFirstObject];
            NSLog(@"%@",type.description);
            NSLog(@"%@", [[type objectForKey:@"types"]description]);
            [[NSUserDefaults standardUserDefaults] setObject:[type objectForKey:@"types"] forKey:@"typeTextArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            if(succeeded){
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showSuccess:@"下载成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
            }else{
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showError:@"下载失败" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
            }
        });
        
    });
    
}

#pragma mark - User Info Actions

- (void)setLatestLabel{
    AVQuery *dbQuery = [AVQuery queryWithClassName:@"dbBackUp"];
    [dbQuery whereKey:@"userID" equalTo:self.currentUser.objectId];
    if(dbQuery.countObjects != 0){
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        [self.uploadTimeLabel setText:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[dbQuery getFirstObject].updatedAt]]];
    }else{
        [self.uploadTimeLabel setText:@""];
    }
}

- (void)logout{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"登出" actionBlock:^{
        [AVUser logOut];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showWarning:@"确认登出吗" subTitle:nil closeButtonTitle:@"取消" duration:0.0f];
}

- (void)editUsername{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    UITextField *usernameText = [alert addTextField:@"用户名"];
    [alert addButton:@"提交" validationBlock:^BOOL{
        //检查是否有重复用户名
        AVQuery *duplicateNameQuery = [AVQuery queryWithClassName:@"username"];
        [duplicateNameQuery whereKey:@"username" equalTo:usernameText.text];
        if(duplicateNameQuery.countObjects > 0){
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showError:@"错误" subTitle:@"用户名与已有用户重复，请更换" closeButtonTitle:@"好的" duration:0.0];
        }
        return duplicateNameQuery.countObjects == 0;
        
    } actionBlock:^{
        
        AVQuery *query = [AVQuery queryWithClassName:@"username"];
        [query whereKey:@"userId" equalTo:self.currentUser.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                AVObject *user;
                
                if(query.countObjects > 0){
                    user = objects[0];
                }else{
                    user = [AVObject objectWithClassName:@"username"];
                    [user setObject:self.currentUser.objectId forKey:@"userId"];
                }
                [user setObject:usernameText.text forKey:@"username"];
                
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                    [alert showSuccess:@"修改成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
                    [alert alertIsDismissed:^{
                        [self.userNameLabel setText:[user objectForKey:@"username"]];
                    }];
                    
                }];
            }else{
                NSLog(@"错误：%@",error.description);
            }
        }];
        
    }];
    [alert showEdit:@"修改用户名" subTitle:nil closeButtonTitle:@"取消" duration:0.0];
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
        
        [self logout];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"上传" actionBlock:^{
            
            [self uploadDB];
            
        }];
        
        NSString *subtitle = [NSString stringWithFormat:@"上传后将覆盖服务器端所有数据，确定上传吗？\n注：上传将消耗约 %.2f MB 流量，建议在 WiFi 环境下上传", [[DBManager shareInstance] dbFilesize] / 1000000.0];
        [alert showWarning:@"注意" subTitle:subtitle closeButtonTitle:@"取消" duration:0.0];
        
    }else if(indexPath.section == 1 && indexPath.row == 1){
        
        if(![self hasDBOnline]){
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:@"您还没有上传过数据" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
        }else{
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addButton:@"下载" actionBlock:^{
                
                [self downloadDB];
                
            }];
            
            NSString *subtitle = [NSString stringWithFormat:@"下载后将覆盖本地所有数据，确定下载吗？\n注：下载将消耗约 %.2f MB 流量，建议在 WiFi 环境下下载", [self getDBOnlineFileSize] / 1000000.0];
            [alert showWarning:@"注意" subTitle:subtitle closeButtonTitle:@"取消" duration:0.0];
        }
        
    }else if(indexPath.section == 0 && indexPath.row == 0){
        
        [self editUsername];
        
    }
}

@end
