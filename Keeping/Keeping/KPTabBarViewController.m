//
//  KPTabBarViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBarViewController.h"
#import "Utilities.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "KPTabBar.h"
#import "KPNavigationTitleView.h"
#import "KPTaskDetailTableViewController.h"

@interface KPTabBarViewController ()

@end

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
    
    [[self.tabBar.items objectAtIndex:0] setTitle:@"今日"];
    [[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"TAB_TODAY"]];
    [[self.tabBar.items objectAtIndex:1] setTitle:@"任务"];
    [[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"TAB_TASK"]];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [Utilities getColor];
    
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
    
    //注册通知:检查反馈新消息
    [[NSNotificationCenter defaultCenter] addObserver:self.kpSettingsTableViewController
                                             selector:@selector(checkMessage:)
                                                 name:@"Notification_CheckMessage"
                                               object:nil];
    
    //注册通知:设置角标
    [[NSNotificationCenter defaultCenter] addObserver:self.kpTodayTableViewController
                                             selector:@selector(setBadge)
                                                 name:@"Notification_Badge"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_CheckMessage"
                                                        object:nil
                                                      userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_Badge"
                                                        object:nil
                                                      userInfo:nil];
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
    [self performSegueWithIdentifier:@"settingSegue" sender:nil];
}

#pragma mark - UITabBarController Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
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
            [self.navigationItem setTitle:@"任务"];
            
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
