//
//  KPBaseTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/7/4.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "KPBaseTableViewController.h"
#import "Utilities.h"
#import "UIViewController+Extensions.h"

@implementation KPBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadTasks];
}

- (void)changeRotate:(NSNotification *)noti {
    [self.hoverView layoutSubviews];
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
            [weakSelf loadTasks];
        }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    
    if (alert.popoverPresentationController != NULL) {
        alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectZero;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadTasks{
    
}

#pragma mark - Fade Animation

- (void)fadeAnimation{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]){
        CATransition *animation = [CATransition animation];
        animation.duration = 0.3f;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        animation.type = [Utilities getAnimationType];
        [self.tableView.layer addAnimation:animation forKey:@"fadeAnimation"];
    }
}

#pragma mark - DZNEmptyTableViewDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = NSLocalizedString(@"没有任务", @"") ;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont systemFontOfSize:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

#pragma mark - UITableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

@end
