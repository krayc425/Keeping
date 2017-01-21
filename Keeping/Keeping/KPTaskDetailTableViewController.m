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
#import "UIView+MJAlertView.h"
#import "KPTaskExtraTableViewController.h"
#import "DateUtil.h"
#import "DateTools.h"

@interface KPTaskDetailTableViewController ()

@end

@implementation KPTaskDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"任务详情"];
    self.clearsSelectionOnViewWillAppear = NO;
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_NEXT"] style:UIBarButtonItemStylePlain target:self action:@selector(nextAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    //任务名
    [self.taskNameField setFont:[UIFont fontWithName:[Utilities getFont] size:25.0]];
    //星期几选项按钮
    for(UIButton *button in self.weekDayStack.subviews){
        [button setTintColor:[Utilities getColor]];
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        if(button.tag != -1){
            //-1是全选按钮
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:18.0]];
            UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
            buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
        }else{
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0]];
        }
    }
    
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
//    self.calendar.appearance.todayColor = [UIColor whiteColor];
//    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    
    self.calendar.allowsSelection = NO;
    
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.taskNameField setText:[self.task name]];
    
    self.selectedWeekdayArr = [NSMutableArray arrayWithArray:self.task.reminderDays];
    for(NSNumber *num in self.selectedWeekdayArr){
        UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
        buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.weekDayStack.subviews[num.integerValue-1] setBackgroundImage:buttonImg forState:UIControlStateNormal];
        [self.weekDayStack.subviews[num.integerValue-1] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (void)hideKeyboard{
    [self.taskNameField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)checkCompleted{
    if([self.taskNameField.text isEqualToString:@""]){
        return NO;
    }
    if([self.selectedWeekdayArr count] <= 0){
        return NO;
    }
    return YES;
}

- (void)nextAction:(id)sender{
    if(![self checkCompleted]){
        [UIView addMJNotifierWithText:@"信息填写不完整" dismissAutomatically:YES];
    }else{
        [self performSegueWithIdentifier:@"addExtraSegue" sender:nil];
    }
}

- (IBAction)selectWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIImage *buttonImg;
    NSNumber *tag = [NSNumber numberWithInteger:btn.tag];
    //包含
    if([self.selectedWeekdayArr containsObject:tag]){
        buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
        [self.selectedWeekdayArr removeObject:tag];
        [btn setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    }else{
        //不包含
        buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
        [self.selectedWeekdayArr addObject:tag];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setBackgroundImage:buttonImg forState:UIControlStateNormal];
    
    if([self.selectedWeekdayArr count] > 0){
        [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    }else{
        [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    }
    
    [self.calendar reloadData];
}

- (IBAction)selectAllWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([btn.titleLabel.text isEqualToString:@"全选"]){
        [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
        for(UIButton *button in self.weekDayStack.subviews){
            if(button.tag != -1){
                NSNumber *tag = [NSNumber numberWithInteger:button.tag];
                if(![self.selectedWeekdayArr containsObject:tag]){
                    [self selectWeekdayAction:button];
                }
            }
        }
    }else if([btn.titleLabel.text isEqualToString:@"清空"]){
        [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
        for(UIButton *button in self.weekDayStack.subviews){
            if(button.tag != -1){
                NSNumber *tag = [NSNumber numberWithInteger:button.tag];
                if([self.selectedWeekdayArr containsObject:tag]){
                    [self selectWeekdayAction:button];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
    switch (section) {
        case 0:
            [view setText:@"任务名"];
            break;
        case 1:
            [view setText:@"完成时间"];
            break;
        case 2:
            [view setText:@"完成情况"];
            break;
        default:
            [view setText:@""];
            break;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"addExtraSegue"]){
        KPTaskExtraTableViewController *kpstvc = (KPTaskExtraTableViewController *)[segue destinationViewController];
        self.task.name = self.taskNameField.text;
        self.task.reminderDays = self.selectedWeekdayArr;
        kpstvc.task = self.task;
    }
}

#pragma mark - FSCalendar Delegate

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date{
    //打了卡的日子
    if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
        return [Utilities getColor];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    //打了卡的日子
    if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
        return [UIColor whiteColor];
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date{
    //未来应该打卡的日子、打了卡的日子、没打卡的日子
    if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
        return [Utilities getColor];
    }
    if([self.task.addDate isEarlierThanOrEqualTo:date] && [self.selectedWeekdayArr containsObject:@(date.weekday)]){
        if([[NSDate date] isEarlierThanOrEqualTo:date]){
            return [Utilities getColor];
        }else{
            return [UIColor redColor];
        }
    }
    return appearance.borderDefaultColor;
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    //创建日期
    return [self.task.addDate isEqualToDate:date];
}

@end
