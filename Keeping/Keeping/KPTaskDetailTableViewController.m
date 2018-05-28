//
//  KPTaskDetailTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/20.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskDetailTableViewController.h"
#import "TaskManager.h"
#import "Utilities.h"
#import "KPSeparatorView.h"
#import "DateUtil.h"
#import "DateTools.h"
#import "KPSchemeTableViewController.h"
#import "KPSchemeManager.h"
#import "ImageUtil.h"
#import "SCLAlertView.h"
#import "IDMPhotoBrowser.h"

#define ENDLESS_STRING @"无限期"
#define DATE_FORMAT @"yyyy/MM/dd"

@interface KPTaskDetailTableViewController ()

@end

@implementation KPTaskDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    //导航栏左上角
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_BACK"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItems = @[cancelItem];
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(doneAction:)];
    //不能编辑==过期==没有右上角
    if([self.tableView isUserInteractionEnabled]){
        self.navigationItem.rightBarButtonItems = @[okItem];
    }
    
    //任务名
    [self.taskNameField setFont:[UIFont systemFontOfSize:20.0f]];
    self.taskNameField.layer.borderWidth = 1.0;
    self.taskNameField.layer.cornerRadius = 5.0;
    self.taskNameField.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.taskNameField.delegate = self;
    
    //持续时间
    for(UILabel *label in self.durationStack.subviews){
        [label setFont:[UIFont systemFontOfSize:20.0f]];
    }
    
    //星期代理
    self.weekdayView.weekdayDelegate = self;
    self.weekdayView.isAllSelected = NO;
    self.weekdayView.fontSize = 18.0;
    self.weekdayView.isAllButtonHidden = NO;
    
    //类别代理
    self.colorView.colorDelegate = self;
    
    //提醒标签
    [self.reminderLabel setFont:[UIFont systemFontOfSize:20.0f]];
    //提醒开关
    [self.reminderSwitch setTintColor:[Utilities getColor]];
    [self.reminderSwitch setOnTintColor:[Utilities getColor]];
    [self.reminderSwitch addTarget:self action:@selector(showReminderPickerAction:) forControlEvents:UIControlEventValueChanged];
    
    //APP名字标签
    [self.appNameLabel setFont:[UIFont systemFontOfSize:20.0f]];
    
    //图片
    self.selectedImgView.userInteractionEnabled = YES;
    for(UIButton *button in self.imgButtonStack.subviews){
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    }
    
    //链接
    [self.linkTextField setFont:[UIFont systemFontOfSize:15.0f]];
    self.linkTextField.layer.borderWidth = 1.0;
    self.linkTextField.layer.cornerRadius = 5.0;
    self.linkTextField.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.linkTextField.delegate = self;
    
    //开始、到期日期颜色
    [self.startDateButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    [self.endDateButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    [self.startDateButton.titleLabel sizeToFit];
    [self.endDateButton.titleLabel sizeToFit];
    
    //备注
    self.memoTextView.delegate = self;
    [self.memoTextView setTextColor:[Utilities getColor]];
    [self.memoTextView setFont:[UIFont systemFontOfSize:15.0f]];
    self.memoTextView.layer.borderWidth = 1.0;
    self.memoTextView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.memoTextView.layer.cornerRadius = 5.0;
    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"点击输入备注";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [placeHolderLabel setFont:[UIFont systemFontOfSize:15.0f]];
    placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    [self.memoTextView addSubview:placeHolderLabel];
    [self.memoTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    //加载任务
    if(self.task != NULL){
        [self.navigationItem setTitle:@"任务详情"];
        
        [self.taskNameField setText:[self.task name]];
        
        self.selectedWeekdayArr = [NSMutableArray arrayWithArray:self.task.reminderDays];
        [self.weekdayView selectWeekdaysInArray:self.selectedWeekdayArr];
        
        [self.startDateButton setTitle:[self.task.addDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        if(self.task.endDate != NULL){
            [self.endDateButton setTitle:[self.task.endDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
            
            //如果已经超期，不能编辑
            //            if([self.task.endDate isEarlierThan:[NSDate date]]){
            //                [self.tableView setUserInteractionEnabled:NO];
            //            }else{
            //                [self.tableView setUserInteractionEnabled:YES];
            //            }
            
        }else{
            [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
        }
        
        //对星期排序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.task.reminderDays];
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *n1 = (NSNumber *)obj1;
            NSNumber *n2 = (NSNumber *)obj2;
            NSComparisonResult result = [n1 compare:n2];
            return result == NSOrderedDescending;
        }];
        self.task.reminderDays = arr;
        
        self.reminderTime = self.task.reminderTime;
        if(self.reminderTime != NULL){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
            [self.reminderLabel setText:currentDateStr];
            [self.reminderSwitch setOn:YES];
        }else{
            [self.reminderLabel setText:@"无"];
            [self.reminderSwitch setOn:NO];
        }
        
        self.selectedApp = NULL;
        for(KPScheme *s in [[KPSchemeManager shareInstance] getSchemeArr]){
            if([s.name isEqualToString:self.task.appScheme.allKeys[0]]){
                self.selectedApp = s;
            }
        }
        if(self.selectedApp != NULL){
            [self.appNameLabel setText:self.selectedApp.name];
        }else{
            [self.appNameLabel setText:@"无"];
        }
        
        if(self.task.image != NULL){
            [self.selectedImgView setImage:[UIImage imageWithData:self.task.image]];
            [self setHasImage];
        }else{
            [self setNotHaveImage];
        }
        
        [self.linkTextField setText:self.task.link];
        
        [self.memoTextView setText:self.task.memo];
        
        self.selectedColorNum = self.task.type;
        [self.colorView setSelectedColorNum:self.selectedColorNum];
        
        [self.tableView reloadData];
    }else{
        [self.navigationItem setTitle:@"新增任务"];
        
        [self.startDateButton setTitle:[[NSDate date] formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
        
        self.selectedWeekdayArr = [[NSMutableArray alloc] init];
        [self.reminderSwitch setOn:NO];
        
        [self setNotHaveImage];
        
        [self.taskNameField becomeFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)checkCompleted{
    if([self.taskNameField.text isEqualToString:@""]){
        return NO;
    }
    if([self.selectedWeekdayArr count] <= 0){
        return NO;
    }
    return YES;
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender{
    
    //先检查有没有填满必填信息
    if(![self checkCompleted]){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showError:@"信息填写不完整" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
        [alert alertIsDismissed:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
        return;
    }
    
    NSDate *titleStartDate = [NSDate dateWithString:self.startDateButton.titleLabel.text formatString:DATE_FORMAT];
    NSDate *titleEndDate = [NSDate dateWithString:self.endDateButton.titleLabel.text formatString:DATE_FORMAT];
    //检查结束日期是否合法
    if([titleEndDate isEarlierThan:titleStartDate]){
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showError:@"持续时间设置不正确" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
        [alert alertIsDismissed:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }];
        return;
    }
    
    if(self.task == NULL){
        self.task = [Task new];
    }
    
    //任务名
    self.task.name = self.taskNameField.text;
    //app 名
    if(self.selectedApp == NULL){
        self.task.appScheme = NULL;
    }else{
        self.task.appScheme = @{self.selectedApp.name : self.selectedApp.scheme};
    }
    //提醒时间
    self.task.reminderTime = self.reminderTime;
    //图片
    if(self.selectedImgView.image == NULL){
        self.task.image = NULL;
    }else{
        self.task.image = UIImageJPEGRepresentation([ImageUtil normalizedImage:self.selectedImgView.image], 1.0);
        NSLog(@"img size : %lu", self.task.image.length);
    }
    //链接
    self.task.link = self.linkTextField.text;       //有：文字，无：@“”
    //开始日期
    self.task.addDate = titleStartDate;
    //结束日期
    if([self.endDateButton.titleLabel.text isEqualToString:ENDLESS_STRING]){
        self.task.endDate = NULL;
    }else{
        self.task.endDate = titleEndDate;
    }
    //备注
    self.task.memo = self.memoTextView.text;
    //类别
    self.task.type = self.selectedColorNum;
    
    //更新
    if(self.task.id == 0){
        
        self.task.punchDateArr = [[NSMutableArray alloc] init];
        self.task.punchMemoArr = [[NSMutableArray alloc] init];

        //完成时间
        //对星期排序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.selectedWeekdayArr];
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *n1 = (NSNumber *)obj1;
            NSNumber *n2 = (NSNumber *)obj2;
            NSComparisonResult result = [n1 compare:n2];
            return result == NSOrderedDescending;
        }];
        //赋值
        self.task.reminderDays = arr;
        
        //增加
        [[TaskManager shareInstance] addTask:self.task];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showSuccess:@"新增成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
        [alert alertIsDismissed:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        //完成时间排序
        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.selectedWeekdayArr];
        [arr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *n1 = (NSNumber *)obj1;
            NSNumber *n2 = (NSNumber *)obj2;
            NSComparisonResult result = [n1 compare:n2];
            return result == NSOrderedDescending;
        }];
        self.selectedWeekdayArr = arr;
        
        if(![self.task.reminderDays isEqual:arr]){
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            
            [alert addButton:@"仍然更改" actionBlock:^(void) {
                
                //更新初始日期、打卡数组和提醒日期
                self.task.reminderDays = arr;
                
                NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
                self.task.addDate = addDate;
                self.task.punchDateArr = [[NSMutableArray alloc] init];
                
                [[TaskManager shareInstance] updateTask:self.task];
                
                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                [alert showSuccess:@"修改成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
                [alert alertIsDismissed:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            }];
            
            [alert showWarning:@"注意" subTitle:@"您更改了预计完成日的选项，这会导致今天之前的打卡记录清空，新的记录将从今天开始重新计算。\n您要继续吗？" closeButtonTitle:@"取消" duration:0.0f];
            
        }else{
            
            [[TaskManager shareInstance] updateTask:self.task];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showSuccess:@"修改成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0f];
            [alert alertIsDismissed:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }

    }
}

#pragma mark - Color Type Selection

- (IBAction)selectColorAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(self.selectedColorNum == (int)button.tag){
        self.selectedColorNum = -1;
    }else{
        self.selectedColorNum = (int)button.tag;
    }
    self.colorView.selectedColorNum = self.selectedColorNum;
}

#pragma mark - Reminder Actions

- (void)showReminderPickerAction:(id)sender{
    if(![self.reminderSwitch isOn]){
        self.reminderTime = NULL;
        [self.reminderLabel setText:@"无"];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择提醒时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH - 20, 250)];
        datePicker.tintColor = [Utilities getColor];
        datePicker.datePickerMode = UIDatePickerModeTime;
        [alert.view addSubview:datePicker];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.reminderTime = datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
            [self.reminderLabel setText:currentDateStr];
            [self.tableView reloadData];
        }];
        [alert addAction:okAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];

        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:datePicker.frame.size.height + 120];
        [alert.view addConstraint:heightConstraint];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Pic Actions

- (IBAction)appSetIconAction:(id)sender{
    if(self.selectedApp == NULL){
        return;
    }
    AVFile *file = self.selectedApp.iconFile;
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        [self.selectedImgView setImage:[ImageUtil normalizedImage:[UIImage imageWithData:data]]];
    }];
    [self setHasImage];
}

- (IBAction)deletePicAction:(id)sender{
    if(self.selectedImgView.image == [UIImage new]){
        return;
    }else{
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"删除" actionBlock:^{
            [self setNotHaveImage];
        }];
        [alert showWarning:@"删除照片" subTitle:@"您确定要删除这张照片？" closeButtonTitle:@"取消" duration:0.0];

    }
}

- (IBAction)modifyPicAction:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择一张照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if(self.selectedApp != NULL && ![self.appNameLabel.text isEqualToString:@"无"]){
        UIAlertAction *appAction = [UIAlertAction actionWithTitle:@"选择 APP 图标"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             AVFile *file = self.selectedApp.iconFile;
                                                             
                                                             [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:8] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                                                             
                                                             [file getThumbnail:YES
                                                                          width:self.view.frame.size.width
                                                                         height:self.view.frame.size.width
                                                                      withBlock:^(UIImage * _Nullable image, NSError * _Nullable error) {
                                                                          
                                                                          [self setHasImage];
                                                                          [self.selectedImgView setImage:[ImageUtil normalizedImage:image]];
                                                                                                                            
                                                             }];

                                                         }];
        [alert addAction:appAction];
    }
    
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

- (IBAction)clickPicAction:(id)sender{
    if(self.selectedImgView.image == [UIImage new]){
        return;
    }else{
        IDMPhoto *photo = [IDMPhoto photoWithImage:self.selectedImgView.image];
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)setHasImage{
    [self.addImgButton setTitle:@"更改图片" forState: UIControlStateNormal];
    [self.viewImgButton setHidden:NO];
    [self.deleteImgButton setHidden:NO];
    [self.deleteImgButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.tableView reloadData];
}

- (void)setNotHaveImage{
    self.task.image = NULL;
    [self.selectedImgView setImage:NULL];
    
    [self.addImgButton setTitle:@"添加图片" forState: UIControlStateNormal];
    [self.viewImgButton setHidden:YES];
    [self.deleteImgButton setHidden:YES];
    [self.tableView reloadData];
}

#pragma mark - Select end date

- (IBAction)selectDateAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self showDatePickerWithStartOrEnd:(int)btn.tag];
}

- (void)showDatePickerWithStartOrEnd:(int)type{
    //type:
    //      0 : 开始
    //      1 : 结束
    HSDatePickerViewController *hsdpvc = [[HSDatePickerViewController alloc] init];
    hsdpvc.delegate = self;
    
    hsdpvc.backButtonTitle = @"返回";
    hsdpvc.confirmButtonTitle = @"确定";
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:DATE_FORMAT];
    hsdpvc.dateFormatter = fmt;
    
    NSDateFormatter *myfmt = [[NSDateFormatter alloc] init];
    [myfmt setDateFormat:@"yyyy 年 MM 月"];
    hsdpvc.monthAndYearLabelDateFormater = myfmt;
    
    //设置时开始日期还是结束日期
    hsdpvc.timeType = type;
    
    if(type == 0){
        
    }else{
        //让他结束日期可以是今天
        NSDate *minDate = [NSDate dateWithString:self.startDateButton.titleLabel.text formatString:DATE_FORMAT];
        hsdpvc.minDate = [minDate dateByAddingDays:-1];
    }
    
    [self presentViewController:hsdpvc animated:YES completion:nil];
}

- (void)hsDatePickerPickedDate:(NSDictionary *)dateDict{
    if(dateDict == NULL){
        //无限期，只能是结束日期
        [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
    }else{
        NSDate *date = [dateDict valueForKey:@"date"];
        if([[dateDict valueForKey:@"type"] intValue] == 0){
            NSDate *addDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
            [self.startDateButton setTitle:[addDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        }else{
            NSDate *endDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
            [self.endDateButton setTitle:[endDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
    switch (section) {
        case 0:
            [view setText:@"任务名"];
            break;
        case 1:
            [view setText:@"完成时间"];
            break;
        case 2:
            [view setText:@"持续时间"];
            break;
        case 3:
            [view setText:@"类别"];
            break;
        case 4:
            [view setText:@"提醒时间"];
            break;
        case 5:
            [view setText:@"备注"];
            break;
        case 6:
            [view setText:@"打开 APP"];
            break;
        case 7:
            [view setText:@"链接"];
            break;
        case 8:
            [view setText:@"图片"];
            break;
        default:
            [view setText:@""];
            break;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 4:
            [self showReminderPickerAction:[NSDate date] ];
            break;
        case 6:
            [self performSegueWithIdentifier:@"appSegue" sender:nil];
            break;
        case 8:
            [self modifyPicAction:nil];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 8){
        return self.selectedImgView.image == NULL ? 40.0f : self.view.frame.size.width;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (void)pickerDoneClicked{
    [self.memoTextView resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"appSegue"]){
        KPSchemeTableViewController *kpstvc = (KPSchemeTableViewController *)[segue destinationViewController];
        kpstvc.delegate = self;
        if(self.selectedApp != NULL){
            [kpstvc setSelectedApp:self.selectedApp];
        }else{
            [kpstvc setSelectedApp:NULL];
        }
    }
}

#pragma mark - Scheme Delegate

- (void)passScheme:(KPScheme *)scheme{
    if(scheme == NULL){
        self.selectedApp = NULL;
        [self.appNameLabel setText:@"无"];
    }else{
        self.selectedApp = scheme;
        [self.appNameLabel setText:scheme.name];
    }
    [self.tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //原图还是编辑过的图？
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.selectedImgView setImage:[ImageUtil normalizedImage:image]];
    [self setHasImage];
}

#pragma mark - KPWeekdayPickerDelegate

- (void)didChangeWeekdays:(NSArray *_Nonnull)selectWeekdays{
    self.selectedWeekdayArr = [NSMutableArray arrayWithArray:selectWeekdays];
}

#pragma mark - KPColorPickerDelegate

- (void)didChangeColors:(int)selectColorNum{
    self.selectedColorNum = selectColorNum;
}

@end
