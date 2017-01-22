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
#import "UIScrollView+EmptyDataSet.h"

@interface KPTodayTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.progressLabel setFont:[UIFont fontWithName:[Utilities getFont] size:40.0f]];
    [self.dateLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    
    /*
     NSArray *fontFamilies = [UIFont familyNames];
     for (int i = 0; i < [fontFamilies count]; i++){
     NSString *fontFamily = [fontFamilies objectAtIndex:i];
     NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
     NSLog (@"%@: %@", fontFamily, fontNames);
     }
     */
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.dateLabel setText:[DateUtil getTodayDate]];
    [self loadTasks];
}

- (void)loadTasks{
    self.unfinishedTaskArr = [[NSMutableArray alloc] init];
    self.finishedTaskArr = [[NSMutableArray alloc] init];
    NSMutableArray *taskArr = [[TaskManager shareInstance] getTodayTasks];
    for (Task *task in taskArr) {
        if([task.punchDateArr containsObject:[DateUtil transformDate:[NSDate date]]]){
            [self.finishedTaskArr addObject:task];
        }else{
            [self.unfinishedTaskArr addObject:task];
        }
    }
    
    [self.progressLabel setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.finishedTaskArr.count, ((unsigned long)self.finishedTaskArr.count + (unsigned long)self.unfinishedTaskArr.count)]];
    
    [self.tableView reloadData];
    
    [self.tableView reloadEmptyDataSet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
                return 20.0f;
            }
        }
        case 2:
        {
             return 20.0f;
        }
        default:
            return 0.00001f;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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
            
            Task *t;
            if(indexPath.section == 1){
                t = self.unfinishedTaskArr[indexPath.row];
                
                cell.delegate = self;
                [cell setIsFinished:NO];
            }else{
                t = self.finishedTaskArr[indexPath.row];
                
                [cell setIsFinished:YES];
            }
            [cell.taskNameLabel setText:t.name];
            
            [cell.accessoryLabel setText:@""];
            [cell.accessoryLabel setHidden:YES];
            if(t.appScheme != NULL){
                [cell.accessoryLabel setHidden:NO];
                
                NSDictionary *d = t.appScheme;
                NSString *s = d.allKeys[0];
                [cell.accessoryLabel setText:[NSString stringWithFormat:@"启动 %@", s]];
            }
            
            
            if(t.link != NULL && ![t.link isEqualToString:@""]){
                [cell.accessoryLabel setHidden:NO];
                
                if(![cell.accessoryLabel.text isEqualToString:@""]){
                    [cell.accessoryLabel setText:[cell.accessoryLabel.text stringByAppendingString:@", "]];
                }
                [cell.accessoryLabel setText:[cell.accessoryLabel.text stringByAppendingString:@"1 条链接"]];
            }
            
            NSString *reminderTimeStr = @"";
            if(t.reminderTime != NULL){
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"HH:mm"];
                reminderTimeStr = [dateFormatter stringFromDate:t.reminderTime];
                
                [cell.reminderLabel setText:reminderTimeStr];
                
                [cell.reminderLabel setHidden:NO];
            }else{
                [cell.reminderLabel setHidden:YES];
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
        return 70;
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
        Task *t;
        if(indexPath.section == 1){
            t = self.unfinishedTaskArr[indexPath.row];
        }else if(indexPath.section == 2){
            t = self.finishedTaskArr[indexPath.row];
        }
        if(t.appScheme != NULL){
            NSString *s = t.appScheme.allValues[0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]];
        }
    }
    
}

#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    Task *task = self.unfinishedTaskArr[path.row];
    [[TaskManager shareInstance] punchForTaskWithID:@(task.id)];
    [self loadTasks];
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

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.finishedTaskArr.count + self.unfinishedTaskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
}

@end
