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
#import "UIView+MJAlertView.h"
#import "DateUtil.h"
#import "DateTools.h"
#import "KPImageViewController.h"
#import "KPSchemeTableViewController.h"
#import "KPReminderViewController.h"
#import "KPSchemeManager.h"

#define ENDLESS_STRING @"无限期"
#define DATE_FORMAT @"yyyy/MM/dd"

@interface KPTaskDetailTableViewController ()

@end

@implementation KPTaskDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    //导航栏左上角
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_CANCEL"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItems = @[cancelItem];
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    //不能编辑==过期==没有右上角
    if([self.tableView isUserInteractionEnabled]){
        self.navigationItem.rightBarButtonItems = @[okItem];
    }
    
    
    //任务名
    [self.taskNameField setFont:[UIFont fontWithName:[Utilities getFont] size:25.0f]];
    self.taskNameField.layer.borderWidth = 1.0;
    self.taskNameField.layer.cornerRadius = 5.0;
    self.taskNameField.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.taskNameField.delegate = self;
    
    
    //持续时间
    for(UILabel *label in self.durationStack.subviews){
        [label setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    }
    
    
    //星期代理
    self.weekdayView.weekdayDelegate = self;
    self.weekdayView.isAllSelected = NO;
    self.weekdayView.fontSize = 18.0;
    self.weekdayView.isAllButtonHidden = NO;
    
    
    
    //类别代理
    self.colorView.colorDelegate = self;
    
    
    //提醒标签
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    //提醒开关
    [self.reminderSwitch setTintColor:[Utilities getColor]];
    [self.reminderSwitch setOnTintColor:[Utilities getColor]];
    [self.reminderSwitch addTarget:self action:@selector(showReminderPickerAction:) forControlEvents:UIControlEventValueChanged];
    
    
    //APP名字标签
    [self.appNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    
    
    //图片
    self.selectedImgView.userInteractionEnabled = YES;
    for(UIButton *button in self.imgButtonStack.subviews){
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    }
    
    
    //链接
    [self.linkTextField setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    self.linkTextField.layer.borderWidth = 1.0;
    self.linkTextField.layer.cornerRadius = 5.0;
    self.linkTextField.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.linkTextField.delegate = self;
    
    
    //开始、到期日期颜色
    [self.startDateButton setUserInteractionEnabled:NO];
    [self.startDateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.endDateButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    [self.startDateButton.titleLabel sizeToFit];
    [self.endDateButton.titleLabel sizeToFit];
    
    
    //备注
    self.memoTextView.delegate = self;
    [self.memoTextView setTextColor:[Utilities getColor]];
    [self.memoTextView setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    self.memoTextView.layer.borderWidth = 1.0;
    self.memoTextView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.memoTextView.layer.cornerRadius = 5.0;
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = NO;
    keyboardDoneButtonView.backgroundColor = [Utilities getColor];
    keyboardDoneButtonView.tintColor = [Utilities getColor];
    keyboardDoneButtonView.barTintColor = [Utilities getColor];
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                       style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(pickerDoneClicked)];
    doneButton.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView setItems:@[spaceButton, doneButton]];
    self.memoTextView.inputAccessoryView = keyboardDoneButtonView;
    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"点击输入备注";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [placeHolderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    placeHolderLabel.textAlignment = NSTextAlignmentCenter;
    [self.memoTextView addSubview:placeHolderLabel];
    [self.memoTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    
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
        }else{
            [self.reminderLabel setText:@"无"];
            [self.reminderSwitch setOn:NO];
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

- (void)hideKeyboard{
    if([self.taskNameField isFirstResponder]){
        [self.taskNameField resignFirstResponder];
    }
    if([self.linkTextField isFirstResponder]){
        [self.linkTextField resignFirstResponder];
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

- (void)nextAction:(id)sender{
    if(![self checkCompleted]){
        [UIView addMJNotifierWithText:@"信息填写不完整" dismissAutomatically:YES];
    }else{
        [self performSegueWithIdentifier:@"addExtraSegue" sender:nil];
    }
}

- (void)doneAction:(id)sender{
    
    //先检查有没有填满必填信息
    if(![self checkCompleted]){
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"信息填写不完整"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler: nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if(self.task == NULL){
        self.task = [Task new];
    }
    
    //任务名
    self.task.name = self.taskNameField.text;
    //app 名
    self.task.appScheme = self.selectedApp;
    //提醒时间
    self.task.reminderTime = self.reminderTime;
    //图片
    self.task.image = UIImagePNGRepresentation(self.selectedImgView.image);
    //链接
    self.task.link = self.linkTextField.text;       //有：文字，无：@“”
    //结束日期
    if([self.endDateButton.titleLabel.text isEqualToString:ENDLESS_STRING]){
        self.task.endDate = NULL;
    }else{
        self.task.endDate = [NSDate dateWithString:self.endDateButton.titleLabel.text formatString:DATE_FORMAT];
    }
    //备注
    self.task.memo = self.memoTextView.text;
    //类别
    self.task.type = self.selectedColorNum;
    
    //更新
    if(self.task.id == 0){
        
        //添加日期，打卡数组
        NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
        self.task.addDate = addDate;
        self.task.punchDateArr = [[NSMutableArray alloc] init];

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
        
        //提示
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"新增成功"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             [self.navigationController popToRootViewControllerAnimated:YES];
                                                         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
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
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"注意"
                                                message:@"您更改了预计完成日的选项，这会导致今天之前的打卡记录清空，新的记录将从今天开始重新计算。您要继续吗？"
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action){
                                                                     
                                                                     [[TaskManager shareInstance] updateTask:self.task];
                                                                     
                                                                     UIAlertController *alertController =
                                                                     [UIAlertController alertControllerWithTitle:@"修改成功"
                                                                                                         message:nil
                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                                                     UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                                                                                        style:UIAlertActionStyleDefault
                                                                                                                      handler:^(UIAlertAction *action){
                                                                                                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                                                      }];
                                                                     [alertController addAction:okAction];
                                                                     [self presentViewController:alertController animated:YES completion:nil];
                                                                 }];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"仍然更改"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){
                                                                 
                                                                 //更新厨师日期、打卡数组和提醒日期
                                                                 self.task.reminderDays = arr;
                                                                 
                                                                 NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
                                                                 self.task.addDate = addDate;
                                                                 self.task.punchDateArr = [[NSMutableArray alloc] init];
                                                                 
                                                                 [[TaskManager shareInstance] updateTask:self.task];
                                                                 
                                                                 UIAlertController *alertController =
                                                                 [UIAlertController alertControllerWithTitle:@"修改成功"
                                                                                                     message:nil
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                                                 UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                                                                                    style:UIAlertActionStyleDefault
                                                                                                                  handler:^(UIAlertAction *action){
                                                                                                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                                                                                                  }];
                                                                 [alertController addAction:okAction];
                                                                 [self presentViewController:alertController animated:YES completion:nil];
                                                             }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            
            [[TaskManager shareInstance] updateTask:self.task];
            
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"修改成功"
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
        NSDate *date = (NSDate *)sender;
        [self performSegueWithIdentifier:@"reminderSegue" sender:date];
    }
}

#pragma mark - Pic Actions

- (IBAction)deletePicAction:(id)sender{
    if(self.selectedImgView.image == [UIImage new]){
        return;
    }else{
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"删除图片"
                                            message:@"您确定要删除这张图片？"
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction *action){
                                                             [self setNotHaveImage];
                                                         }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)modifyPicAction:(id)sender{
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

- (IBAction)clickPicAction:(id)sender{
    if(self.selectedImgView.image == [UIImage new]){
        return;
    }else{
        [self performSegueWithIdentifier:@"imageSegue" sender:self.selectedImgView.image];
    }
}

- (UIImage *)normalizedImage:(UIImage *)img {
    if (img.imageOrientation == UIImageOrientationUp){
        return img;
    }
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [img drawInRect:(CGRect){0, 0, img.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
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
    
    hsdpvc.timeType = type;
    
    if(type == 0){
        
    }else{
        hsdpvc.minDate = [NSDate date];
    }
    
    [self presentViewController:hsdpvc animated:YES completion:nil];
}

- (void)hsDatePickerPickedDate:(NSDate *)date{
    if(date == NULL){
        [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
    }else{
        NSDate *endDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
        [self.endDateButton setTitle:[endDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
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
    return 30.0f;
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
        return self.view.frame.size.width;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return YES;
}

- (void)pickerDoneClicked{
    [self.memoTextView resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"appSegue"]){
        KPSchemeTableViewController *kpstvc = (KPSchemeTableViewController *)[segue destinationViewController];
        kpstvc.delegate = self;
        if(self.selectedApp != NULL){
            [kpstvc setSelectedPath:[NSIndexPath indexPathForRow:[[[KPSchemeManager shareInstance] getSchemeArr] indexOfObject:self.selectedApp] inSection:1]];
        }else{
            [kpstvc setSelectedPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
    }else if([segue.identifier isEqualToString:@"reminderSegue"]){
        KPReminderViewController *kprvc = (KPReminderViewController *)[segue destinationViewController];
        kprvc.delegate = self;
        [kprvc.timePicker setPickingDate:(NSDate *)sender];
    }else if([segue.identifier isEqualToString:@"imageSegue"]){
        KPImageViewController *imageVC = (KPImageViewController *)[segue destinationViewController];
        [imageVC setImg:(UIImage *)sender];
    }
}

#pragma mark - Scheme Delegate

- (void)passScheme:(NSDictionary *)value{
    if([value.allKeys[0] isEqualToString:@""]){
        self.selectedApp = NULL;
        [self.appNameLabel setText:@"无"];
    }else{
        self.selectedApp = value;
        [self.appNameLabel setText:self.selectedApp.allKeys[0]];
    }
    [self.tableView reloadData];
}

#pragma mark - Reminder Delegate

- (void)passTime:(NSDate *)date{
    if(date == NULL){
        self.reminderTime = NULL;
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
    //原图还是编辑过的图？
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.selectedImgView setImage:[self normalizedImage:image]];
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
