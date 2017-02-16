//
//  KPTabBarViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBarViewController.h"
#import "Utilities.h"
#import "KPTabBar+BadgeTabBar.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "KPTabBar.h"
#import "KPTaskDetailTableViewController.h"

@interface KPTabBarViewController ()

@end

@implementation KPTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
//    [self setValue:[[KPTabBar alloc] init] forKeyPath:@"tabBar"];
    KPTabBar *tabBar = (KPTabBar *)self.tabBar;
    tabBar.addDelegate = self;
    
    [self.tabBarItem setImageInsets:UIEdgeInsetsMake(10, 0, -10, 0)];
    
    [[self.tabBar.items objectAtIndex:0] setTitle:@"今日"];
    [[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"TAB_TODAY"]];
    [[self.tabBar.items objectAtIndex:1] setTitle:@"任务"];
    [[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"TAB_TASK"]];
    [[self.tabBar.items objectAtIndex:2] setTitle:@"统计"];
    [[self.tabBar.items objectAtIndex:2] setImage:[UIImage imageNamed:@"TAB_STATISTICS"]];
    [[self.tabBar.items objectAtIndex:3] setTitle:@"设置"];
    [[self.tabBar.items objectAtIndex:3] setImage:[UIImage imageNamed:@"TAB_SETTINGS"]];
    
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [Utilities getColor];
    
    self.kpTodayTableViewController = (KPTodayTableViewController *)self.viewControllers[0];
    self.kpTaskTableViewController = (KPTaskTableViewController *)self.viewControllers[1];
    self.kpCalViewController = (KPCalViewController *)self.viewControllers[2];
    self.kpSettingsTableViewController=  (KPSettingsTableViewController *)self.viewControllers[3];
    
    [self.navigationItem setTitle:@"今日"];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_EDIT"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self.kpTodayTableViewController
                                                                action:@selector(editAction:)];
    self.navigationItem.leftBarButtonItems = @[editItem];
    self.navigationItem.rightBarButtonItems = nil;
    
    [self setFont];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self.kpSettingsTableViewController
                                             selector:@selector(checkMessage:)
                                                 name:@"Notification_CheckMessage"
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_CheckMessage"
                                                        object:nil
                                                      userInfo:nil];
}

- (void)setFont{
    NSDictionary *dicTab = @{
                             NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:10.0],
                             NSForegroundColorAttributeName: [UIColor grayColor],
                             };
    NSDictionary *dicTabSelected = @{
                                     NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:10.0],
                                     NSForegroundColorAttributeName: [Utilities getColor],
                                     };
    for(UITabBarItem *item in self.tabBar.items){
        [item setTitleTextAttributes:dicTab forState:UIControlStateNormal];
        [item setTitleTextAttributes:dicTabSelected forState:UIControlStateSelected];
    }
}

#pragma mark - UITabBarController Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    switch (self.selectedIndex) {
        case 0:
        {
            [self.navigationItem setTitle:@"今日"];
            
            UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_EDIT"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self.kpTodayTableViewController
                                                                        action:@selector(editAction:)];
            self.navigationItem.leftBarButtonItems = @[editItem];
            
            self.navigationItem.rightBarButtonItems = nil;
        }
            break;
        case 1:
        {
            [self.navigationItem setTitle:@"任务"];
            
            UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_EDIT"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self.kpTaskTableViewController
                                                                        action:@selector(editAction:)];
            self.navigationItem.leftBarButtonItems = @[editItem];
            
            
//            UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//                                                                                        target:self.kpTaskTableViewController
//                                                                                        action:@selector(searchAction:)];
//            self.navigationItem.rightBarButtonItems = @[searchItem];
            self.navigationItem.rightBarButtonItems = @[];
        }
            break;
        case 2:
        {
            [self.navigationItem setTitle:@"统计"];
            
            UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_EDIT"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self.kpCalViewController
                                                                        action:@selector(editAction:)];
            self.navigationItem.leftBarButtonItems = @[editItem];
            
            self.navigationItem.rightBarButtonItems = nil;
        }
            break;
        case 3:
        {
            [self.navigationItem setTitle:@"设置"];
            
            self.navigationItem.leftBarButtonItems = nil;
            self.navigationItem.rightBarButtonItems = nil;
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
