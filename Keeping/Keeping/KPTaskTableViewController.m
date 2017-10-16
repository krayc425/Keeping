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
#import "SCLAlertView.h"
#import "KPTaskDisplayTableViewController.h"
#import "KPNavigationTitleView.h"
#import "AMPopTip.h"
#import "CardsView.h"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

static AMPopTip *shareTip = NULL;
static KPColorPickerView *colorPickerView = NULL;

@interface KPTaskTableViewController () <MLKMenuPopoverDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;
@property (strong, nonatomic) NSIndexPath* editingIndexPath;  //当前左滑cell的index，在代理方法中设置

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
    
    //星期代理
    self.weekDayView.weekdayDelegate = self;
    self.weekDayView.isAllSelected = YES;
    self.weekDayView.isAllButtonHidden = NO;
    self.weekDayView.fontSize = 18.0;
    
    self.weekDayView.selectedWeekdayArr = [NSMutableArray arrayWithArray: @[@1,@2,@3,@4,@5,@6,@7]];
    [self loadTasksOfWeekdays: self.weekDayView.selectedWeekdayArr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setFont];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideTip];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.editingIndexPath) {
        [self configSwipeButtons];
    }
}

- (void)setFont{
    [self.weekDayView setFont];
}

- (void)editAction:(id)senders{
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    [alert addButton:@"删除" actionBlock:^{
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
    [alert showWarning:@"确认删除吗" subTitle:@"此操作不可恢复" closeButtonTitle:@"取消" duration:0.0];
}

- (void)loadTasksOfWeekdays:(NSArray *)weekDays{
    NSDictionary *sortDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"sort"];
    self.sortFactor = sortDict.allKeys[0];
    self.isAscend = sortDict.allValues[0];
    
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
    self.taskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.taskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    self.historyTaskArr = [NSMutableArray arrayWithArray:[TaskDataHelper sortTasks:self.historyTaskArr withSortFactor:self.sortFactor isAscend:self.isAscend.intValue]];
    
    [self.tableView reloadData];
    
    [self fadeAnimation];
}

- (void)configSwipeButtons {
    // 获取选项按钮的reference
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
        // iOS 11层级 (Xcode 9编译): UITableView -> UISwipeActionPullView
        for (UIView *subview in self.tableView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subview.subviews count] >= 1) {
                // 和iOS 10的按钮顺序相反
                UIButton *moreButton = subview.subviews[0];
                
                [self configMoreButton:moreButton];
                [subview setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            }
        }
    } else {
        // iOS 8-10层级: UITableView -> UITableViewCell -> UITableViewCellDeleteConfirmationView
        KPTaskTableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
        for (UIView *subview in tableCell.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subview.subviews count] >= 1) {
                UIButton *moreButton = subview.subviews[0];
                
                [self configMoreButton:moreButton];
                [subview setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            }
        }
    }
}

- (void)configMoreButton:(UIButton *)moreButton {
    if (moreButton) {
        [moreButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        
        CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(0, 5, moreButton.frame.size.width - 5, moreButton.frame.size.height - 10)];
        cardView.cornerRadius = 10.0f;
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(cardView.frame.size.width / 2 - 30,
                                                              cardView.frame.size.height / 2 - 25,
                                                              60,
                                                              50)];
        [infoLabel setText:@"详情"];
        [infoLabel setTextColor:[Utilities getColor]];
        [infoLabel setNumberOfLines:2];
        [infoLabel setTextAlignment:NSTextAlignmentCenter];
        [cardView addSubview:infoLabel];
        
        [moreButton addSubview:cardView];
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
                return 50.0f;
            }
        }
        case 2:
        {
            if([self. historyTaskArr count] == 0){
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section != 0){
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteTaskAtIndexPath:indexPath];
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
    return @"               ";
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.editingIndexPath = indexPath;
    [self.view setNeedsLayout];   // 触发-(void)viewDidLayoutSubviews
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.editingIndexPath = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"imageSegue"]){
        KPImageViewController *imageVC = (KPImageViewController *)[segue destinationViewController];
        [imageVC setImg:(UIImage *)sender];
    }else if([segue.identifier isEqualToString:@"detailTaskSegue"]){
        Task *t = (Task *)sender;
        KPTaskDisplayTableViewController *kptdtvc = segue.destinationViewController;
        [kptdtvc setTaskid:t.id];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    if ([self.presentedViewController isKindOfClass:[KPTaskDisplayTableViewController class]]){
        return nil;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(KPTaskTableViewCell* )[previewingContext sourceView]];
    
    Task *task;
    if(indexPath.section == 1){
        task = self.taskArr[indexPath.row];
    }else if(indexPath.section == 2){
        task = self.historyTaskArr[indexPath.row];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KPTaskDisplayTableViewController *childVC = (KPTaskDisplayTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KPTaskDisplayTableViewController"];
    [childVC setTaskid:task.id];
    childVC.preferredContentSize = CGSizeMake(0.0f, 525.0f);
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 70);
    previewingContext.sourceRect = rect;
    
    return childVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
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

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    if([self.sortFactor isEqualToString:[[Utilities getTaskSortArr] allValues][selectedIndex]]){
        if(self.isAscend.intValue == true){
            self.isAscend = @(0);
        }else{
            self.isAscend = @(1);
        }
    }else{
        self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
        self.isAscend = @(1);
    }
    [[NSUserDefaults standardUserDefaults] setValue: @{self.sortFactor : self.isAscend} forKey:@"sort"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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

@end
