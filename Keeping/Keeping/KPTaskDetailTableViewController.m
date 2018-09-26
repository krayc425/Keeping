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
#import "IDMPhotoBrowser.h"

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
    
    //CardViews
    for(CardsView *cardView in self.cardsViews){
        [cardView setCornerRadius:10.0];
        [cardView setBackgroundColor:[UIColor whiteColor]];
    }
    
    //任务名
    self.taskNameField.layer.borderWidth = 1.0;
    self.taskNameField.layer.cornerRadius = 5.0;
    self.taskNameField.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.taskNameField.delegate = self;
    
    //星期代理
    self.weekdayView.weekdayDelegate = self;
    self.weekdayView.isAllSelected = NO;
    self.weekdayView.fontSize = 15.0;
    self.weekdayView.isAllButtonHidden = YES;
    
    //类别代理
    self.colorView.colorStack.spacing = 6;
    self.colorView.colorDelegate = self;
    
    //提醒开关
    [self.reminderSwitch setTintColor:[Utilities getColor]];
    [self.reminderSwitch setOnTintColor:[Utilities getColor]];
    [self.reminderSwitch addTarget:self action:@selector(showReminderPickerAction:) forControlEvents:UIControlEventValueChanged];
    
    //app 开关
    [self.appSwitch setTintColor:[Utilities getColor]];
    [self.appSwitch setOnTintColor:[Utilities getColor]];
    [self.appSwitch addTarget:self action:@selector(appSelectAction:) forControlEvents:UIControlEventValueChanged];
    
    //图片
    self.selectedImgView.userInteractionEnabled = YES;
    for(UIButton *button in self.imgButtonStack.subviews){
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
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
    [self.memoTextView setTextColor:[UIColor blackColor]];
    [self.memoTextView setFont:[UIFont systemFontOfSize:15.0f]];
    self.memoTextView.layer.borderWidth = 1.0;
    self.memoTextView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.memoTextView.layer.cornerRadius = 5.0;
    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = NSLocalizedString(@"Click to add memo", nil);
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightTextColor];
    [placeHolderLabel sizeToFit];
    [placeHolderLabel setFont:[UIFont systemFontOfSize:15.0f]];
    placeHolderLabel.textAlignment = NSTextAlignmentLeft;
    [self.memoTextView addSubview:placeHolderLabel];
    [self.memoTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    //加载任务
    if(self.task != NULL){
        [self.navigationItem setTitle:NSLocalizedString(@"Task detail", nil)];
        
        [self.taskNameField setText:[self.task name]];
        
        self.selectedWeekdayArr = [NSMutableArray arrayWithArray:self.task.reminderDays];
        [self.weekdayView selectWeekdaysInArray:self.selectedWeekdayArr];
        
        [self.startDateButton setTitle:[self.task.addDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        if(self.task.endDate != NULL){
            [self.endDateButton setTitle:[self.task.endDate formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
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
            [self.reminderLabel setText:NSLocalizedString(@"None", nil)];
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
            [self.appSwitch setOn:YES];
        }else{
            [self.appNameLabel setText:NSLocalizedString(@"None", nil)];
            [self.appSwitch setOn:NO];
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
        
        [self didChangeColors:self.selectedColorNum];
        
        [self.tableView reloadData];
    }else{
        [self.navigationItem setTitle:NSLocalizedString(@"Add new task", nil)];
        
        [self.startDateButton setTitle:[[NSDate date] formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
        
        self.selectedWeekdayArr = [[NSMutableArray alloc] init];
        [self.reminderSwitch setOn:NO];
        
        [self setNotHaveImage];
        
        [self.taskNameField becomeFirstResponder];
    }
    
}

- (void)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction:(id)sender{
    //先检查有没有填满必填信息
    NSString *title = @"";
    if([self.taskNameField.text isEqualToString:@""]){
        title = @"请填写任务名称";
    }else if([self.selectedWeekdayArr count] <= 0){
        title = @"请选择完成时间";
    }
    
    if(![title isEqualToString:@""]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
        return;
    }

    NSDate *titleStartDate = [NSDate dateWithString:self.startDateButton.titleLabel.text formatString:DATE_FORMAT];
    NSDate *titleEndDate = [NSDate dateWithString:self.endDateButton.titleLabel.text formatString:DATE_FORMAT];
    //检查结束日期是否合法
    if([titleEndDate isEarlierThan:titleStartDate]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"持续时间设置不正确" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    }
    //链接
    self.task.link = self.linkTextField.text;       //有：文字，无：@""
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
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新增成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"您更改了预计完成日的选项，这会导致今天之前的打卡记录清空，新的记录将从今天开始重新计算。\n您要继续吗？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"仍然更改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                //更新初始日期、打卡数组和提醒日期
                self.task.reminderDays = arr;
                
                NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
                self.task.addDate = addDate;
                self.task.punchDateArr = [[NSMutableArray alloc] init];
                
                [[TaskManager shareInstance] updateTask:self.task];
                
                [self showChangeSuccessAlert];

            }];
            [alert addAction:changeAction];
            [self presentViewController:alert animated:YES completion:nil];

        }else{
            [[TaskManager shareInstance] updateTask:self.task];

            [self showChangeSuccessAlert];
        }
    }
}

- (void)showChangeSuccessAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - App Action

- (void)appSelectAction:(UISwitch *)sender {
    UISwitch *senderSwitch = (UISwitch *)sender;
    if (senderSwitch != self.appSwitch) {
        return;
    }
    if (self.selectedApp == NULL) {
        [self performSegueWithIdentifier:@"appSegue" sender:nil];
    } else {
        self.selectedApp = NULL;
        [self.appNameLabel setText:NSLocalizedString(@"None", nil)];
    }
}

#pragma mark - Reminder Actions

- (void)showReminderPickerAction:(id)sender{
    UISwitch *senderSwitch = (UISwitch *)sender;
    if (senderSwitch != self.reminderSwitch) {
        return;
    }
    if(![self.reminderSwitch isOn]){
        self.reminderTime = NULL;
        [self.reminderLabel setText:NSLocalizedString(@"None", nil)];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择提醒时间" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, IS_IPAD ? 300 : SCREEN_WIDTH - 20, 250)];
        datePicker.tintColor = [Utilities getColor];
        datePicker.datePickerMode = UIDatePickerModeTime;
        [alert.view addSubview:datePicker];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.reminderTime = datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
            [self.reminderLabel setText:currentDateStr];
            [self.tableView reloadData];
        }];
        [alert addAction:okAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if(self.reminderSwitch.isOn){
                [self.reminderSwitch setOn:NO animated:YES];
            }
        }];
        [alert addAction:cancelAction];

        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:datePicker.frame.size.height + (IS_IPAD ? 70.0 : 120.0)];
        [alert.view addConstraint:heightConstraint];
        
        if (alert.popoverPresentationController != NULL) {
            alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            alert.popoverPresentationController.sourceView = senderSwitch;
            alert.popoverPresentationController.sourceRect = CGRectZero;
        }
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Pic Actions

- (IBAction)deletePicAction:(id)sender{
    if(self.selectedImgView.image == [UIImage new]){
        return;
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除这张图片？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self setNotHaveImage];
        }];
        [alert addAction:deleteAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)modifyPicAction:(id)sender{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose an image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    if(self.selectedApp != NULL && ![self.appNameLabel.text isEqualToString:NSLocalizedString(@"None", nil)]){
        UIAlertAction *appAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose app icon", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             AVFile *file = self.selectedApp.iconFile;
                                                             
                                                             [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                                                             
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
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take a photo", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                             imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                             [self presentViewController:imagePickerController animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Select from album", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                             [self presentViewController:imagePickerController animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
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
    [self.selectedImgView setHidden:NO];
    [self.addImgButton setTitle:NSLocalizedString(@"Change an image", nil) forState:UIControlStateNormal];
    
    [self.viewImgButton setHidden:NO];
    [self.deleteImgButton setHidden:NO];
    [self.deleteImgButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [self.tableView reloadData];
}

- (void)setNotHaveImage{
    self.task.image = NULL;
    [self.selectedImgView setImage:NULL];
    [self.selectedImgView setHidden:YES];
    
    [self.addImgButton setTitle:NSLocalizedString(@"Add an image", nil) forState:UIControlStateNormal];
    
    [self.viewImgButton setHidden:YES];
    [self.deleteImgButton setHidden:YES];
    
    [self.tableView reloadData];
}

#pragma mark - Select end date

- (IBAction)selectDateAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger type = btn.tag;
    //type:
    //      0 : 开始
    //      1 : 结束
    NSString *title = type == 0 ? @"选择开始日期" : @"选择结束日期";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, IS_IPAD ? 300 : SCREEN_WIDTH - 20, 250)];
    datePicker.tintColor = [Utilities getColor];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [alert.view addSubview:datePicker];
    
    NSString *startDateString = self.startDateButton.titleLabel.text;
    NSString *endDateString = self.endDateButton.titleLabel.text;
    if(type == 0){
        datePicker.date = [NSDate dateWithString:startDateString formatString:DATE_FORMAT];
    }else{
        if (![endDateString isEqualToString:ENDLESS_STRING]) {
            datePicker.date = [NSDate dateWithString:endDateString formatString:DATE_FORMAT];
        }
        
        datePicker.minimumDate = [NSDate dateWithString:startDateString formatString:DATE_FORMAT];
        
        UIAlertAction *endlessAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Set to forever", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
        }];
        [alert addAction:endlessAction];
    }
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDate *date = datePicker.date;
        if(type == 0){
            [self.startDateButton setTitle:[date formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        }else{
            [self.endDateButton setTitle:[date formattedDateWithFormat:DATE_FORMAT] forState:UIControlStateNormal];
        }
    }];
    [alert addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:alert.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:datePicker.frame.size.height + (type == 1 ? 175 : 120) + (IS_IPAD ? -50.0 : 0.0)];
    [alert.view addConstraint:heightConstraint];
    
    if (alert.popoverPresentationController != NULL) {
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        alert.popoverPresentationController.sourceView = btn;
        alert.popoverPresentationController.sourceRect = CGRectZero;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        default:
            return 0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
    switch (section) {
        case 0:
            [view setText:NSLocalizedString(@"Required", nil)];
            break;
        case 1:
            [view setText:NSLocalizedString(@"Optional", nil)];
            break;
        default:
            [view setText:@""];
            break;
    }
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 60.0f;
    } else if (section == 1) {
        return 50.0f;
    } else {
        return 0.00001f;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1 && indexPath.row == 2){
        return 280.f + (self.selectedImgView.image == NULL ? 0.0f : (CGRectGetWidth(self.view.frame) - 120.0f));
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
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
        [self.appNameLabel setText:NSLocalizedString(@"None", nil)];
        [self.appSwitch setOn:NO];
    }else{
        self.selectedApp = scheme;
        [self.appNameLabel setText:scheme.name];
        [self.appSwitch setOn:YES];
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
