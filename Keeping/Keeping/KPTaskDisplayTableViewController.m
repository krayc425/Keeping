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
#import "TaskManager.h"
#import "AMPopTip.h"
#import "KPTaskDetailTableViewController.h"
#import "KPSeparatorView.h"
#import "KPTimeView.h"
#import "KPNavigationTitleView.h"
#import "IDMPhotoBrowser.h"
#import "UIViewController+Extensions.h"
#import "Masonry.h"
#import "KPProgressLabel.h"

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
    [self.startDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.endDateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.startDateButton.titleLabel sizeToFit];
    [self.endDateButton.titleLabel sizeToFit];
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
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 2, CGRectGetWidth(self.tableView.frame) - 30, 240)];
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
    
    self.calendar.appearance.titleFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont systemFontOfSize:15.0];
    self.calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.subtitleFont = [UIFont systemFontOfSize:10.0];
    
    [cardView addSubview:self.calendar];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousButton setBackgroundColor:[UIColor clearColor]];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"NAV_BACK"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:previousButton];
    self.previousButton = previousButton;
    
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.calendar.mas_top).with.offset(3);
        make.left.mas_equalTo(self.calendar.mas_left).with.offset(5);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(34);
    }];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setBackgroundColor:[UIColor clearColor]];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"NAV_NEXT"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.calendar.mas_top).with.offset(3);
        make.right.mas_equalTo(self.calendar.mas_right).with.offset(-5);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(34);
    }];
    
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
    
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cardView.mas_top).with.offset(2);
        make.left.mas_equalTo(cardView.mas_left).with.offset(5);
        make.right.mas_equalTo(cardView.mas_right).with.offset(-5);
        make.bottom.mas_equalTo(cardView.mas_bottom).with.offset(-25);
    }];
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
    KPNavigationTitleView *titleView = [[KPNavigationTitleView alloc] initWithTitle:self.task.name andColor:color];
    [titleView setCanTap:NO];
    self.navigationItem.titleView = titleView;
    
    //progress
    [self.progressView setProgress:self.task.progress animated:NO];
    [self.progressLabel setProgressWithFinished:self.task.punchDays andTotal:self.task.totalDays];
    
    //duration
    [self.startDateButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"From", nil), [self.task.addDate formattedDateWithFormat:DATE_FORMAT]] forState:UIControlStateNormal];
    if(self.task.endDate != NULL){
        [self.endDateButton setTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"To", nil), [self.task.endDate formattedDateWithFormat:DATE_FORMAT]] forState:UIControlStateNormal];
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

- (IBAction)deleteTask:(id)sender{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SureToDelete", nil) message:NSLocalizedString(@"This operation cannot be reverted", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[TaskManager shareInstance] deleteTask:self.task];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
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

#pragma mark - 3D Touch

- (NSArray<id<UIPreviewActionItem>> *)previewActionItems{
    UIPreviewAction *deleteAction = [UIPreviewAction
                                    actionWithTitle:@"删除任务"
                                    style:UIPreviewActionStyleDestructive
                                    handler:^(UIPreviewAction * _Nonnull action,
                                              UIViewController * _Nonnull previewViewController) {
                                        [[TaskManager shareInstance] deleteTask:self.task];
                                    }];
    return @[deleteAction];
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
            [view setText:NSLocalizedString(@"Info", nil)];
            return view;
        }
            break;
        case 1:
        {
            KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
            view.backgroundColor = [UIColor clearColor];
            [view setText:NSLocalizedString(@"Progress", nil)];
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
    
    NSString *memo = [[TaskManager shareInstance] getPunchMemoOfTask:self.task onDate:date];
    NSString *displayMemo;
    NSString *buttonMemoText;
    if([memo isEqualToString:@""]){
        displayMemo = NSLocalizedString(@"No daily memo", nil);
        buttonMemoText = NSLocalizedString(@"Add daily memo", nil);
    }else{
        displayMemo = [NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"Daily memo", nil), memo];
        buttonMemoText = NSLocalizedString(@"Change daily memo", nil);
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[DateUtil getDateStringOfDate:date] message:displayMemo preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *memoAction = [UIAlertAction actionWithTitle:buttonMemoText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Fill in daily memo", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        __block UITextField *memoText = nil;
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = memo;
            memoText = textField;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        UIAlertAction *submitAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Submit", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[TaskManager shareInstance] modifyMemoForTask:self.task withMemo:memoText.text onDate:date];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Change success", nil) message:nil
                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }];
        [alert addAction:submitAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];

    [alert addAction:memoAction];
    
    //补打卡
    if([self canFixPunch:date]){
        UIAlertAction *fixPunchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mark as finished", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TaskManager shareInstance] punchForTaskWithID:@(self.task.id) onDate:date];
            [self loadTask];
        }];
        [alert addAction:fixPunchAction];
    }
    
    //跳过打卡
    if([self canSkipTask:date] && [self canFixPunch:date]){
        UIAlertAction *skipPunchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mark as skipped", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TaskManager shareInstance] skipForTask:self.task onDate:date];
            [self loadTask];
        }];
        [alert addAction:skipPunchAction];
    }
    
    //取消跳过打卡
    if([self.task.punchSkipArr containsObject:[DateUtil transformDate:date]]) {
        UIAlertAction *unskipPunchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Unmark as skipped", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TaskManager shareInstance] unskipForTask:self.task onDate:date];
            [self loadTask];
        }];
        [alert addAction:unskipPunchAction];
    }
    
    //取消打卡
    if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
        UIAlertAction *cancelPunchAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Mark as unfinished", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[TaskManager shareInstance] unpunchForTaskWithID:@(self.task.id) onDate:date];
            [self loadTask];

        }];
        [alert addAction:cancelPunchAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
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
        return NSLocalizedString(@"Today Calendar", nil);
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
