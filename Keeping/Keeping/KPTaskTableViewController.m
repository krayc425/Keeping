//
//  KPTaskTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskTableViewController.h"
#import "KPSeparatorView.h"
#import "TaskManager.h"
#import "Task.h"
#import "KPTaskTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Utilities.h"
#import "DateTools.h"
#import "DateUtil.h"

@interface KPTaskTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation KPTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskArr = [[NSMutableArray alloc] init];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    self.taskArr = [[TaskManager shareInstance] getTasks];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addAction:(id)senders{
    [self performSegueWithIdentifier:@"addTaskSegue" sender:nil];
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
    static NSString *cellIdentifier = @"KPTaskTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPTaskTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Task *t = self.taskArr[indexPath.row];
    [cell.nameLabel setText:t.name];
    
    NSString *reminderDayStr = @"";
    if([t.reminderDays count] > 0){
        NSArray *arr = t.reminderDays;
        
        if([arr isEqualToArray:@[@(1),@(2),@(3),@(4),@(5),@(6),@(7)]]){
            reminderDayStr = @"每天";
        }else if([arr isEqualToArray:@[@(2),@(3),@(4),@(5),@(6)]]){
            reminderDayStr = @"工作日";
        }else if([arr isEqualToArray:@[@(1),@(7)]]){
            reminderDayStr = @"周末";
        } else{
            for (NSNumber *i in arr) {
                reminderDayStr = [reminderDayStr stringByAppendingString:[NSString stringWithFormat:@"%@, ", [DateUtil getWeekdayStr:[i intValue]]]];
            }
            reminderDayStr = [reminderDayStr substringToIndex:reminderDayStr.length - 2];
        }
        
        [cell.daysLabel setHidden:NO];
    }else{
        [cell.daysLabel setHidden:YES];
    }
    
    NSString *reminderTimeStr = @"";
    if(t.reminderTime != NULL){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        reminderTimeStr = [reminderTimeStr stringByAppendingString:@", "];
        reminderTimeStr = [reminderTimeStr stringByAppendingString:[dateFormatter stringFromDate:t.reminderTime]];
    }
    
    [cell.daysLabel setText:[reminderDayStr stringByAppendingString:reminderTimeStr]];
    
    NSString *dateStr =  [t.addDate formattedDateWithFormat:@"YYYY/MM/dd HH:mm:ss"];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *t = self.taskArr[indexPath.row];
        
        [[TaskManager shareInstance] deleteTask:t.id];
        
        [self.taskArr removeObject:t];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"addTaskSegue"]){
        
    }
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

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:15.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:@"添加任务" attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    [self addAction:self];
}

@end
