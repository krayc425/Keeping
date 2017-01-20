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

@interface KPCalViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation KPCalViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(10, 64 + 10, view.frame.size.width -20, 320)];
    cardView.cornerRadius = 10;
    cardView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cardView];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 5, cardView.frame.size.width - 10, 310)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
    self.calendar.appearance.headerDateFormat = @"yyyy年MM月";
    self.calendar.appearance.titleFont = [UIFont fontWithName:[Utilities getFont] size:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.weekdayFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.subtitleFont = [UIFont fontWithName:[Utilities getFont] size:10.0];
    self.calendar.appearance.headerTitleColor = [Utilities getColor];
    self.calendar.appearance.weekdayTextColor = [Utilities getColor];
    self.calendar.appearance.selectionColor = [Utilities getColor];
    [cardView addSubview:self.calendar];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(5, 5, 95, 34);
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
    nextButton.frame = CGRectMake(CGRectGetWidth(cardView.frame)-100, 5, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"icon_next"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 330 + 64 + 5, view.frame.size.width, view.frame.size.height - 330 - 64 - 44 - 6) style:UITableViewStylePlain];
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.backgroundColor = [UIColor clearColor];
    
    self.taskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.taskTableView.emptyDataSetSource = self;
    self.taskTableView.emptyDataSetDelegate = self;
    self.taskTableView.tableHeaderView = [UIView new];
    //[[UIView alloc] initWithFrame:CGRectMake(0, 330 + 64 + 5, view.frame.size.width, 5)];
    self.taskTableView.tableFooterView = [UIView new];

    [self.view addSubview:self.taskTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
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
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPCalTaskTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPCalTaskTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPCalTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Task *t = [self.taskArr objectAtIndex:indexPath.row];
    
    if([t.punchDateArr containsObject:[DateUtil transformDate:self.selectedDate]]){
        [cell setIsFinished:YES];
    }else{
        [cell setIsFinished:NO];
    }
    [cell.taskNameLabel setText:t.name];
    
    [cell.punchDaysLabel setText:[NSString stringWithFormat:@"已完成 %lu 天", (unsigned long)[t.punchDateArr count]]];
    
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

@end
