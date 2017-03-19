//
//  KPTabBarViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTabBar.h"
#import "KPTodayTableViewController.h"
#import "KPTaskTableViewController.h"
#import "KPSettingsTableViewController.h"

@interface KPTabBarViewController : UITabBarController <UITabBarControllerDelegate, KPTabBarDelegate>

@property (nonatomic, nonnull) KPTodayTableViewController *kpTodayTableViewController;
@property (nonatomic, nonnull) KPTaskTableViewController *kpTaskTableViewController;
@property (nonatomic, nonnull) KPSettingsTableViewController *kpSettingsTableViewController;

- (void)setFont;

@end
