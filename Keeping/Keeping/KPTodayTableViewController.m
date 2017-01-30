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
#import "KPImageViewController.h"
#import "MLKMenuPopover.h"
#import "AMPopTip.h"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])

@interface KPTodayTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MLKMenuPopoverDelegate>

@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;

@property (nonatomic,strong) AMPopTip *tip;

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sortFactor = @"addDate";
    
//     NSArray *fontFamilies = [UIFont familyNames];
//     for (int i = 0; i < [fontFamilies count]; i++){
//     NSString *fontFamily = [fontFamilies objectAtIndex:i];
//     NSArray *fontNames = [UIFont fontNamesForFamilyName:[fontFamilies objectAtIndex:i]];
//     NSLog (@"%@: %@", fontFamily, fontNames);
//     }
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.progressLabel setFont:[UIFont fontWithName:[Utilities getFont] size:40.0f]];
    [self.dateLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    [self.dateLabel setText:[DateUtil getTodayDate]];
    
    [self loadTasks];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.selectedIndexPath = NULL;
    [self.tip hide];
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
    
    //排序
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for(NSString *str in [self.sortFactor componentsSeparatedByString:@"|"]){
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:str ascending:self.isAscend];
        [sortDescriptors addObject:sortDescriptor];
    }
    self.unfinishedTaskArr = [NSMutableArray arrayWithArray:[self.unfinishedTaskArr sortedArrayUsingDescriptors:sortDescriptors]];
    self.finishedTaskArr = [NSMutableArray arrayWithArray:[self.finishedTaskArr sortedArrayUsingDescriptors:sortDescriptors]];
    
    
    [self.progressLabel setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.finishedTaskArr.count, ((unsigned long)self.finishedTaskArr.count + (unsigned long)self.unfinishedTaskArr.count)]];
    
    [self.tableView reloadData];
    
    [self.tableView reloadEmptyDataSet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addAction:(id)senders{
    [self performSegueWithIdentifier:@"addTaskSegue" sender:nil];
}

- (void)editAction:(id)sender{
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
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
            
            [cell setFont];
            
            cell.delegate = self;
            
            Task *t;
            if(indexPath.section == 1){
                t = self.unfinishedTaskArr[indexPath.row];
                
                [cell setIsFinished:NO];
            }else{
                t = self.finishedTaskArr[indexPath.row];
                
                [cell setIsFinished:YES];
            }
            [cell.taskNameLabel setText:t.name];
            
            [cell.moreButton setHidden:YES];
            if(t.appScheme != NULL){
                [cell.moreButton setHidden:NO];
                
                NSDictionary *d = t.appScheme;
                NSString *s = d.allKeys[0];
                [cell.appButton setTitle:[NSString stringWithFormat:@"%@", s] forState:UIControlStateNormal];
                [cell.appButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.appButton setUserInteractionEnabled:YES];
                
                UIImage *appImg = [UIImage imageNamed:@"TODAY_APP"];
                appImg = [appImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.appImg setImage:appImg];
                [cell.appButton setHidden:NO];
                [cell.appImg setHidden:NO];
            }else{
                [cell.appButton setHidden:YES];
                [cell.appImg setHidden:YES];
            }
            
            if(t.link != NULL && ![t.link isEqualToString:@""]){
                [cell.moreButton setHidden:NO];
                
                [cell.linkButton setTitle:@"链接" forState:UIControlStateNormal];
                [cell.linkButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.linkButton setUserInteractionEnabled:YES];
                
                UIImage *linkImg = [UIImage imageNamed:@"TODAY_LINK"];
                linkImg = [linkImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.linkImg setImage:linkImg];
                [cell.linkButton setHidden:NO];
                [cell.linkImg setHidden:NO];
            }else{
                [cell.linkButton setHidden:YES];
                [cell.linkImg setHidden:YES];
            }
            
            if(t.image != NULL){
                [cell.moreButton setHidden:NO];
                
                [cell.imageButton setTitle:@"图片" forState:UIControlStateNormal];
                [cell.imageButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.imageButton setUserInteractionEnabled:YES];
                
                UIImage *imageImg = [UIImage imageNamed:@"TODAY_IMAGE"];
                imageImg = [imageImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.imageImg setImage:imageImg];
                [cell.imageButton setHidden:NO];
                [cell.imageImg setHidden:NO];
            }else{
                [cell.imageButton setHidden:YES];
                [cell.imageImg setHidden:YES];
            }
            
            if(t.memo != NULL && ![t.memo isEqualToString:@""]){
                [cell.moreButton setHidden:NO];
                
                [cell.memoButton setTitle:@"备注" forState:UIControlStateNormal];
                [cell.memoButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.memoButton setUserInteractionEnabled:YES];
                
                UIImage *imageImg = [UIImage imageNamed:@"TODAY_TEXT"];
                imageImg = [imageImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.memoImg setImage:imageImg];
                [cell.memoButton setHidden:NO];
                [cell.memoImg setHidden:NO];
            }else{
                [cell.memoButton setHidden:YES];
                [cell.memoImg setHidden:YES];
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
            
            if(indexPath == self.selectedIndexPath){
                [cell.cardView2 setHidden:NO];
                
                [cell.moreButton setBackgroundImage:[UIImage imageNamed:@"MORE_INFO_UP"] forState:UIControlStateNormal];
            }else{
                [cell.cardView2 setHidden:YES];
                
                [cell.moreButton setBackgroundImage:[UIImage imageNamed:@"MORE_INFO_DOWN"] forState:UIControlStateNormal];
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
        if([cell.moreButton isHidden]){
            
        }else{
        
            if(self.selectedIndexPath == indexPath){
                self.selectedIndexPath = NULL;
            }else{
                self.selectedIndexPath = indexPath;
            }
        
        }
        
        [tableView reloadData];
        
    }
}

#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //section = 1 : 未完成
    if(path.section == 1){
        Task *task = self.unfinishedTaskArr[path.row];
        [[TaskManager shareInstance] punchForTaskWithID:@(task.id) onDate:[NSDate date]];
        self.selectedIndexPath = NULL;
        [self loadTasks];
    }else if(path.section == 2){
        Task *task = self.finishedTaskArr[path.row];
        [[TaskManager shareInstance] unpunchForTaskWithID:@(task.id)];
        self.selectedIndexPath = NULL;
        [self loadTasks];
    }
}

- (void)moreAction:(UITableViewCell *)cell withButton:(UIButton *)button;{
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
            [self performSegueWithIdentifier:@"imageSegue" sender:[UIImage imageWithData:t.image]];
        }
            break;
        case 3:
        {
            self.tip = [AMPopTip popTip];
            [self.tip showText:t.memo
                     direction:AMPopTipDirectionNone
                      maxWidth:self.view.frame.size.width - 50
                        inView:self.view
                     fromFrame:self.view.frame];
            self.tip.shouldDismissOnTap = YES;
            
            self.tip.textColor = [UIColor whiteColor];
            self.tip.tintColor = [Utilities getColor];
            self.tip.popoverColor = [Utilities getColor];
            self.tip.borderColor = [UIColor whiteColor];

            self.tip.radius = 10;
        }
            break;
        default:
            break;
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"imageSegue"]){
        KPImageViewController *imageVC = (KPImageViewController *)[segue destinationViewController];
        [imageVC setImg:(UIImage *)sender];
    }
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

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
    self.isAscend = [[[Utilities getTaskSortArr] allKeys][selectedIndex] containsString:@"⇧"];
    NSLog(@"按%@排序", self.sortFactor);
    [self loadTasks];
}

@end
