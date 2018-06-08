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
#import "TaskDataHelper.h"
#import "KPTaskDisplayTableViewController.h"
#import "KPNavigationTitleView.h"
#import "AMPopTip.h"
#import "CardsView.h"
#import "KPTaskTableViewController+Touch.h"
#import "IDMPhotoBrowser.h"
#import "MGSwipeTableCell.h"
#import "UIViewController+Extensions.h"

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTaskTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MGSwipeTableCellDelegate>

@end

@implementation KPTaskTableViewController{
    BOOL firstLoad;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstLoad = YES;
    
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    self.tableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    //类别代理
    [KPTaskTableViewController shareColorPickerView].colorDelegate = self;
    [[KPTaskTableViewController shareColorPickerView] setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 32, 40)];

    //星期代理
    self.weekDayView.weekdayDelegate = self;
    self.weekDayView.isAllSelected = YES;
    self.weekDayView.isAllButtonHidden = NO;
    self.weekDayView.fontSize = 18.0;
    
    self.selectedWeekdayArr = [@[@1,@2,@3,@4,@5,@6,@7] mutableCopy];
    
    self.weekDayView.selectedWeekdayArr = self.selectedWeekdayArr;
    
    [self setFont];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideTip];
}

- (void)setFont{
    [self.weekDayView setFont];
}

- (void)editAction:(id)sender{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择任务排序方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSDictionary *dict = [Utilities getTaskSortArr];
    
    __weak typeof(self) weakSelf = self;
    
    for (NSString *key in dict.allKeys) {
        
        NSMutableString *displayKey = key.mutableCopy;
        if([self.sortFactor isEqualToString:dict[displayKey]]){
            if(self.isAscend.intValue == true){
                [displayKey appendString:@" ↑"];
            }else{
                [displayKey appendString:@" ↓"];
            }
        }
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:displayKey style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if([weakSelf.sortFactor isEqualToString:dict[key]]){
                if(weakSelf.isAscend.intValue == true){
                    weakSelf.isAscend = @(0);
                }else{
                    weakSelf.isAscend = @(1);
                }
            }else{
                weakSelf.sortFactor = dict[key];
                weakSelf.isAscend = @(1);
            }
            [[NSUserDefaults standardUserDefaults] setValue: @{weakSelf.sortFactor : weakSelf.isAscend} forKey:@"sort"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [weakSelf loadTasksOfWeekdays:weakSelf.selectedWeekdayArr];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除吗" message:@"此操作不可恢复" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        Task *t;
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
            [self.taskArr removeObject:t];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
            [self.historyTaskArr removeObject:t];
        }
        
        [[TaskManager shareInstance] deleteTask:t];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(self.taskArr.count == 0 || self.historyTaskArr.count == 0){
            [self.tableView reloadData];
        }
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadTasksOfWeekdays:(NSArray *)weekDays{
    NSDictionary *sortDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"sort"];
    self.sortFactor = sortDict.allKeys[0];
    self.isAscend = sortDict.allValues[0];
    
    //按星期
    self.taskArr = [[TaskManager shareInstance] getTasksOfWeekdays:weekDays];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    //按类别
    if (self.selectedColorNum > 0) {
        self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.taskArr
                                                                           withType:self.selectedColorNum]];
    }
    
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
    self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.taskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    self.historyTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.historyTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    
    [self.tableView reloadData];
    
    [self fadeAnimation];
    
    if(firstLoad){
        firstLoad = NO;
    }
}

#pragma mark - Pop Up Image

- (void)passImg:(UIImage *)img{
    IDMPhoto *photo = [IDMPhoto photoWithImage:img];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
    [self presentViewController:browser animated:YES completion:nil];
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
                return 50.0f;
            }
        }
        case 2:
        {
            if([self.historyTaskArr count] == 0){
                return 0.00001f;
            }else{
                return 50.0f;
            }
        }
        default:
            return 0.00001f;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section != 0){
        Task *t;
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
        }
        [self performSegueWithIdentifier:@"detailTaskSegue" sender:t];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 70;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return NO;
    }
    return YES;
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
        cell.delegate = self;
        cell.imgDelegate = self;
        
        Task *t;
        
        if(indexPath.section == 1){
            t = self.taskArr[indexPath.row];
        }else if(indexPath.section == 2){
            t = self.historyTaskArr[indexPath.row];
        }
        
        [cell configureWithTask:t];
        
        //注册3D Touch
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
        
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section == 0
//       || ![[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]
//       || !firstLoad){
//        return;
//    }
//    
//    NSInteger order = indexPath.row + (indexPath.section == 2 ? self.taskArr.count : 0);
//    CGFloat time = order * 0.1;
//    
//    cell.transform = CGAffineTransformMakeTranslation(-SCREEN_WIDTH, 0);
//    [UIView animateWithDuration:0.4
//                          delay:time
//         usingSpringWithDamping:0.7
//          initialSpringVelocity:1 / 0.7
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         cell.transform = CGAffineTransformIdentity;
//                     } completion:^(BOOL finished) {
//                         
//                     }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"detailTaskSegue"]){
        Task *t = (Task *)sender;
        KPTaskDisplayTableViewController *kptdtvc = segue.destinationViewController;
        [kptdtvc setTaskid:t.id];
    }
}

#pragma mark - MGSwipeCellDelegate

- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (direction) {
        case MGSwipeDirectionLeftToRight:
        {
            Task *task = indexPath.section == 1 ? self.taskArr[indexPath.row] : self.historyTaskArr[indexPath.row];
            [self performSegueWithIdentifier:@"detailTaskSegue" sender:task];
        }
            break;
        case MGSwipeDirectionRightToLeft:
            [self deleteTaskAtIndexPath:indexPath];
            break;
        default:
            break;
    }
    return YES;
}

#pragma mark - DZN Empty Delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"没有任务";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.taskArr.count == 0 && self.historyTaskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
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
    [colorPickerView setSelectedColorNum:self.selectedColorNum];
    
    KPNavigationTitleView *titleView = (KPNavigationTitleView *)self.tabBarController.navigationItem.titleView;
    
    if(self.selectedColorNum > 0){
        [titleView changeColor:[Utilities getTypeColorArr][self.selectedColorNum - 1]];
    }else{
        [titleView changeColor:NULL];
    }
    
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

#pragma mark - KPNavigationTitleDelegate

- (void)navigationTitleViewTapped{
    AMPopTip *tp = [KPTaskTableViewController shareTipInstance];

    if(![tp isVisible] && ![tp isAnimating]){
        [tp showCustomView:colorPickerView
                 direction:AMPopTipDirectionDown
                    inView:self.view
                 fromFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2, -44, 0, 44)];

        tp.textColor = [UIColor whiteColor];
        tp.tintColor = [Utilities getColor];
        tp.popoverColor = [Utilities getColor];
        tp.borderColor = [UIColor whiteColor];

        tp.radius = 10;

        [tp setDismissHandler:^{
            shareTip = NULL;
        }];
    }else{
        [tp hide];
    }
}

#pragma mark - AMPopTip Singleton

+ (AMPopTip *)shareTipInstance{
    return shareTip == NULL ? shareTip = [AMPopTip popTip] : shareTip;
}

- (void)hideTip{
    if([[KPTaskTableViewController shareTipInstance] isAnimating]
       || [[KPTaskTableViewController shareTipInstance] isVisible]){
        [[KPTaskTableViewController shareTipInstance] hide];
        shareTip = NULL;
    }
}

#pragma mark - KPColor Singleton

+ (KPColorPickerView *)shareColorPickerView{
    if(colorPickerView == NULL){
        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"KPColorPickerView" owner:nil options:nil];
        colorPickerView = [nibView firstObject];
    }
    return colorPickerView;
}

@end
