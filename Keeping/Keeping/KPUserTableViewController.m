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
#import "DateUtil.h"
#import "DateTools.h"

@interface KPUserTableViewController ()

@end

@implementation KPUserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"备份"];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
    
    AVQuery *query = [AVQuery queryWithClassName:@"username"];
    [query whereKey:@"userId" equalTo:[AVUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSInteger days = 0;
            NSString *username = @"";
            if(query.countObjects > 0){
                AVObject *user = objects[0];
                username = [user objectForKey:@"username"];
                days = [[NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]] daysFrom:[NSDate dateWithYear:user.createdAt.year month:user.createdAt.month day:user.createdAt.day]];
            }else{
                username = [[AVUser currentUser] valueForKey:@"username"];
                days = [[NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]] daysFrom:[NSDate dateWithYear:[AVUser currentUser].createdAt.year month:[AVUser currentUser].createdAt.month day:[AVUser currentUser].createdAt.day]];
            }
            [self.joinDaysLabel setText:[NSString stringWithFormat:@"已加入 %ld 天", (long)days]];
            [self.userNameLabel setText:username];
        }else{
            NSLog(@"错误：%@",error.description);
        }
    }];
    
    [self setLatestLabel];
}

- (void)setFont{
    for(UILabel *lbl in self.labels) {
        [lbl setFont:[UIFont systemFontOfSize:17.0]];
    }
}

#pragma mark - DB Actions

- (void)uploadDB{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
//    hud.label.text = @"上传中";
    
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
            if(succeeded){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self setLatestLabel];
                }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
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
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
//    hud.label.text = @"下载中";
    
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
            [[NSUserDefaults standardUserDefaults] setObject:[type objectForKey:@"types"] forKey:@"typeTextArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:succeeded ? @"下载成功" : @"下载失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认登出吗" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"登出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AVUser logOut];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:logoutAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editUsername{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改用户名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *usernameText = nil;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户名";
        usernameText = textField;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        AVQuery *duplicateNameQuery = [AVQuery queryWithClassName:@"username"];
        [duplicateNameQuery whereKey:@"username" equalTo:usernameText.text];
        if(duplicateNameQuery.countObjects > 0){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"用户名与已有用户重复，请更换" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
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
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.userNameLabel setText:[user objectForKey:@"username"]];
                        }];
                        [alert addAction:okAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }];
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改失败" message:error.description preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
        
    }];
    [alert addAction:submitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [@[@(2), @(2), @(1)][section] integerValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 2 && indexPath.row == 0){
        
        [self logout];
        
    }else if(indexPath.section == 1 && indexPath.row == 0){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"上传后将覆盖服务器端所有数据，确定上传吗？" message:[NSString stringWithFormat:@"上传将消耗约 %.2f MB 流量，建议在 WiFi 环境下上传", [[DBManager shareInstance] dbFilesize] / 1000000.0] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self uploadDB];
        }];
        [alert addAction:uploadAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if(indexPath.section == 1 && indexPath.row == 1){
        
        if(![self hasDBOnline]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您还没有上传过数据" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下载后将覆盖本地所有数据，确定下载吗？" message:[NSString stringWithFormat:@"\n注：下载将消耗约 %.2f MB 流量，建议在 WiFi 环境下下载", [self getDBOnlineFileSize] / 1000000.0] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self downloadDB];
            }];
            [alert addAction:uploadAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }else if(indexPath.section == 0 && indexPath.row == 0){
        
        [self editUsername];
        
    }
}

@end
