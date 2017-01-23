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

@property (nonatomic, assign) UIView *background;   //图片放大的背景

@end

@implementation KPTodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
            
            if(t.appScheme != NULL){
                NSDictionary *d = t.appScheme;
                NSString *s = d.allKeys[0];
                [cell.appButton setTitle:[NSString stringWithFormat:@"启动%@", s] forState:UIControlStateNormal];
                [cell.appButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                
                [cell.appButton setUserInteractionEnabled:YES];
            }else{
                [cell.appButton setTitle:@"没有 APP" forState:UIControlStateNormal];
                [cell.appButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
                [cell.appButton setUserInteractionEnabled:NO];
            }
            
            if(t.link != NULL && ![t.link isEqualToString:@""]){
                [cell.linkButton setTitle:@"打开链接" forState:UIControlStateNormal];
                [cell.linkButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.linkButton setUserInteractionEnabled:YES];
            }else{
                [cell.linkButton setTitle:@"没有链接" forState:UIControlStateNormal];
                [cell.linkButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [cell.linkButton setUserInteractionEnabled:NO];
            }
            
            if(t.image != NULL){
                [cell.imageButton setTitle:@"查看图片" forState:UIControlStateNormal];
                [cell.imageButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
                [cell.imageButton setUserInteractionEnabled:YES];
            }else{
                [cell.imageButton setTitle:@"没有图片" forState:UIControlStateNormal];
                [cell.imageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [cell.imageButton setUserInteractionEnabled:YES];
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
        if(self.selectedIndexPath == indexPath){
            self.selectedIndexPath = NULL;
        }else{
            self.selectedIndexPath = indexPath;
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
        [[TaskManager shareInstance] punchForTaskWithID:@(task.id)];
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
    switch (button.tag) {
        case 0:
        {
            NSString *s = t.appScheme.allValues[0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:s]];
        }
            break;
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:t.link]];
        }
            break;
        case 2:
        {
            [self passImg:[UIImage imageWithData:t.image]];
        }
            break;
        default:
            break;
    }

}

#pragma mark - Pop Up Image

- (void)passImg:(UIImage *)img{
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64)];
    self.background = bgView;
    [bgView setBackgroundColor:[UIColor colorWithRed:0/250.0 green:0/250.0 blue:0/250.0 alpha:1.0]];
    
    UIImageView *browseImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64)];
    browseImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    browseImgView.image = img;
    [bgView addSubview:browseImgView];
    
    browseImgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    [browseImgView addGestureRecognizer:tapGesture];
    
    [self.tableView addSubview:bgView];
}

- (void)closeView{
    [self.background removeFromSuperview];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:NO];
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
