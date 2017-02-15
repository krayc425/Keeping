//
//  KPTabBarViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTabBar.h"

@class KPTodayTableViewController;
@class KPTaskTableViewController;
@class KPCalViewController;
@class KPSettingsTableViewController;

@interface KPTabBarViewController : UITabBarController <UITabBarControllerDelegate, KPTabBarDelegate>

@property (nonatomic, nonnull) KPTodayTableViewController *kpTodayTableViewController;
@property (nonatomic, nonnull) KPTaskTableViewController *kpTaskTableViewController;
@property (nonatomic, nonnull) KPCalViewController *kpCalViewController;
@property (nonatomic, nonnull) KPSettingsTableViewController *kpSettingsTableViewController;

- (void)setFont;

@end
