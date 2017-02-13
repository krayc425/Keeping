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
#import "TaskDataHelper.h"

#define ANIMATION_TYPE @"fade"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])

@interface KPTaskTableViewController () <MLKMenuPopoverDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) UIView *background;   //图片放大的背景

@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;

@end

@implementation KPTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortFactor = @"sortName";
    self.isAscend = true;
    
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //星期代理
    self.weekDayView.weekdayDelegate = self;
    self.weekDayView.isAllSelected = YES;
    self.weekDayView.isAllButtonHidden = NO;
    self.weekDayView.fontSize = 18.0;
    
    //类别代理
    self.colorView.colorDelegate = self;
    
    //page 指示 stack
    self.weekDayView.hidden = NO;
    self.colorView.hidden = YES;
    for(UIImageView *imgView in self.pageStack.subviews){
        UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imgView setImage:img];
    }
    [self.pageStack.subviews[0] setTintColor:[Utilities getColor]];
    [self.pageStack.subviews[1] setTintColor:[UIColor groupTableViewBackgroundColor]];
    
    UISwipeGestureRecognizer *swipeGRLeft1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    UISwipeGestureRecognizer *swipeGRRight1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeGRLeft1.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGRRight1.direction = UISwipeGestureRecognizerDirectionRight;
    UISwipeGestureRecognizer *swipeGRLeft2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    UISwipeGestureRecognizer *swipeGRRight2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    swipeGRLeft2.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGRRight2.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.colorView addGestureRecognizer:swipeGRLeft1];
    [self.colorView addGestureRecognizer:swipeGRRight1];
    [self.weekDayView addGestureRecognizer:swipeGRLeft2];
    [self.weekDayView addGestureRecognizer:swipeGRRight2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
    [self setFont];
}

- (void)setFont{
    [self.weekDayView setFont];
}

- (void)swipeAction:(UISwipeGestureRecognizer *)sender{
    
    if([self.colorView isHidden]){
        [self.colorView setHidden:NO];
        [self.weekDayView setHidden:YES];
        
        [self.pageStack.subviews[0] setTintColor:[UIColor groupTableViewBackgroundColor]];
        [self.pageStack.subviews[1] setTintColor:[Utilities getColor]];
    }else{
        [self.colorView setHidden:YES];
        [self.weekDayView setHidden:NO];
        
        [self.pageStack.subviews[0] setTintColor:[Utilities getColor]];
        [self.pageStack.subviews[1] setTintColor:[UIColor groupTableViewBackgroundColor]];
    }

    [self fadeAnimation];
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

- (void)loadTasksOfWeekdays:(NSArray *)weekDays{
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    //按星期
    self.taskArr = [[TaskManager shareInstance] getTasksOfWeekdays:weekDays];
    
    //按类别
    self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.taskArr
                                                                       withType:self.selectedColorNum]];
    
    for(Task *t in self.taskArr){
        //（结束日加一天以后 才是到期）
        if([[t.endDate dateByAddingDays:1] isEarlierThan:[NSDate date]]){
            [self.historyTaskArr addObject:t];
        }
    }
    for(Task *t in self.historyTaskArr){
        [self.taskArr removeObject:t];
    }
    
    //排序
    self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.taskArr withSortFactor:self.sortFactor isAscend:self.isAscend]];
    self.historyTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.historyTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend]];
    
    [self.tableView reloadData];
    
    [self fadeAnimation];
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
        
        Task *t;
        
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
        }
        [cell.nameLabel setText:t.name];
        
        [cell.weekdayView selectWeekdaysInArray:[NSMutableArray arrayWithArray:t.reminderDays]];
        [cell.weekdayView setIsAllSelected:NO];
        [cell.weekdayView setUserInteractionEnabled:NO];
        
        if(t.type > 0){
            UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
            img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.typeImg.tintColor = [Utilities getTypeColorArr][t.type - 1];
            [cell.typeImg setImage:img];
        }else{
            [cell.typeImg setImage:[UIImage new]];
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
    if([self.sortFactor isEqualToString:[[Utilities getTaskSortArr] allValues][selectedIndex]]){
        self.isAscend = !self.isAscend;
    }else{
        self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
        self.isAscend = true;
    }
    NSLog(@"按%@排序", self.sortFactor);
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
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

#pragma mark - KPWeekdayPickerDelegate

- (void)didChangeWeekdays:(NSArray *_Nonnull)selectWeekdays{
    self.selectedWeekdayArr = [NSMutableArray arrayWithArray:selectWeekdays];
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

#pragma mark - KPColorPickerDelegate

- (void)didChangeColors:(int)selectColorNum{
    self.selectedColorNum = selectColorNum;
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

@end
