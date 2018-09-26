//
//  KPTabBarViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBarViewController.h"
#import "Utilities.h"
#import "KPTabBar.h"
#import "UIViewController+Extensions.h"
#import "KPNavigationTitleView.h"
#import "KPTaskDetailTableViewController.h"

@implementation KPTabBarViewController{
    KPNavigationTitleView *titleView1;
    KPNavigationTitleView *titleView2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    KPTabBar *tabBar = (KPTabBar *)self.tabBar;
    tabBar.addDelegate = self;
    
    [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
    
    [self.tabBar.items[0] setTitle:NSLocalizedString(@"Today", nil)];
    [self.tabBar.items[0] setImage:[UIImage imageNamed:@"TAB_TODAY"]];
    [self.tabBar.items[0] setSelectedImage:[UIImage imageNamed:@"TAB_TODAY_SELECTED"]];
    [self.tabBar.items[1] setTitle:NSLocalizedString(@"Task", nil)];
    [self.tabBar.items[1] setImage:[UIImage imageNamed:@"TAB_TASK"]];
    [self.tabBar.items[1] setSelectedImage:[UIImage imageNamed:@"TAB_TASK_SELECTED"]];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [Utilities getColor];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    self.kpTodayTableViewController = (KPTodayTableViewController *)self.viewControllers[0];
    self.kpTaskTableViewController = (KPTaskTableViewController *)self.viewControllers[1];
    
    titleView1 = [[KPNavigationTitleView alloc] initWithTitle:@"今日" andColor:NULL];
    titleView1.navigationTitleDelegate = self.kpTodayTableViewController;
    [titleView1 setCanTap:YES];
    
    titleView2 = [[KPNavigationTitleView alloc] initWithTitle:@"任务" andColor:NULL];
    titleView2.navigationTitleDelegate = self.kpTaskTableViewController;
    [titleView2 setCanTap:YES];
    
    self.navigationItem.titleView = titleView1;
    
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_SORT"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self.kpTodayTableViewController
                                                                action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItems = @[editItem];
    
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_SETTINGS"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(settingAction:)];
    self.navigationItem.rightBarButtonItems = @[settingItem];
    
    [self setFont];
    
    //注册通知:设置角标
    [[NSNotificationCenter defaultCenter] addObserver:self.kpTodayTableViewController
                                             selector:@selector(setBadge)
                                                 name:@"Notification_Badge"
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Notification_Badge" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_Badge" object:nil userInfo:nil];
}

- (void)setFont{
    NSDictionary *dicTab = @{
                             NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                             NSForegroundColorAttributeName: [UIColor grayColor],
                             };
    NSDictionary *dicTabSelected = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:10.0f],
                                     NSForegroundColorAttributeName: [Utilities getColor],
                                     };
    for(UITabBarItem *item in self.tabBar.items){
        [item setTitleTextAttributes:dicTab forState:UIControlStateNormal];
        [item setTitleTextAttributes:dicTabSelected forState:UIControlStateSelected];
    }
    
    KPNavigationTitleView *titleView = (KPNavigationTitleView *)self.navigationItem.titleView;
    [titleView setFont];
}

- (void)settingAction:(id)sender{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    [self performSegueWithIdentifier:@"settingSegue" sender:nil];
}

#pragma mark - UITabBarController Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    switch (self.selectedIndex) {
        case 0:
        {
            UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_SORT"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self.kpTodayTableViewController
                                                                        action:@selector(editAction:)];
            self.navigationItem.leftBarButtonItems = @[editItem];
            
            self.navigationItem.titleView = titleView1;
        }
            break;
        case 1:
        {
            [self.navigationItem setTitle:NSLocalizedString(@"Task", nil)];
            
            UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_SORT"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self.kpTaskTableViewController
                                                                        action:@selector(editAction:)];
            self.navigationItem.leftBarButtonItems = @[editItem];
            
            self.navigationItem.titleView = titleView2;
        }
            break;
        default:
            break;
    }
}

#pragma mark - KPTabBar Delegate

- (void)tabBar:(UITabBar *_Nonnull)tabBar didTappedAddButton:(UIButton *_Nonnull)addButton{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    [self performSegueWithIdentifier:@"addTaskSegue" sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"addTaskSegue"]){
        KPTaskDetailTableViewController *kptdtvc = (KPTaskDetailTableViewController *)[segue destinationViewController];
        [kptdtvc setTask:NULL];
    }
}

@end
