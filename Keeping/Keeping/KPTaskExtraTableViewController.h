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

@interface KPTaskExtraTableViewController : UITableViewController <SchemeDelegate, ReminderDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonnull, nonatomic) IBOutlet UILabel *reminderLabel;
@property (nonnull, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (nonatomic, nullable) NSDate *reminderTime;

@property (nonnull, nonatomic) IBOutlet UILabel *appNameLabel;
@property (nonatomic, nullable) NSDictionary *selectedApp;

@property (nonnull, nonatomic) IBOutlet UIImageView *selectedImgView;
@property (nonnull, nonatomic) UIImagePickerController* picker_library_;

@property (nonnull, nonatomic) Task *task;

@end
