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
#import "KPSeparatorView.h"
#import "KPTimeView.h"
#import "KPNavigationTitleView.h"
#import "IDMPhotoBrowser.h"
#import "UIViewController+Extensions.h"

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
    [self.startDateButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [self.endDateButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    self.startDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.endDateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.startDateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.endDateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    //Weekday
    [self.weekdayView setFontSize:9.0];
    self.weekdayView.isAllButtonHidden = YES;
    self.weekdayView.userInteractionEnabled = NO;
    [self.weekdayView setNeedsLayout];
    [self.weekdayView layoutIfNeeded];
    [self.weekdayView setNeedsUpdateConstraints];
    [self.weekdayView updateConstraintsIfNeeded];
    
    //CardViews
    for(CardsView *cardView in self.cardsViews){
        [cardView setCornerRadius:10.0];
        [cardView setBackgroundColor:[UIColor whiteColor]];
    }
    
    //Calendar
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    CardsView *cardView;
    for(CardsView *cv in self.cardsViews){
        if(cv.tag == 2){
            cardView = cv;
        }
    }
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.tableView.frame) - 30, 240)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
    self.calendar.appearance.headerDateFormat = @"yyyy 年 MM 月";
    self.calendar.appearance.separators = FSCalendarSeparatorNone;
    self.calendar.clipsToBounds = YES;
    
    self.calendar.appearance.headerTitleColor = [Utilities getColor];
    self.calendar.appearance.weekdayTextColor = [Utilities getColor];
    
    self.calendar.appearance.todayColor = [UIColor clearColor];
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    self.calendar.appearance.selectionColor =  [UIColor clearColor];
    self.calendar.appearance.titleSelectionColor = [UIColor blackColor];
    self.calendar.appearance.todaySelectionColor = [UIColor clearColor];
    self.calendar.appearance.eventDefaultColor = [Utilities getColor];
    self.calendar.appearance.eventSelectionColor = [Utilities getColor];
    
    [cardView addSubview:self.calendar];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(5, 3, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"NAV_BACK"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:previousButton];
    self.previousButton = previousButton;
    
    self.calendar.appearance.titleFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont systemFontOfSize:15.0];
    self.calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.subtitleFont = [UIFont systemFontOfSize:10.0];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - 120, 3, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"NAV_NEXT"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    NSArray *colorLegend = @[[UIColor redColor],
                             [Utilities getColor],
                             [UIColor lightGrayColor],
                             [Utilities getColor]];
    NSArray *legendName = @[@"CIRCLE_BORDER",
                            @"CIRCLE_FULL",
                            @"CIRCLE_FULL",
                            @"CIRCLE_BORDER"];
    for (int i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:legendName[i]];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = self.legendImageView[i];
        imageView.image = image;
        [imageView setTintColor:colorLegend[i]];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadTask];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideTip];
}

- (void)editAction:(id)sender{
    [self performSegueWithIdentifier:@"editSegue" sender:nil];
}

- (void)loadTask{
    self.task = [[TaskManager shareInstance] getTasksOfID:self.taskid];
    
    //Set Task Properties
    //name
    UIColor *color;
    if(self.task.type > 0){
        color = [Utilities getTypeColorArr][self.task.type - 1];
    }else{
        color = NULL;
    }
    KPNavigationTitleView *titleView = [[KPNavigationTitleView alloc] initWithTitle:self.task.name
                                                                           andColor:color];
    [titleView setCanTap:NO];
    self.navigationItem.titleView = titleView;
    
    //progress
    [self.progressView setProgress:self.task.progress animated:NO];
    
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
        [self.reminderTimeView setTime:self.reminderTime];
    }else{
        [self.reminderTimeView setTime:NULL];
    }

    //app
    if(self.task.appScheme != NULL){
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
            IDMPhoto *photo = [IDMPhoto photoWithImage:[UIImage imageWithData:self.task.image]];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            [self presentViewController:browser animated:YES completion:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.contentView setNeedsUpdateConstraints];
        [cell.contentView updateConstraintsIfNeeded];
    }
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
            return 60.0f;
        case 1:
            return 50.0f;
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

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    [calendar deselectDate:date];
    
    if(self.task == NULL){
        return;
    }
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    NSString *memo = [[TaskManager shareInstance] getPunchMemoOfTask:self.task onDate:date];
    NSString *displayMemo;
    NSString *buttonMemoText;
    if([memo isEqualToString:@""]){
        displayMemo = @"无当日备注";
        buttonMemoText = @"增加当日备注";
    }else{
        displayMemo = [NSString stringWithFormat:@"当日备注：%@", memo];
        buttonMemoText = @"修改当日备注";
    }
    
    [alert addButton:buttonMemoText actionBlock:^(void) {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
        UITextField *memoText = [alert addTextField:@"填写当日备注"];
        memoText.text = memo;
        [alert addButton:@"提交" actionBlock:^(void) {
            [[TaskManager shareInstance] modifyMemoForTask:self.task withMemo:memoText.text onDate:date];
            
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showSuccess:@"修改当日备注成功" subTitle:nil closeButtonTitle:@"好的" duration:0.0];
        }];
        [alert showEdit:@"当日备注" subTitle:[NSString stringWithFormat:@"%@ · %@", self.task.name, [DateUtil getDateStringOfDate:date]] closeButtonTitle:@"取消" duration:0.0];
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
    
    //取消跳过打卡
    if([self.task.punchSkipArr containsObject:[DateUtil transformDate:date]]) {
        [alert addButton:@"取消跳过打卡" actionBlock:^(void) {
            [[TaskManager shareInstance] unskipForTask:self.task onDate:date];
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

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return self.task.addDate;
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    if([self.task.punchMemoArr containsObject:[DateUtil transformDate:date]]){
        return 1;
    }
    return 0;
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editSegue"]){
        KPTaskDetailTableViewController *kptdtvc = segue.destinationViewController;
        [kptdtvc setTask:self.task];
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

@end
