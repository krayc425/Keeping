//
//  KPTaskAddTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSDatePickerViewController.h"
#import "KPSchemeTableViewController.h"

@interface KPTaskAddTableViewController : UITableViewController <HSDatePickerViewControllerDelegate, SchemeDelegate>

@property (nonnull, nonatomic) IBOutlet UITextField *taskNameField;
@property (nonnull, nonatomic) IBOutlet UIStackView *weekDayStack;
@property (nonnull, nonatomic) IBOutlet UILabel *reminderLabel;
@property (nonnull, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (nonnull, nonatomic) IBOutlet UILabel *appNameLabel;

@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;
@property (nonatomic) NSDictionary *selectedApp;

@end
