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
#import "KPTaskDetailTableViewController.h"
#import "MLKMenuPopover.h"
#import "KPImageViewController.h"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])

@interface KPTaskTableViewController () <MLKMenuPopoverDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) UIView *background;   //图片放大的背景

@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;

@end

@implementation KPTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.sortFactor = @"addDate";
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
    [self selectAllWeekDay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:18.0]];
        }else{
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0]];
        }
    }
    
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (void)loadTasksOfWeekdays:(NSArray *)weekDays{
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.reminderDays in %@", weekDays];
    self.taskArr = [NSMutableArray arrayWithArray:[[[TaskManager shareInstance] getTasks] filteredArrayUsingPredicate:predicate]];
    
    for(Task *t in self.taskArr){
        if([t.endDate isEarlierThan:[NSDate date]]){
            [self.historyTaskArr addObject:t];
        }
    }
    for(Task *t in self.historyTaskArr){
        [self.taskArr removeObject:t];
    }
    
    //排序
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for(NSString *str in [self.sortFactor componentsSeparatedByString:@"|"]){
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:str ascending:YES];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    self.taskArr = [NSMutableArray arrayWithArray:[self.taskArr sortedArrayUsingDescriptors:sortDescriptors]];
    self.historyTaskArr = [NSMutableArray arrayWithArray:[self.historyTaskArr sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self.tableView reloadData];
}

- (void)addAction:(id)senders{
    [self performSegueWithIdentifier:@"addTaskSegue" sender:nil];
}

- (void)editAction:(id)senders{
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
}

- (IBAction)selectWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIImage *buttonImg;
    NSNumber *tag = [NSNumber numberWithInteger:btn.tag];
    
    if([self.selectedWeekdayArr containsObject:tag]){
        //包含
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
    
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (IBAction)selectAllWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([btn.titleLabel.text isEqualToString:@"全选"]){
        [self selectAllWeekDay];
    }else if([btn.titleLabel.text isEqualToString:@"清空"]){
        [self deselectAllWeekDay];
    }
}

- (void)selectAllWeekDay{
    [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            NSNumber *tag = [NSNumber numberWithInteger:button.tag];
            if(![self.selectedWeekdayArr containsObject:tag]){
                [self selectWeekdayAction:button];
            }
        }
    }
}

- (void)deselectAllWeekDay{
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

#pragma mark - Pop Up Image

- (void)passImg:(UIImage *)img{
    [self performSegueWithIdentifier:@"imageSegue" sender:img];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        default:
            return 1;
        case 1:
            return [self.taskArr count];
        case 2:
            return [self.historyTaskArr count];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
        {
            if([self.taskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:@"进行中"];
                return view;
            }
        }
            break;
        case 2:
        {
            if([self.historyTaskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:@"已结束"];
                return view;
            }
        }
            break;
        default:
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
        {
            if([self.taskArr count] == 0){
                return 0.00001f;
            }else{
                return 20.0f;
            }
        }
        case 2:
        {
            if([self. historyTaskArr count] == 0){
                return 0.00001f;
            }else{
                return 20.0f;
            }
        }
        default:
            return 0.00001f;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if(section == 0){
        return [UIView new];
//    }else{
//        return [super tableView:tableView viewForFooterInSection:section];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    if(section == 0){
        return 0.00001f;
//    }else{
//        return [super tableView:tableView heightForFooterInSection:section];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section != 0){
        [self performSegueWithIdentifier:@"detailTaskSegue" sender:indexPath];
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
    if (indexPath.section == 0) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }else{
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0){
        static NSString *cellIdentifier = @"KPTaskTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"KPTaskTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        KPTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell setFont];
        
        cell.backgroundColor = [UIColor clearColor];
        
        
        Task *t;
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
        }
        [cell.nameLabel setText:t.name];
        
        for(UIButton *button in cell.weekDayStack.subviews){
            if([t.reminderDays containsObject:@(button.tag)]){
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
                buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
            }else{
                [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                
                UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
                buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
            }
        }
        
        NSString *reminderTimeStr = @"";
        if(t.reminderTime != NULL){
            [cell.daysLabel setHidden:NO];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            reminderTimeStr = [dateFormatter stringFromDate:t.reminderTime];
        }else{
            [cell.daysLabel setHidden:YES];
        }
        [cell.daysLabel setText:reminderTimeStr];
        
        if(t.image != NULL){
            [cell.taskImgViewBtn setUserInteractionEnabled:YES];
            [cell.taskImgViewBtn setBackgroundImage:[UIImage imageWithData:t.image] forState:UIControlStateNormal];
            cell.delegate = self;
        }else{
            [cell.taskImgViewBtn setUserInteractionEnabled:NO];
            [cell.taskImgViewBtn setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
        }
        
//        NSString *dateStr =  [t.addDate formattedDateWithFormat:@"YYYY/MM/dd HH:mm:ss"];
        [cell.totalDayLabel setText:[NSString stringWithFormat:@"已添加 %ld 天, 已完成 %lu 天", (long)[[NSDate date] daysFrom:t.addDate] + 1, (unsigned long)[t.punchDateArr count]]];
        
        int totalPunchNum = [[TaskManager shareInstance] totalPunchNumberOfTask:t];
        int punchNum = (int)[t.punchDateArr count];
        //暂时 NO
        [cell.progressView setProgress:totalPunchNum == 0 ? 0 : (float)punchNum / totalPunchNum animated:NO];
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
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
        Task *t;
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
            
            [self.taskArr removeObject:t];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
            
            [self.historyTaskArr removeObject:t];
        }
        
        [[TaskManager shareInstance] deleteTask:t];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(self.taskArr.count == 0 || self.historyTaskArr.count == 0){
            [self.tableView reloadData];
        }
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
    return @"删除";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"imageSegue"]){
        KPImageViewController *imageVC = (KPImageViewController *)[segue destinationViewController];
        [imageVC setImg:(UIImage *)sender];
    }else if([segue.identifier isEqualToString:@"detailTaskSegue"]){
        KPTaskDetailTableViewController *kptdtvc = (KPTaskDetailTableViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        if(indexPath.section == 1){
            [kptdtvc setTask:self.taskArr[indexPath.row]];
        }else if(indexPath.section == 2){
            [kptdtvc setTask:self.historyTaskArr[indexPath.row]];
        }
    }else if([segue.identifier isEqualToString:@"addTaskSegue"]){
        KPTaskDetailTableViewController *kptdtvc = (KPTaskDetailTableViewController *)[segue destinationViewController];
        [kptdtvc setTask:NULL];
    }
}

#pragma mark - DZN Empty Delegate

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
    
    return [[NSAttributedString alloc] initWithString:@"去新增任务" attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    [self addAction:self];
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.taskArr.count == 0 && self.historyTaskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
    NSLog(@"按%@排序", self.sortFactor);
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

@end
