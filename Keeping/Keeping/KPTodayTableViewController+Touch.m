//
//  KPTodayTableViewController+Touch.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/16.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTodayTableViewController+Touch.h"
#import "KPTaskDisplayTableViewController.h"

@implementation KPTodayTableViewController (Touch)

- (UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    if ([self.presentedViewController isKindOfClass:[KPTaskDisplayTableViewController class]]){
        return nil;
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(KPTodayTableViewCell* )[previewingContext sourceView]];
    
    Task *task;
    if(indexPath.section == 1){
        task = self.unfinishedTaskArr[indexPath.row];
    }else{
        task = self.finishedTaskArr[indexPath.row];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KPTaskDisplayTableViewController *childVC = (KPTaskDisplayTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"KPTaskDisplayTableViewController"];
    [childVC setTaskid:task.id];
    childVC.preferredContentSize = CGSizeMake(0.0f,525.0f);
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, 70);
    previewingContext.sourceRect = rect;
    
    return childVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

@end
