//
//  KPTaskAddTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPSchemeTableViewController.h"
#import "KPReminderViewController.h"

@interface KPTaskAddTableViewController : UITableViewController <SchemeDelegate, ReminderDelegate>

@property (nonnull, nonatomic) IBOutlet UITextField *taskNameField;
@property (nonnull, nonatomic) IBOutlet UIStackView *weekDayStack;
@property (nonnull, nonatomic) IBOutlet UILabel *reminderLabel;
@property (nonnull, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (nonnull, nonatomic) IBOutlet UILabel *appNameLabel;
@property (nonnull, nonatomic) IBOutlet UIButton *allButton;

@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;
@property (nonatomic, nullable) NSDictionary *selectedApp;
@property (nonatomic, nullable) NSDate *reminderTime;

@end
