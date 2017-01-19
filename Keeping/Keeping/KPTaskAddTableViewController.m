//
//  KPTaskAddTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskAddTableViewController.h"
#import "KPSeparatorView.h"
#import "Utilities.h"
#import "TaskManager.h"
#import "UIView+MJAlertView.h"
#import "KPSchemeManager.h"
#import "DateTools.h"

@interface KPTaskAddTableViewController ()

@end

@implementation KPTaskAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"新增任务"];
    self.clearsSelectionOnViewWillAppear = NO;
    //导航栏右上角
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_DONE"] style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItems = @[okItem];
    //任务名
    [self.taskNameField setFont:[UIFont fontWithName:[Utilities getFont] size:25.0]];
    //提醒标签
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
    //提醒开关
    [self.reminderSwitch setOn:NO];
    [self.reminderSwitch setTintColor:[Utilities getColor]];
    [self.reminderSwitch setOnTintColor:[Utilities getColor]];
    [self.reminderSwitch addTarget:self action:@selector(showReminderPickerAction:) forControlEvents:UIControlEventValueChanged];
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
    self.selectedWeekdayArr = [[NSMutableArray alloc] init];
    //APP名字标签
    [self.appNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0]];
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

- (void)doneAction:(id)sender{
    if(![self checkCompleted]){
        [UIView addMJNotifierWithText:@"信息填写不完整" dismissAutomatically:YES];
    }else{
        Task *task = [Task new];
        task.name = self.taskNameField.text;
        task.appScheme = self.selectedApp;
        
        //排序
        [self.selectedWeekdayArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *n1 = (NSNumber *)obj1;
            NSNumber *n2 = (NSNumber *)obj2;
            NSComparisonResult result = [n1 compare:n2];
            return result == NSOrderedDescending;
        }];
        task.reminderDays = self.selectedWeekdayArr;
        
        task.reminderTime = self.reminderTime;
        
//        NSDate *date = [NSDate date];
//        NSInteger year = date.year;
//        NSInteger month = date.month;
//        NSInteger day = date.day;
//        NSInteger hour = date.hour;
//        NSInteger minute= date.minute;
//        NSInteger second = date.second;
//        NSLog(@"year: %ld, month: %ld, day %ld, H %ld M %ld S %ld",
//              (long)year, (long)month, (long)day, (long)hour, (long)minute, (long)second);
        
        NSDate *addDate = [NSDate dateWithYear:[[NSDate date] year] month:[[NSDate date] month] day:[[NSDate date] day]];
        task.addDate = addDate;
        
        task.punchDateArr = [[NSMutableArray alloc] init];
        
        [[TaskManager shareInstance] addTask:task];
        
        [UIView addMJNotifierWithText:@"添加成功" dismissAutomatically:YES];
    }
}

- (void)showReminderPickerAction:(id)sender{
    if(![self.reminderSwitch isOn]){
        [self.reminderLabel setText:@"无"];
    }else{
        [self performSegueWithIdentifier:@"reminderSegue" sender:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
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
            [view setText:@"提醒"];
            break;
        case 3:
            [view setText:@"选择 APP"];
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
    
    if(indexPath.section == 3 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"appSegue" sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"appSegue"]){
        KPSchemeTableViewController *kpstvc = (KPSchemeTableViewController *)[segue destinationViewController];
        kpstvc.delegate = self;
        if(self.selectedApp != NULL){
            [kpstvc setSelectedPath:[NSIndexPath indexPathForRow:[[KPSchemeManager getSchemeArr] indexOfObject:self.selectedApp] inSection:0]];
        }
    }else if([segue.identifier isEqualToString:@"reminderSegue"]){
        KPReminderViewController *kprvc = (KPReminderViewController *)[segue destinationViewController];
        kprvc.delegate = self;
    }
}

#pragma mark - Scheme Delegate

- (void)passScheme:(NSDictionary *)value{
    if([value.allKeys[0] isEqualToString:@""]){
        self.selectedApp = NULL;
        [self.appNameLabel setText:@"无"];
        [self.tableView reloadData];
    }else{
        self.selectedApp = value;
        [self.appNameLabel setText:self.selectedApp.allKeys[0]];
        [self.tableView reloadData];
    }
}

#pragma mark - Reminder Delegate

- (void)passTime:(NSDate *)date{
    if(date == nil){
        [self.reminderSwitch setOn:NO animated:YES];
        [self.reminderLabel setText:@"无"];
    }else{
        self.reminderTime = date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        [self.reminderLabel setText:currentDateStr];
    }
    [self.tableView reloadData];
}

@end
