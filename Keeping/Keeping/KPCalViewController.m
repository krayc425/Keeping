//
//  KPCalViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPCalViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"
#import "DateTools.h"
#import "DateUtil.h"
#import "CardsView.h"
#import "KPCalTaskTableViewCell.h"
#import "MLKMenuPopover.h"
#import "TaskDataHelper.h"
#import "SCLAlertView.h"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])

@interface KPCalViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MLKMenuPopoverDelegate>

@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;

@end

@implementation KPCalViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(10, 64 + 10, view.frame.size.width -20, 250)];
    cardView.cornerRadius = 10;
    cardView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cardView];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 5, cardView.frame.size.width - 10, 240)];
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
    previousButton.frame = CGRectMake(5, 10, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"icon_prev"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:previousButton];
    self.previousButton = previousButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(cardView.frame)-100, 10, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"icon_next"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 260 + 64 + 5, view.frame.size.width, view.frame.size.height - 260 - 64 - 44 - 6) style:UITableViewStylePlain];
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.backgroundColor = [UIColor clearColor];
    
    self.taskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.taskTableView.emptyDataSetSource = self;
    self.taskTableView.emptyDataSetDelegate = self;
    self.taskTableView.tableHeaderView = [UIView new];
    self.taskTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 10)];
    self.taskTableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self.view addSubview:self.taskTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.task = NULL;
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunchCal"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunchCal"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showInfo:@"小提示" subTitle:@"点击每项任务查看进度\n红色圆圈代表当天未完成，点击可以补打卡\n蓝色圆圈代表未来应当完成的日期\n蓝色实心圆圈代表打了卡的日期\n日期下方的小蓝点代表添加/结束日期" closeButtonTitle:@"好的" duration:0.0f];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTasks{
    self.taskArr = [[TaskManager shareInstance] getTasks];
    
    //排序
    self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.taskArr withSortFactor:self.sortFactor isAscend:self.isAscend]];
    
    [self.calendar reloadData];
    [self.calendar reloadInputViews];
    [self.taskTableView reloadData];
    
    [self fadeAnimation];
}

- (void)viewWillAppear:(BOOL)animated{
    self.task = NULL;
    [self setFont];
    [self loadTasks];
}

- (void)setFont{
    self.calendar.appearance.titleFont = [UIFont fontWithName:[Utilities getFont] size:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.weekdayFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.subtitleFont = [UIFont fontWithName:[Utilities getFont] size:10.0];
}

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

- (void)editAction:(id)sender{
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskArr count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.task isEqual:self.taskArr[indexPath.row]]){
        self.task = NULL;
    }else{
        self.task = self.taskArr[indexPath.row];
    }
    
    [self.calendar reloadInputViews];
    [self.calendar reloadData];
    
    [self.taskTableView reloadData];
    
    [self fadeAnimation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPCalTaskTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPCalTaskTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPCalTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setFont];
    
    Task *t = self.taskArr[indexPath.row];
    
    if([t isEqual:self.task]){
        [cell setIsSelected:YES];
    }else{
        [cell setIsSelected:NO];
    }
    
    [cell.taskNameLabel setText:t.name];
    
    //类别
    if(t.type > 0){
        UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.typeImg.tintColor = [Utilities getTypeColorArr][t.type - 1];
        [cell.typeImg setImage:img];
    }else{
        [cell.typeImg setImage:[UIImage new]];
    }
    
    //进度
    int totalPunchNum = [[TaskManager shareInstance] totalPunchNumberOfTask:t];
    int punchNum = (int)[t.punchDateArr count];
    [cell.punchDaysLabel setText:[NSString stringWithFormat:@"已完成 %d 天, 计划完成 %d 天", punchNum, totalPunchNum]];
    [cell.progressView setProgress:totalPunchNum == 0 ? 0 : (float)punchNum / (float)totalPunchNum animated:NO];
    
    return cell;
}

#pragma mark - DZNEmpty Delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"没有任务";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - FSCalendar Delegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    [calendar deselectDate:date];
    if([self canFixPunch:date]){
        
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        
        [alert addButton:@"好的" actionBlock:^(void) {
            [[TaskManager shareInstance] punchForTaskWithID:@(self.task.id) onDate:date];
            NSIndexPath *path = [NSIndexPath indexPathForRow:[self.taskArr indexOfObject:self.task] inSection:0];
            [self loadTasks];
            self.task = self.taskArr[path.row];
        }];
        
        [alert showInfo:@"补打卡" subTitle:[NSString stringWithFormat:@"这个日期您可以为 %@ 补打卡", self.task.name] closeButtonTitle:@"取消" duration:0.0f];
        
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

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [Utilities getColor];
        }
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [UIColor whiteColor];
        }
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date{
    
    if(self.task != NULL){
        //未来应该打卡的日子、打了卡的日子、没打卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [Utilities getColor];
        }
        if([self.task.addDate isEarlierThanOrEqualTo:date] && [self.task.reminderDays containsObject:@(date.weekday)]){
                if(self.task.endDate == NULL){
                    
                    if([[NSDate date] isEarlierThanOrEqualTo:date]){
                        return [Utilities getColor];
                    }else{
                        return [UIColor redColor];
                    }
                    
                }else{
                    
                    if([self.task.endDate isLaterThanOrEqualTo:date]){
                        
                        if([[NSDate date] isEarlierThanOrEqualTo:date]){
                            return [Utilities getColor];
                        }else{
                            return [UIColor redColor];
                        }
                        
                    }else{
                        return [UIColor clearColor];
                    }
                }
        
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

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    if([self.sortFactor isEqualToString:[[Utilities getTaskSortArr] allValues][selectedIndex]]){
        self.isAscend = !self.isAscend;
    }else{
        self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
        self.isAscend = true;
    }
    [self loadTasks];
}

#pragma mark - Fade Animation

- (void)fadeAnimation{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]){
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = [Utilities getAnimationType];
        [self.view.layer addAnimation:animation forKey:@"fadeAnimation"];
    }
}

@end
