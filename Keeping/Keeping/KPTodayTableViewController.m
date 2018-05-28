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
#import "MLKMenuPopover.h"
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

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTodayTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MLKMenuPopoverDelegate>

@property (nonatomic, strong) MLKMenuPopover *_Nonnull menuPopover;
@property (strong, nonatomic) NSIndexPath* editingIndexPath;  //当前左滑cell的index，在代理方法中设置

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    self.selectedDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    //类别按钮
    [KPTodayTableViewController shareColorPickerView].colorDelegate = self;
    [[KPTodayTableViewController shareColorPickerView] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 32, 40)];

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
    
    //        self.calendar.appearance.todayColor = [UIColor whiteColor];
    //        self.calendar.appearance.titleTodayColor = [UIColor whiteColor];
    self.calendar.appearance.selectionColor =  [Utilities getColor];
    self.calendar.appearance.titleSelectionColor = [UIColor whiteColor];
    //        self.calendar.appearance.todaySelectionColor = [Utilities getColor];
    
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadTasks];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.selectedIndexPath = NULL;
    [self.tableView reloadData];
    [self hideTip];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.editingIndexPath) {
        [self configSwipeButtons];
    }
}

- (void)loadTasks{
    NSDictionary *sortDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"sort"];
    self.sortFactor = sortDict.allKeys[0];
    self.isAscend = sortDict.allValues[0];
    
    [self.subDateLabel setText:[DateUtil getTodayDateStringOfDate:self.selectedDate]];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.selectedDate.day] forState:UIControlStateNormal];
    
    self.selectedIndexPath = NULL;
    
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
    
    //设置进度
    NSUInteger finished = self.finishedTaskArr.count;
    NSUInteger total = self.finishedTaskArr.count + self.unfinishedTaskArr.count;
    [self.progressButton setProgressWithFinished:(int)finished andTotal:(int)total];
    
    //排序
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.unfinishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.finishedTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    
    //按类别
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.unfinishedTaskArr withType:self.selectedColorNum]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.finishedTaskArr withType:self.selectedColorNum]];
    
    [self.tableView reloadData];
    
    [self.tableView reloadEmptyDataSet];
    
    [self fadeAnimation];
    
    //设置角标
    [self setBadge];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)editAction:(id)sender{
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
}

#pragma mark - Choose Date

- (IBAction)chooseDateAction:(id)sender{
    AMPopTip *tp = [KPTodayTableViewController shareTipInstance];
    
    if(![tp isVisible] && ![tp isAnimating]){
        
        [tp showCustomView:self.calendar
                 direction:AMPopTipDirectionDown
                    inView:self.tableView
                 fromFrame:CGRectOffset(self.dateButton.frame, 23, 0)]; //这个23咋回事
        
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

#pragma mark - Set Swipe Cells

- (void)configSwipeButtons {
    // 获取选项按钮的reference
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.tableView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subview.subviews count] >= 1) {
                // 和iOS 10的按钮顺序相反
                UIButton *moreButton = subview.subviews[0];
                
                [self configMoreButton:moreButton];
                [subview setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            }
        }
    } else {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        KPTodayTableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
        for (UIView *subview in tableCell.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count] >= 1) {
                UIButton *moreButton = subview.subviews[0];
                
                [self configMoreButton:moreButton];
                [subview setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            }
        }
    }
}

- (void)configMoreButton:(UIButton *)moreButton {
    if (moreButton) {
        [moreButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(0, 5, moreButton.frame.size.width - 5, moreButton.frame.size.height - 10)];
        cardView.cornerRadius = 10.0f;
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       70,
                                                                       cardView.frame.size.height)];
        [infoLabel setText:@"详情"];
        [infoLabel setTextColor:[Utilities getColor]];
        [infoLabel setNumberOfLines:2];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [cardView addSubview:infoLabel];
        
        [moreButton addSubview:cardView];
    }
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
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0){
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *task;
        if(indexPath.section == 1){
            task = self.unfinishedTaskArr[indexPath.row];
        }else{
            task = self.finishedTaskArr[indexPath.row];
        }
        [self performSegueWithIdentifier:@"detailTaskSegue" sender:task];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section != 0){
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"               ";
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.editingIndexPath = indexPath;
    [self.view setNeedsLayout];   // 触发-(void)viewDidLayoutSubviews
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.editingIndexPath = nil;
}

#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //section = 1 : 未完成
    if(path.section == 1){
        Task *task = self.unfinishedTaskArr[path.row];
        [[TaskManager shareInstance] punchForTaskWithID:@(task.id) onDate:self.selectedDate];
        [self loadTasks];
    }else if(path.section == 2){
        Task *task = self.finishedTaskArr[path.row];
        [[TaskManager shareInstance] unpunchForTaskWithID:@(task.id) onDate:self.selectedDate];
        [self loadTasks];
    }
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
    NSString *text = @"没有任务";
    
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
    NSDate *tempDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    self.selectedDate = tempDate;
    [self hideTip];
    [self loadTasks];
}

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    if([self.sortFactor isEqualToString:[[Utilities getTaskSortArr] allValues][selectedIndex]]){
        if(self.isAscend.intValue == true){
            self.isAscend = @(0);
        }else{
            self.isAscend = @(1);
        }
    }else{
        self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
        self.isAscend = @(1);
    }
    [[NSUserDefaults standardUserDefaults] setValue: @{self.sortFactor : self.isAscend} forKey:@"sort"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
