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
#import "Masonry.h"

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTodayTableViewController () <MGSwipeTableCellDelegate> 

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.selectedDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];

    //类别按钮
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(10, 270, SCREEN_WIDTH - 40, 50)];
    cardView.cornerRadius = 10.0;
    
    [KPTodayTableViewController shareColorPickerView].colorDelegate = self;
    [[KPTodayTableViewController shareColorPickerView] setFrame:CGRectMake(10, 5, SCREEN_WIDTH - 60, 40)];

    //日历插件
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 40, 250)];
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
    previousButton.backgroundColor = [UIColor whiteColor];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"NAV_BACK"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendar addSubview:previousButton];
    self.previousButton = previousButton;
    
    [self.previousButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.calendar.mas_top).with.offset(5);
        make.left.mas_equalTo(self.calendar.mas_left).with.offset(5);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(34);
    }];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.backgroundColor = [UIColor whiteColor];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"NAV_NEXT"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendar addSubview:nextButton];
    self.nextButton = nextButton;
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.calendar.mas_top).with.offset(5);
        make.right.mas_equalTo(self.calendar.mas_right).with.offset(-5);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(34);
    }];
    
    [self.calendar selectDate:self.selectedDate scrollToDate:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTasks) name:@"refresh_today_task" object:nil];
    
    [cardView addSubview:colorPickerView];
    
    self.hoverView = [[KPHoverView alloc] initWithFrame:CGRectMake(10.0, -330.0, SCREEN_WIDTH - 20, 330.0)];
    self.hoverView.headerScrollView = self.tableView;
    [self.hoverView addSubview:self.calendar];
    [self.hoverView addSubview:cardView];
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hoverView.mas_top).with.offset(10);
        make.left.mas_equalTo(self.hoverView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.hoverView.mas_right).with.offset(-10);
        make.height.mas_equalTo(250);
    }];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.hoverView.mas_bottom).with.offset(-10);
        make.left.mas_equalTo(self.hoverView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.hoverView.mas_right).with.offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView addObserver:self.hoverView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.hoverView];
    [self.view bringSubviewToFront:self.hoverView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refresh_today_task" object:nil];
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
    
    //排序
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.unfinishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.finishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    
    //按类别
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.unfinishedTaskArr withType:self.selectedColorNum]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.finishedTaskArr withType:self.selectedColorNum]];
    
    //设置进度
    [self refreshProgress];
    
    [self.tableView reloadData];
    
    [self.tableView reloadEmptyDataSet];
    
    [self fadeAnimation];
    
    [self setBadge];
}

- (void)setBadge{
    UIApplication *application = [UIApplication sharedApplication];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]){
        NSUInteger count = self.unfinishedTaskArr.count;
        [application setApplicationIconBadgeNumber:count];
        if(count > 0){
            self.tabBarController.tabBar.items[0].badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)self.unfinishedTaskArr.count];
        }else{
            self.tabBarController.tabBar.items[0].badgeValue = NULL;
        }
    }else{
        [application setApplicationIconBadgeNumber:0];
        self.tabBarController.tabBar.items[0].badgeValue = NULL;
    }
}

- (void)refreshProgress{
    NSUInteger finished = self.finishedTaskArr.count;
    NSUInteger total = self.finishedTaskArr.count + self.unfinishedTaskArr.count;
    [self.progressLabel setProgressWithFinished:finished andTotal:total];
}

- (IBAction)chooseDateAction:(id)sender{
    [self navigationTitleViewTapped];
}

#pragma mark - Choose Date

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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除吗？" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - DZNEmptyDelegate

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.finishedTaskArr.count + self.unfinishedTaskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
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

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    NSDate *tempDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    self.selectedDate = tempDate;
    [self hideTip];
    [self loadTasks];
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
    if (self.hoverView.isShow) {
        [self.hoverView hide];
    } else {
        [self.hoverView show];
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
