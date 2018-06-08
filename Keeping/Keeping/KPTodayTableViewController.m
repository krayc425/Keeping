//
//  KPTodayTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTodayTableViewController.h"
#import "KPSeparatorView.h"
#import "KPTodayTableViewCell.h"
#import "Utilities.h"
#import "TaskManager.h"
#import "Task.h"
#import "DateUtil.h"
#import "DateTools.h"
#import "UIScrollView+EmptyDataSet.h"
#import "AMPopTip.h"
#import "CardsView.h"
#import "TaskDataHelper.h"
#import "KPTaskDisplayTableViewController.h"
#import "UIImage+Extensions.h"
#import "KPTimeView.h"
#import "KPNavigationTitleView.h"
#import "KPTodayTableViewController+Touch.h"
#import "KPWatchManager.h"
#import "IDMPhotoBrowser.h"
#import "UIViewController+Extensions.h"
#import "MGSwipeTableCell.h"
#import "KPProgressLabel.h"

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTodayTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MGSwipeTableCellDelegate> {
    BOOL firstLoad;
}

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstLoad = YES;
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.selectedDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    //类别按钮
    [KPTodayTableViewController shareColorPickerView].colorDelegate = self;
    [[KPTodayTableViewController shareColorPickerView] setFrame:CGRectMake(0, 0, SCREEN_WIDTH - 32, 40)];

    //日历插件
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, 250)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.layer.cornerRadius = 10;
    
    self.calendar.appearance.titleFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont systemFontOfSize:15.0];
    self.calendar.appearance.weekdayFont = [UIFont systemFontOfSize:12.0];
    self.calendar.appearance.subtitleFont = [UIFont systemFontOfSize:10.0];
    
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
    self.calendar.appearance.headerDateFormat = @"yyyy 年 MM 月";
    
    self.calendar.appearance.headerTitleColor = [Utilities getColor];
    self.calendar.appearance.weekdayTextColor = [Utilities getColor];
    self.calendar.appearance.selectionColor =  [Utilities getColor];
    self.calendar.appearance.titleSelectionColor = [UIColor whiteColor];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(5, 5, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"NAV_BACK"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendar addSubview:previousButton];
    self.previousButton = previousButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(self.calendar.frame)-100, 5, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"NAV_NEXT"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendar addSubview:nextButton];
    self.nextButton = nextButton;
    
    [self.calendar selectDate:self.selectedDate scrollToDate:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTasks) name:@"refresh_today_task" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh_today_task" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadTasks];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self hideTip];
    
    if (self.selectedIndexPath != NULL) {
        [self.tableView reloadData];
        self.selectedIndexPath = NULL;
    }
}

- (void)loadTasks{
    NSDictionary *sortDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"sort"];
    self.sortFactor = sortDict.allKeys[0];
    self.isAscend = sortDict.allValues[0];
    
    [self.subDateLabel setText:[DateUtil getTodayDateStringOfDate:self.selectedDate]];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.selectedDate.day] forState:UIControlStateNormal];
    
    self.unfinishedTaskArr = [[NSMutableArray alloc] init];
    self.finishedTaskArr = [[NSMutableArray alloc] init];
    
    NSMutableArray *taskArr = [[TaskManager shareInstance] getTasksOfDate:self.selectedDate];
    for (Task *task in taskArr) {
        if ([task hasPunchedOnDate:self.selectedDate]) {
            [self.finishedTaskArr addObject:task];
        } else {
            [self.unfinishedTaskArr addObject:task];
        }
    }
    
    [[KPWatchManager shareInstance] transformTasksToWatchWithTasks:taskArr];
    
    //设置进度
    [self refreshProgress];
    
    //排序
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.unfinishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.finishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    
    //按类别
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.unfinishedTaskArr withType:self.selectedColorNum]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.finishedTaskArr withType:self.selectedColorNum]];
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
    
    [self.tableView reloadEmptyDataSet];
    
    [self fadeAnimation];
    
    [self setBadge];
    
    if(firstLoad){
        firstLoad = NO;
    }
}

- (void)setBadge{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]){
        UIApplication *application = [UIApplication sharedApplication];
        [application setApplicationIconBadgeNumber:self.unfinishedTaskArr.count];
    }else{
        UIApplication *application = [UIApplication sharedApplication];
        [application setApplicationIconBadgeNumber:0];
    }
}

- (void)refreshProgress{
    NSUInteger finished = self.finishedTaskArr.count;
    NSUInteger total = self.finishedTaskArr.count + self.unfinishedTaskArr.count;
    [self.progressLabel setProgressWithFinished:finished andTotal:total];
}

- (void)editAction:(id)sender{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择任务排序方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSDictionary *dict = [Utilities getTaskSortArr];
    for (NSString *key in dict.allKeys) {
        
        NSMutableString *displayKey = key.mutableCopy;
        if([self.sortFactor isEqualToString:dict[displayKey]]){
            if(self.isAscend.intValue == true){
                [displayKey appendString:@" ↑"];
            }else{
                [displayKey appendString:@" ↓"];
            }
        }
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:displayKey style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if([self.sortFactor isEqualToString:dict[key]]){
                if(self.isAscend.intValue == true){
                    self.isAscend = @(0);
                }else{
                    self.isAscend = @(1);
                }
            }else{
                self.sortFactor = dict[key];
                self.isAscend = @(1);
            }
            [[NSUserDefaults standardUserDefaults] setValue: @{self.sortFactor : self.isAscend} forKey:@"sort"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loadTasks];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Choose Date

- (IBAction)chooseDateAction:(id)sender{
    AMPopTip *tp = [KPTodayTableViewController shareTipInstance];
    
    if(![tp isVisible] && ![tp isAnimating]){
        [tp showCustomView:self.calendar
                 direction:AMPopTipDirectionNone
                    inView:self.tableView
                 fromFrame:self.view.bounds]; //这个23咋回事
        
        tp.textColor = [UIColor whiteColor];
        tp.tintColor = [Utilities getColor];
        tp.popoverColor = [Utilities getColor];
        tp.borderColor = [UIColor whiteColor];
        
        tp.radius = 15;
        
        [tp setDismissHandler:^{
            shareTip = NULL;
        }];
    }
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

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除吗" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        Task *t;
        if(indexPath.section == 1){
            t = self.unfinishedTaskArr[indexPath.row];
            [self.unfinishedTaskArr removeObject:t];
        }else if(indexPath.section == 2){
            t = self.finishedTaskArr[indexPath.row];
            [self.finishedTaskArr removeObject:t];
        }
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[TaskManager shareInstance] deleteTask:t];
        
        if(self.finishedTaskArr.count == 0 || self.unfinishedTaskArr.count == 0){
            [self.tableView reloadData];
        }
        
        [self refreshProgress];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
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
            return [self.unfinishedTaskArr count];
        case 2:
            return [self.finishedTaskArr count];
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
        {
            if([self.unfinishedTaskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:@"未完成"];
                return view;
            }
        }
        case 2:
        {
            if([self.finishedTaskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:@"已完成"];
                return view;
            }
        }
        default:
            return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
        {
            if([self.unfinishedTaskArr count] == 0){
                return 0.00001f;
            }else{
                return 50.0f;
            }
        }
        case 2:
            return 50.0f;
        default:
            return 0.00001f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
        case 2:
        {
            static NSString *cellIdentifier = @"KPTodayTableViewCell";
            UINib *nib = [UINib nibWithNibName:@"KPTodayTableViewCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
            KPTodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            
            [cell setFont];
            
            cell.checkDelegate = self;
            cell.delegate = self;
            
            //配置任务信息
            Task *t;
            if(indexPath.section == 1){
                t = self.unfinishedTaskArr[indexPath.row];
                
                [cell setIsFinished:NO];
            }else{
                t = self.finishedTaskArr[indexPath.row];
                
                [cell setIsFinished:YES];
            }
            
            //设置是否为当前 cell
            if([indexPath isEqual:self.selectedIndexPath] && ![cell.moreButton isHidden]){
                [cell setIsSelected:YES];
                [cell.moreButton setBackgroundImage:[UIImage imageNamed:@"MORE_INFO_UP"] forState:UIControlStateNormal];
            }else{
                [cell setIsSelected:NO];
                [cell.moreButton setBackgroundImage:[UIImage imageNamed:@"MORE_INFO_DOWN"] forState:UIControlStateNormal];
            }
            
            [cell configureWithTask:t];
            
            //晚于：不能打卡
            NSDate *tempDate = [NSDate dateWithYear:[[NSDate date] year]
                                              month:[[NSDate date] month]
                                                day:[[NSDate date] day]];
            if(![self.selectedDate isEarlierThanOrEqualTo:tempDate]){
                cell.myCheckBox.userInteractionEnabled = NO;
            }else{
                cell.myCheckBox.userInteractionEnabled = YES;
            }
            
            //注册3D Touch
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
            
            return cell;
        }
        default:
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        if(indexPath == self.selectedIndexPath){
            return 120;
        }else{
            return 70;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return NO;
    }
    return self.selectedIndexPath != indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section != 0){
        KPTodayTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(![cell.moreButton isHidden]){
            if([self.selectedIndexPath isEqual:indexPath]){
                self.selectedIndexPath = NULL;
            }else{
                self.selectedIndexPath = indexPath;
            }
        }else{
            self.selectedIndexPath = NULL;
        }
        [self fadeAnimation];
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section == 0
//       || indexPath == self.selectedIndexPath
//       || ![[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]
//       || !firstLoad){
//        return;
//    }
//    
//    NSInteger order = indexPath.row + (indexPath.section == 2 ? self.unfinishedTaskArr.count : 0);
//    CGFloat time = order * 0.1;
//    
//    cell.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH, 0);
//    [UIView animateWithDuration:0.4
//                          delay:time
//         usingSpringWithDamping:0.7
//          initialSpringVelocity:1 / 0.7
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//        cell.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //section = 1 : 未完成
    if(path.section == 1){
        Task *task = self.unfinishedTaskArr[path.row];
        [[TaskManager shareInstance] punchForTaskWithID:@(task.id) onDate:self.selectedDate];
    }else if(path.section == 2){
        Task *task = self.finishedTaskArr[path.row];
        [[TaskManager shareInstance] unpunchForTaskWithID:@(task.id) onDate:self.selectedDate];
    }
    [self loadTasks];
}

- (void)moreAction:(UITableViewCell *)cell withButton:(UIButton *)button{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    Task *t;
    if(indexPath.section == 1){
        t = self.unfinishedTaskArr[indexPath.row];
    }else if(indexPath.section == 2){
        t = self.finishedTaskArr[indexPath.row];
    }
    
    //tag:
    //      = 0 : app
    //      = 1 : 链接
    //      = 2 : 图片
    //      = 3 : 备注
    switch (button.tag) {
        case 0:
        {
            NSString *s = t.appScheme.allValues[0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s] options:@{} completionHandler:nil];
        }
            break;
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:t.link] options:@{} completionHandler:nil];
        }
            break;
        case 2:
        {
            IDMPhoto *photo = [IDMPhoto photoWithImage:[UIImage imageWithData:t.image]];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            [self presentViewController:browser animated:YES completion:nil];
        }
            break;
        case 3:
        {
            AMPopTip *tp = [KPTodayTableViewController shareTipInstance];
            
            if(![tp isVisible] && ![tp isAnimating]){
                [tp showText:t.memo
                         direction:AMPopTipDirectionNone
                          maxWidth:self.view.frame.size.width - 50
                            inView:self.view
                         fromFrame:self.view.bounds];
                tp.shouldDismissOnTap = YES;
                
                tp.tintColor = [UIColor whiteColor];
                tp.popoverColor = [Utilities getColor];
                tp.borderColor = [UIColor whiteColor];
                tp.backgroundColor = [UIColor clearColor];

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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailTaskSegue"]){
        Task *t = (Task *)sender;
        KPTaskDisplayTableViewController *kptdtvc = (KPTaskDisplayTableViewController *)[segue destinationViewController];
        [kptdtvc setTaskid:t.id];
    }
}

#pragma mark - DZNEmptyTableViewDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"没有任务", @"") ;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.finishedTaskArr.count + self.unfinishedTaskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    NSDate *tempDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    self.selectedDate = tempDate;
    [self hideTip];
    [self loadTasks];
}

#pragma mark - Fade Animation

- (void)fadeAnimation{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]){
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = [Utilities getAnimationType];
        [self.tableView.layer addAnimation:animation forKey:@"fadeAnimation"];
    }
}

#pragma mark - MGSwipeCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (direction) {
        case MGSwipeDirectionLeftToRight:
        {
            Task *task = indexPath.section == 1 ? self.unfinishedTaskArr[indexPath.row] : self.finishedTaskArr[indexPath.row];
            [self performSegueWithIdentifier:@"detailTaskSegue" sender:task];
        }
            break;
        case MGSwipeDirectionRightToLeft:
            [self deleteTaskAtIndexPath:indexPath];
            break;
        default:
            break;
    }
    return YES;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point{
    return [self.tableView indexPathForCell:cell] != self.selectedIndexPath;
}

#pragma mark - KPNavigationTitleDelegate

- (void)navigationTitleViewTapped{
    AMPopTip *tp = [KPTodayTableViewController shareTipInstance];

    if(![tp isVisible] && ![tp isAnimating]){
        [tp showCustomView:colorPickerView
                 direction:AMPopTipDirectionDown
                    inView:self.view
                 fromFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2, -44, 0, 44)];

        tp.textColor = [UIColor whiteColor];
        tp.tintColor = [Utilities getColor];
        tp.popoverColor = [Utilities getColor];
        tp.borderColor = [UIColor whiteColor];

        tp.radius = 10;

        [tp setDismissHandler:^{
            shareTip = NULL;
        }];
    }else{
        [tp hide];
    }
}

#pragma mark - KPColorPickerDelegate

- (void)didChangeColors:(int)selectColorNum{
    self.selectedColorNum = selectColorNum;
    [colorPickerView setSelectedColorNum:self.selectedColorNum];
    
    KPNavigationTitleView *titleView = (KPNavigationTitleView *)self.tabBarController.navigationItem.titleView;
    
    if(self.selectedColorNum > 0){
        [titleView changeColor:[Utilities getTypeColorArr][self.selectedColorNum - 1]];
    }else{
        [titleView changeColor:NULL];
    }

    [self loadTasks];
}

#pragma mark - AMPopTip Singleton

+ (AMPopTip *)shareTipInstance{
    return shareTip == NULL ? shareTip = [AMPopTip popTip] : shareTip;
}

- (void)hideTip{
    if([[KPTodayTableViewController shareTipInstance] isAnimating]
       || [[KPTodayTableViewController shareTipInstance] isVisible]){
        [[KPTodayTableViewController shareTipInstance] hide];
        shareTip = NULL;
    }
}

#pragma mark - KPColor Singleton

+ (KPColorPickerView *)shareColorPickerView{
    if(colorPickerView == NULL){
        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"KPColorPickerView" owner:nil options:nil];
        colorPickerView = [nibView firstObject];
    }
    return colorPickerView;
}

@end
