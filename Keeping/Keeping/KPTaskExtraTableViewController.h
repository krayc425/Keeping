//
//  KPTaskExtraTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/21.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPSchemeTableViewController.h"
#import "KPReminderViewController.h"
#import "Task.h"

@interface KPTaskExtraTableViewController : UITableViewController <SchemeDelegate, ReminderDelegate>

@property (nonnull, nonatomic) IBOutlet UILabel *reminderLabel;
@property (nonnull, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (nonnull, nonatomic) IBOutlet UILabel *appNameLabel;

@property (nonatomic, nullable) NSDictionary *selectedApp;
@property (nonatomic, nullable) NSDate *reminderTime;

@property (nonnull, nonatomic) Task *task;

@end
