//
//  KPCalViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPCalViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "KPTaskTableViewCell.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"
#import "DateTools.h"
#import "DateUtil.h"
#import "KPTodayTableViewCell.h"

@interface KPCalViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation KPCalViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 64, view.frame.size.width, 300)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:calendar];
    self.calendar = calendar;
    
    self.calendar.appearance.headerDateFormat = @"yyyy年MM月";
    self.calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase | FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    
    self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300 + 64, view.frame.size.width, view.frame.size.height - 300 - 64 - 44) style:UITableViewStyleGrouped];
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.backgroundColor = [UIColor whiteColor];
    
    self.taskTableView.emptyDataSetSource = self;
    self.taskTableView.emptyDataSetDelegate = self;
    self.taskTableView.tableHeaderView = [UIView new];
    self.taskTableView.tableFooterView = [UIView new];
    
    [self.view addSubview:self.taskTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTasks{
    NSLog(@"Load Task on : %@", [self.selectedDate description]);
    self.taskArr = [[TaskManager shareInstance] getTasksOfDate:self.selectedDate];
    [self.taskTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    self.selectedDate = [NSDate date];
    [self loadTasks];
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPTodayTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPTodayTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPTodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Task *t = [self.taskArr objectAtIndex:indexPath.row];
    
    //TODO: cell userinteraction?
    [cell setUserInteractionEnabled:NO];
    
    if([t.punchDateArr containsObject:[DateUtil transformDate:self.selectedDate]]){
        [cell setIsFinished:YES];
    }else{
        [cell setIsFinished:NO];
    }
    [cell.taskNameLabel setText:t.name];
    
    if(t.appScheme != NULL){
        NSDictionary *d = t.appScheme;
        NSString *s = d.allKeys[0];
        [cell.accessoryLabel setText:[NSString stringWithFormat:@"启动 %@", s]];
        [cell.accessoryLabel setHidden:NO];
    }else{
        [cell.accessoryLabel setHidden:YES];
    }
    
    return cell;
}

#pragma mark -DZNEmpty Delegate

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
    self.selectedDate = date;
    [self loadTasks];
}

@end
