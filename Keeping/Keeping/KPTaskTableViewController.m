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
#import "Masonry.h"
#import "KPWeekdayPickerHeaderView.h"

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTaskTableViewController () <MGSwipeTableCellDelegate>

@end

@implementation KPTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.taskArr = [[NSMutableArray alloc] init];
    self.historyTaskArr = [[NSMutableArray alloc] init];
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    KPWeekdayPickerHeaderView *weekdayView = (KPWeekdayPickerHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"KPWeekdayPickerHeaderView" owner:nil options:nil] firstObject];
    [weekdayView setFrame:CGRectMake(10, 10, SCREEN_WIDTH - 40, 50)];
    //星期代理
    weekdayView.weekdayDelegate =  self;
    weekdayView.isAllSelected = YES;
    weekdayView.isAllButtonHidden = NO;
    weekdayView.fontSize = 17.0;

    self.selectedWeekdayArr = [@[@1,@2,@3,@4,@5,@6,@7] mutableCopy];
    weekdayView.selectedWeekdayArr = self.selectedWeekdayArr;
    [weekdayView setFont];
    
    //类别代理
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(10, 70, SCREEN_WIDTH - 40, 50)];
    cardView.cornerRadius = 10.0;
    
    [KPTaskTableViewController shareColorPickerView].colorDelegate = self;
    [[KPTaskTableViewController shareColorPickerView] setFrame:CGRectMake(10, 5, SCREEN_WIDTH - 60, 40)];
    
    [cardView addSubview:colorPickerView];
    
    self.hoverView = [[KPHoverView alloc] initWithFrame:CGRectMake(10.0, -140.0, SCREEN_WIDTH - 20, 130.0) andBaseTop:5.0];
    self.hoverView.headerScrollView = self.tableView;
    
    [self.hoverView addSubview:cardView];
    [self.hoverView addSubview:weekdayView];
    [weekdayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.hoverView.mas_top).with.offset(10);
        make.left.mas_equalTo(self.hoverView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.hoverView.mas_right).with.offset(-10);
        make.height.mas_equalTo(50);
    }];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.hoverView.mas_bottom).with.offset(-10);
        make.left.mas_equalTo(self.hoverView.mas_left).with.offset(10);
        make.right.mas_equalTo(self.hoverView.mas_right).with.offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView addObserver:self.hoverView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.view addSubview:self.hoverView];
    [self.view bringSubviewToFront:self.hoverView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self hideTip];
}

- (void)loadTasks{
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"SureToDelete", nil) message:NSLocalizedString(@"This operation cannot be reverted", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        Task *t;
        if(indexPath.section == 0){
            t = self.taskArr[indexPath.row];
            [self.taskArr removeObject:t];
        }else if(indexPath.section == 1){
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
        self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper filtrateTasks:self.taskArr withType:self.selectedColorNum]];
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
}

#pragma mark - Pop Up Image

- (void)passImg:(UIImage *)img{
    IDMPhoto *photo = [IDMPhoto photoWithImage:img];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        default:
            return 0;
        case 0:
            return [self.taskArr count];
        case 1:
            return [self.historyTaskArr count];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            if([self.taskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectZero];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:NSLocalizedString(@"In progress", nil)];
                return view;
            }
        }
            break;
        case 1:
        {
            if([self.historyTaskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectZero];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:NSLocalizedString(@"Archived", nil)];
                return view;
            }
        }
            break;
        default:
            return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        {
            if([self.taskArr count] == 0){
                return 0.00001f;
            }else{
                return 50.0f;
            }
        }
        case 1:
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Task *t;
    if(indexPath.section == 0){
        t = self.taskArr[indexPath.row];
    }else if(indexPath.section == 1){
        t = self.historyTaskArr[indexPath.row];
    }
    [self performSegueWithIdentifier:@"detailTaskSegue" sender:t];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPTaskTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPTaskTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setFont];
    cell.delegate = self;
    cell.imgDelegate = self;
    
    Task *t;
    
    if(indexPath.section == 0){
        t = self.taskArr[indexPath.row];
    }else if(indexPath.section == 1){
        t = self.historyTaskArr[indexPath.row];
    }
    
    [cell configureWithTask:t];
    
    //注册3D Touch
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
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
            Task *task = indexPath.section == 0 ? self.taskArr[indexPath.row] : self.historyTaskArr[indexPath.row];
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

#pragma mark - DZNEmptyDelegate

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.taskArr.count == 0 && self.historyTaskArr.count == 0){
        return YES;
    }else{
        return NO;
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
    if(self.hoverView.isShow){
        [self.hoverView hide];
    }else{
        [self.hoverView show];
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

#pragma mark - Header Singleton

+ (KPColorPickerView *)shareColorPickerView{
    if(colorPickerView == NULL){
        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"KPColorPickerView" owner:nil options:nil];
        colorPickerView = [nibView firstObject];
    }
    return colorPickerView;
}

@end
