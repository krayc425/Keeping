//
//  KPTaskExtraTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/21.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskExtraTableViewController.h"
#import "Utilities.h"
#import "KPSeparatorView.h"
#import "KPSchemeManager.h"
#import "DateTools.h"
#import "TaskManager.h"
#import <QuartzCore/QuartzCore.h>

@interface KPTaskExtraTableViewController ()

@property (nonatomic, assign) UIView *background;   //图片放大的背景

@end

@implementation KPTaskExtraTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"附加选项"];
    self.clearsSelectionOnViewWillAppear = NO;
    
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    //提醒标签
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
    //提醒开关
    [self.reminderSwitch setOn:NO];
    [self.reminderSwitch setTintColor:[Utilities getColor]];
    [self.reminderSwitch setOnTintColor:[Utilities getColor]];
    [self.reminderSwitch addTarget:self action:@selector(showReminderPickerAction:) forControlEvents:UIControlEventValueChanged];
    //APP名字标签
    [self.appNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
    //图片
    self.selectedImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageViewAction)];
    [self.selectedImgView addGestureRecognizer:tapGesture];
    
    //对星期排序
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.task.reminderDays];
    [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *n1 = (NSNumber *)obj1;
        NSNumber *n2 = (NSNumber *)obj2;
        NSComparisonResult result = [n1 compare:n2];
        return result == NSOrderedDescending;
    }];
    self.task.reminderDays = arr;
    //加载原始数据
    if(self.task.id != 0){
        self.selectedApp = self.task.appScheme;
        if(self.selectedApp != NULL){
            [self.appNameLabel setText:self.selectedApp.allKeys[0]];
        }
        self.reminderTime = self.task.reminderTime;
        if(self.reminderTime != NULL){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
            [self.reminderLabel setText:currentDateStr];
            [self.reminderSwitch setOn:YES];
        }
        if(self.task.image != nil){
            [self.selectedImgView setImage:[UIImage imageWithData:self.task.image]];
        }
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doneAction:(id)sender{
    
    NSLog(@"%@",self.task.name);
    //app 名
    self.task.appScheme = self.selectedApp;
    //提醒时间
    self.task.reminderTime = self.reminderTime;
    //图片
    self.task.image = UIImagePNGRepresentation(self.selectedImgView.image);
    //更新
    NSString *title;
    if(self.task.id == 0){
        NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
        self.task.addDate = addDate;
        self.task.punchDateArr = [[NSMutableArray alloc] init];
        
        [[TaskManager shareInstance] addTask:self.task];
        title = @"新增成功";
    }else{
        [[TaskManager shareInstance] updateTask:self.task];
        title = @"修改成功";
    }
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:title
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action){
                                                         [self.navigationController popToRootViewControllerAnimated:YES];
                                                     }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showReminderPickerAction:(id)sender{
    if(![self.reminderSwitch isOn]){
        [self.reminderLabel setText:@"无"];
    }else{
        NSDate *date = (NSDate *)sender;
        [self performSegueWithIdentifier:@"reminderSegue" sender:date];
    }
}

- (void)modifyPic{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择一张照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                             imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                                                             [self presentViewController:imagePickerController animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:@"从相册选取"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                             [self presentViewController:imagePickerController animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [alert addAction:cameraAction];
    }
    
    [alert addAction:photosAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clickImageViewAction{
    [self.navigationController.navigationBar setHidden:YES];
    //创建一个黑色背景, 初始化一个用来当做背景的View。
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64)];
    self.background = bgView;
    [bgView setBackgroundColor:[UIColor colorWithRed:0/250.0 green:0/250.0 blue:0/250.0 alpha:1.0]];
    
    //创建显示图像的视图
    //初始化要显示的图片内容的imageView
    UIImageView *browseImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64)];
    browseImgView.contentMode = UIViewContentModeScaleAspectFit;
    browseImgView.image = self.selectedImgView.image;
    [bgView addSubview:browseImgView];
    
    browseImgView.userInteractionEnabled = YES;
    //添加点击手势（即点击图片后退出全屏）
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    [browseImgView addGestureRecognizer:tapGesture];
    
    [self.tableView addSubview:bgView];
}

- (void)closeView{
    [self.background removeFromSuperview];
    [self.navigationController.navigationBar setHidden:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2){
        return self.view.frame.size.width;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
    switch (section) {
        case 0:
            [view setText:@"提醒时间"];
            break;
        case 1:
            [view setText:@"选择 APP"];
            break;
        case 2:
            [view setText:@"图片"];
            break;
        default:
            [view setText:@""];
            break;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && indexPath.row == 0){
        [self showReminderPickerAction:[NSDate date]];
    }
    if(indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"appSegue" sender:nil];
    }
    if(indexPath.section == 2 && indexPath.row == 0){
        [self modifyPic];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"appSegue"]){
        KPSchemeTableViewController *kpstvc = (KPSchemeTableViewController *)[segue destinationViewController];
        kpstvc.delegate = self;
        if(self.selectedApp != NULL){
            [kpstvc setSelectedPath:[NSIndexPath indexPathForRow:[[KPSchemeManager getSchemeArr] indexOfObject:self.selectedApp] inSection:1]];
        }else{
            [kpstvc setSelectedPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
    }else if([segue.identifier isEqualToString:@"reminderSegue"]){
        KPReminderViewController *kprvc = (KPReminderViewController *)[segue destinationViewController];
        kprvc.delegate = self;
        [kprvc.timePicker setPickingDate:(NSDate *)sender];
    }
}

#pragma mark - Scheme Delegate

- (void)passScheme:(NSDictionary *)value{
    if([value.allKeys[0] isEqualToString:@""]){
        self.selectedApp = NULL;
        [self.appNameLabel setText:@"无"];
        [self.tableView reloadData];
    }else{
        self.selectedApp = value;
        [self.appNameLabel setText:self.selectedApp.allKeys[0]];
        [self.tableView reloadData];
    }
}

#pragma mark - Reminder Delegate

- (void)passTime:(NSDate *)date{
    if(date == nil){
        self.reminderTime = nil;
        [self.reminderSwitch setOn:NO animated:YES];
        [self.reminderLabel setText:@"无"];
    }else{
        self.reminderTime = date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
        [self.reminderLabel setText:currentDateStr];
    }
    [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.selectedImgView setImage:image];
}

@end
