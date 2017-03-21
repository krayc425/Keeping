//
//  KPTaskDisplayTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskDisplayTableViewController.h"
#import "Utilities.h"
#import "CardsView.h"
#import "HYCircleProgressView.h"
#import "DateUtil.h"
#import "DateTools.h"
#import "TaskDataHelper.h"
#import "SCLAlertView.h"
#import "TaskManager.h"
#import "AMPopTip.h"
#import "KPTaskDetailTableViewController.h"
#import "KPImageViewController.h"
#import "KPCalInfoView.h"
#import "KPSeparatorView.h"

#define ENDLESS_STRING @"到 无限期"
#define DATE_FORMAT @"yyyy/MM/dd"

static AMPopTip *shareTip = NULL;

@interface KPTaskDisplayTableViewController (){
    UILabel *titleLabel;
}

@end

@implementation KPTaskDisplayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Navigation
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_EDIT"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(editAction:)];
    self.navigationItem.rightBarButtonItems = @[editItem];
    
    //TableView
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //ProgressView
    [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
    [self.progressView setProgressStrokeColor:[Utilities getColor]];
    [self.progressView setProgressLineWidth:5.0f];
    [self.progressView setBackgroundLineWidth:5.0f];
    [self.progressView setFontWithSize:25.0f];
    
    //Duration
    [self.startDateButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    [self.endDateButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    [self.startDateButton.titleLabel sizeToFit];
    [self.endDateButton.titleLabel sizeToFit];
    [self.startDateButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.endDateButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    self.startDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.endDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.startDateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.endDateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    //CardViews
    for(CardsView *cardView in self.cardsViews){
        [cardView setCornerRadius:10.0];
        [cardView setBackgroundColor:[UIColor whiteColor]];
    }
    
    //Weekday
    self.weekdayView.isAllSelected = NO;
    self.weekdayView.fontSize = 15.0;
    self.weekdayView.isAllButtonHidden = YES;
    self.weekdayView.userInteractionEnabled = NO;
    
    //Reminder
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    
    //Calendar
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    CardsView *cardView;
    for(CardsView *cv in self.cardsViews){
        if(cv.tag == 2){
            cardView = cv;
        }
    }
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.tableView.frame) - 30, 240)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
    self.calendar.appearance.headerDateFormat = @"yyyy 年 MM 月";
    
    self.calendar.appearance.headerTitleColor = [Utilities getColor];
    self.calendar.appearance.weekdayTextColor = [Utilities getColor];
    
    self.calendar.appearance.todayColor = [UIColor clearColor];
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    self.calendar.appearance.selectionColor =  [UIColor clearColor];
    self.calendar.appearance.titleSelectionColor = [UIColor blackColor];
    self.calendar.appearance.todaySelectionColor = [UIColor clearColor];
    
    [cardView addSubview:self.calendar];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(5, 8, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"icon_prev"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:previousButton];
    self.previousButton = previousButton;
    
    self.calendar.appearance.titleFont = [UIFont fontWithName:[Utilities getFont] size:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.weekdayFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.subtitleFont = [UIFont fontWithName:[Utilities getFont] size:10.0];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - 120, 8, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"icon_next"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    infoBtn.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - 60, 9, 32, 32);
    infoBtn.backgroundColor = [UIColor whiteColor];
    infoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [infoBtn setTintColor:[UIColor lightGrayColor]];
    UIImage *infoImg = [UIImage imageNamed:@"Info"];
    infoImg = [infoImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [infoBtn setImage:infoImg forState:UIControlStateNormal];
    [infoBtn addTarget:self action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:infoBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadTask];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self hideTip];
}

- (void)editAction:(id)sender{
    [self performSegueWithIdentifier:@"editSegue" sender:nil];
}

- (void)infoAction:(id)sender{
    NSLog(@"info");
    
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"KPCalInfoView" owner:nil options:nil];
    KPCalInfoView *view = [nibView firstObject];
    [view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 40, 200)];
    
    AMPopTip *tp = [KPTaskDisplayTableViewController shareTipInstance];
    
    if(![tp isVisible] && ![tp isAnimating]){
        
        [tp showCustomView:view
                 direction:AMPopTipDirectionNone
                    inView:self.tableView
                 fromFrame:self.tableView.bounds];
        
        tp.shouldDismissOnTap = YES;
        
        tp.textColor = [UIColor whiteColor];
        tp.tintColor = [Utilities getColor];
        tp.popoverColor = [Utilities getColor];
        tp.borderColor = [UIColor whiteColor];
        
        tp.radius = 10;
        
        [tp setDismissHandler:^{
            shareTip = NULL;
        }];
    }
}

- (void)setTitleLabel:(NSString *)title{
    //Type
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 64)];
    [titleLabel setText:title];
    [titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:22.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel sizeToFit];
    
    UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    if(self.task.type > 0){
        UIImage *img = [UIImage imageNamed:@"Round_S"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        typeView.tintColor = [Utilities getTypeColorArr][self.task.type - 1];
        [typeView setImage:img];
        [typeView setHidden:NO];
    }else{
        [typeView setHidden:YES];
    }
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(typeView.frame) + CGRectGetWidth(titleLabel.frame) + 5, 64)];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = 0;
    [stackView addArrangedSubview:titleLabel];
    [stackView addArrangedSubview:typeView];
    
    self.navigationItem.titleView = stackView;
}

- (void)loadTask{
    self.task = [[TaskManager shareInstance] getTasksOfID:self.taskid];
    
    //Set Task Properties
    //name
    [self setTitleLabel:self.task.name];
    
    //progress
    [self.progressView setProgress:self.task.progress animated:YES];
    
    //duration
    [self.startDateButton setTitle:[NSString stringWithFormat:@"从 %@", [self.task.addDate formattedDateWithFormat:DATE_FORMAT]] forState:UIControlStateNormal];
    if(self.task.endDate != NULL){
        [self.endDateButton setTitle:[NSString stringWithFormat:@"到 %@", [self.task.endDate formattedDateWithFormat:DATE_FORMAT]] forState:UIControlStateNormal];
    }else{
        [self.endDateButton setTitle:ENDLESS_STRING forState:UIControlStateNormal];
    }
    
    //weekday
    self.selectedWeekdayArr = [NSMutableArray arrayWithArray:self.task.reminderDays];
    [self.weekdayView selectWeekdaysInArray:self.selectedWeekdayArr];
    
    //reminder
    self.reminderTime = self.task.reminderTime;
    if(self.reminderTime != NULL){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm 提醒"];
        NSString *currentDateStr = [dateFormatter stringFromDate:self.reminderTime];
        [self.reminderLabel setText:currentDateStr];
//        [self.reminderLabel setHidden:NO];
    }else{
        [self.reminderLabel setText:@"全天"];
//        [self.reminderLabel setHidden:YES];
    }

    //app
    if(self.task.appScheme != NULL){
//        NSDictionary *d = self.task.appScheme;
//        NSString *s = d.allKeys[0];
        [self.appBtn setTintColor:[Utilities getColor]];
        [self.appBtn setUserInteractionEnabled:YES];
    }else{
        [self.appBtn setTintColor:[UIColor groupTableViewBackgroundColor]];
        [self.appBtn setUserInteractionEnabled:NO];
    }
    UIImage *appImg = [UIImage imageNamed:@"TODAY_APP"];
    appImg = [appImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.appBtn setImage:appImg forState:UIControlStateNormal];
    
    //link
    if(self.task.link != NULL && ![self.task.link isEqualToString:@""]){
        [self.linkBtn setTintColor:[Utilities getColor]];
        [self.linkBtn setUserInteractionEnabled:YES];
    }else{
        [self.linkBtn setTintColor:[UIColor groupTableViewBackgroundColor]];
        [self.linkBtn setUserInteractionEnabled:NO];
    }
    UIImage *linkImg = [UIImage imageNamed:@"TODAY_LINK"];
    linkImg = [linkImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.linkBtn setImage:linkImg forState:UIControlStateNormal];
    
    //image
    if(self.task.image != NULL){
        [self.imageBtn setTintColor:[Utilities getColor]];
        [self.imageBtn setUserInteractionEnabled:YES];
    }else{
        [self.imageBtn setTintColor:[UIColor groupTableViewBackgroundColor]];
        [self.imageBtn setUserInteractionEnabled:NO];
    }
    UIImage *imageImg = [UIImage imageNamed:@"TODAY_IMAGE"];
    imageImg = [imageImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageBtn setImage:imageImg forState:UIControlStateNormal];
    
    //memo
    if(self.task.memo != NULL && ![self.task.memo isEqualToString:@""]){
        [self.memoBtn setTintColor:[Utilities getColor]];
        [self.memoBtn setUserInteractionEnabled:YES];
    }else{
        [self.memoBtn setTintColor:[UIColor groupTableViewBackgroundColor]];
        [self.memoBtn setUserInteractionEnabled:NO];
    }
    UIImage *memoImg = [UIImage imageNamed:@"TODAY_TEXT"];
    memoImg = [memoImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.memoBtn setImage:memoImg forState:UIControlStateNormal];
    
    [self.calendar reloadData];
    [self.calendar reloadInputViews];
}

#pragma mark - Helper Methods

- (BOOL)canFixPunch:(NSDate *)date{
    if([[NSDate date] isEarlierThanOrEqualTo:date]){
        return NO;
    }
    if(self.task.endDate != NULL && [[self.task.endDate dateByAddingDays:1] isEarlierThan:date]){
        return NO;
    }else{
        return ![self.task.punchDateArr containsObject:[DateUtil transformDate:date]] && [self.task.reminderDays containsObject:@(date.weekday)] && [self.task.addDate isEarlierThanOrEqualTo:date];
    }
}

- (BOOL)canSkipTask:(NSDate *)date{
    if([[NSDate date] isEarlierThanOrEqualTo:date]){
        return NO;
    }
    if(self.task.endDate != NULL && [[self.task.endDate dateByAddingDays:1] isEarlierThan:date]){
        return NO;
    }else{
        return ![self.task.punchSkipArr containsObject:[DateUtil transformDate:date]] && [self.task.reminderDays containsObject:@(date.weekday)] && [self.task.addDate isEarlierThanOrEqualTo:date];
    }
}

- (IBAction)moreActionWithBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    //tag:
    //      = 0 : app
    //      = 1 : 链接
    //      = 2 : 图片
    //      = 3 : 备注
    switch (btn.tag) {
        case 0:
        {
            NSString *s = self.task.appScheme.allValues[0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s] options:@{} completionHandler:nil];
        }
            break;
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.task.link] options:@{} completionHandler:nil];
        }
            break;
        case 2:
        {
            [self performSegueWithIdentifier:@"imageSegue" sender:[UIImage imageWithData:self.task.image]];
        }
            break;
        case 3:
        {
            AMPopTip *tp = [KPTaskDisplayTableViewController shareTipInstance];
            
            if(![tp isVisible] && ![tp isAnimating]){
                [tp showText:self.task.memo
                   direction:AMPopTipDirectionNone
                    maxWidth:self.view.frame.size.width - 50
                      inView:self.view
                   fromFrame:self.view.bounds];
                tp.shouldDismissOnTap = YES;
                
                tp.textColor = [UIColor whiteColor];
                tp.tintColor = [Utilities getColor];
                tp.popoverColor = [Utilities getColor];
                tp.borderColor = [UIColor whiteColor];
                
                tp.radius = 10;
                
                [tp setDismissHandler:^{
                    shareTip = NULL;
                }];
            }
        }
            break;
        default:
            break;
    }
    
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
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
            view.backgroundColor = [UIColor clearColor];
            [view setText:@"基本信息"];
            return view;
        }
            break;
        case 1:
        {
            KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
            view.backgroundColor = [UIColor clearColor];
            [view setText:@"完成情况"];
            return view;
        }
            break;
        default:
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 30.0f;
        case 1:
            return 20.0f;
        default:
            return 0.00001f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

#pragma mark - FSCalendar Delegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    [calendar deselectDate:date];
    
    if(self.task == NULL){
        return;
    }
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    NSString *memo = [[TaskManager shareInstance] getPunchMemoOfTask:self.task onDate:date];
    NSString *displayMemo;
    NSString *buttonMemoText;
    if([memo isEqualToString:@""]){
        displayMemo = @"无备注";
        buttonMemoText = @"增加备注";
    }else{
        displayMemo = [NSString stringWithFormat:@"备注：%@", memo];
        buttonMemoText = @"修改备注";
    }
    
    [alert addButton:buttonMemoText actionBlock:^(void) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
        UITextField *memoText = [alert addTextField:@"填写备注"];
        memoText.text = memo;
        [alert addButton:@"提交" actionBlock:^(void) {
            [[TaskManager shareInstance] modifyMemoForTask:self.task withMemo:memoText.text onDate:date];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showSuccess:@"修改备注成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
        }];
        [alert showEdit:@"备注" subTitle:[NSString stringWithFormat:@"%@ · %@", self.task.name, [DateUtil getDateStringOfDate:date]] closeButtonTitle:@"取消" duration:0.0];
    }];
    
    //补打卡
    if([self canFixPunch:date]){
        [alert addButton:@"补打卡" actionBlock:^(void) {
            [[TaskManager shareInstance] punchForTaskWithID:@(self.task.id) onDate:date];
            [self loadTask];
        }];
        
    }
    
    //跳过打卡
    if([self canSkipTask:date] && [self canFixPunch:date]){
        [alert addButton:@"跳过打卡" actionBlock:^(void) {
            [[TaskManager shareInstance] skipForTask:self.task onDate:date];
            [self loadTask];
        }];
    }
    
    //取消打卡
    if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
        [alert addButton:@"取消打卡" actionBlock:^(void) {
            [[TaskManager shareInstance] unpunchForTaskWithID:@(self.task.id) onDate:date];
            [self loadTask];
        }];
    }
    
    [alert showInfo:[DateUtil getDateStringOfDate:date] subTitle:displayMemo closeButtonTitle:@"取消" duration:0.0f];
}

- (void)previousClicked:(id)sender{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)nextClicked:(id)sender{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]] && [date isLaterThanOrEqualTo:self.task.addDate]){
            if(self.task.endDate != NULL){
                if([self.task.endDate isLaterThanOrEqualTo:date]){
                    return [Utilities getColor];
                }
            }else{
                return [Utilities getColor];
            }
        }
        
        //跳过打卡的日子
        if([self.task.punchSkipArr containsObject:[DateUtil transformDate:date]] && [date isLaterThanOrEqualTo:self.task.addDate]){
            if(self.task.endDate != NULL){
                if([self.task.endDate isLaterThanOrEqualTo:date]){
                    return [UIColor lightGrayColor];
                }
            }else{
                return [UIColor lightGrayColor];
            }
        }
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        //跳过打卡的日子
        if(([self.task.punchDateArr containsObject:[DateUtil transformDate:date]] && [date isLaterThanOrEqualTo:self.task.addDate]) || ([self.task.punchSkipArr containsObject:[DateUtil transformDate:date]] && [date isLaterThanOrEqualTo:self.task.addDate])){
            if(self.task.endDate != NULL){
                if([self.task.endDate isLaterThanOrEqualTo:date]){
                    return [UIColor whiteColor];
                }
            }else{
                return [UIColor whiteColor];
            }
        }
    }
    
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date{
    
    if(self.task != NULL){
        
        if([date isEarlierThan:self.task.addDate]){
            return [UIColor clearColor];
        }
        
        if(self.task.endDate != NULL){
            if([date isLaterThan:self.task.endDate]){
                return [UIColor clearColor];
            }
        }
        
        if([self.task.reminderDays containsObject:@(date.weekday)]){
            if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
                return [Utilities getColor];
            }else if([self.task.punchSkipArr containsObject:[DateUtil transformDate:date]]){
                return [UIColor lightGrayColor];
            }else{
                if([[NSDate date] isLaterThan:date]){
                    return [UIColor redColor];
                }else{
                    return [Utilities getColor];
                }
            }
        }else{
            return [UIColor clearColor];
        }
        
    }
    
    return appearance.borderDefaultColor;
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    if(self.task != NULL){
        //创建日期
        return [self.task.addDate isEqualToDate:date]
        || (self.task.endDate != NULL && [self.task.endDate isEqualToDate:date]);
    }else{
        return 0;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editSegue"]){
        KPTaskDetailTableViewController *kptdtvc = segue.destinationViewController;
        [kptdtvc setTask:self.task];
    }else if([segue.identifier isEqualToString:@"imageSegue"]){
        KPImageViewController *imageVC = (KPImageViewController *)[segue destinationViewController];
        [imageVC setImg:(UIImage *)sender];
    }
}

#pragma mark - AMPopTip Singleton

+ (AMPopTip *)shareTipInstance{
    return shareTip == NULL ? shareTip = [AMPopTip popTip] : shareTip;
}

- (void)hideTip{
    if([[KPTaskDisplayTableViewController shareTipInstance] isAnimating]
       || [[KPTaskDisplayTableViewController shareTipInstance] isVisible]){
        [[KPTaskDisplayTableViewController shareTipInstance] hide];
        shareTip = NULL;
    }
}

//#pragma mark - 3D Touch Actions
//
//- (NSArray *)previewActionItems{
//    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"编辑"
//                                                          style:UIPreviewActionStyleDefault
//                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//                                                            NSLog(@"%@", self.task.name);
//                                                            [self editAction:nil];
//                                                        }];
//    
//    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"删除"
//                                                          style:UIPreviewActionStyleDestructive
//                                                        handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//                                                            NSLog(@"Aciton2");
//                                                        }];
//    
//    NSArray *actions = @[action1,action2];
//    
//    return actions;
//}

@end
