//
//  KPTaskDetailTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/20.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "KPSchemeTableViewController.h"
#import "KPReminderViewController.h"
#import "HSDatePickerViewController.h"
#import "KPWeekdayPickerView.h"
#import "KPColorPickerView.h"
#import "KPScheme.h"

@interface KPTaskDetailTableViewController : UITableViewController <SchemeDelegate, ReminderDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, HSDatePickerViewControllerDelegate, UITextViewDelegate, KPWeekdayPickerDelegate, KPColorPickerDelegate>

@property (nullable, nonatomic) Task *task;

@property (weak, nonatomic, nullable) IBOutlet UITextField *taskNameField;

@property (weak, nonatomic, nullable) IBOutlet KPWeekdayPickerView *weekdayView;
@property (copy, nonatomic, nonnull) NSMutableArray *selectedWeekdayArr;

@property (weak, nonatomic, nullable) IBOutlet UIStackView *durationStack;
@property (weak, nonatomic, nullable) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *endDateButton;

@property (weak, nonatomic, nullable) IBOutlet KPColorPickerView *colorView;    //button tag : 1 ~ 7
@property (nonatomic) int selectedColorNum;

@property (weak, nonatomic, nullable) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic, nullable) IBOutlet UISwitch *reminderSwitch;
@property (nonatomic, nullable) NSDate *reminderTime;

@property (weak, nonatomic, nullable) IBOutlet UILabel *appNameLabel;
@property (nullable, nonatomic) KPScheme *selectedApp;

@property (weak, nonatomic, nullable) IBOutlet UIImageView *selectedImgView;
@property (nonnull, nonatomic) UIImagePickerController* picker_library_;
@property (weak, nonatomic, nullable) IBOutlet UIStackView *imgButtonStack;
@property (weak, nonatomic, nullable) IBOutlet UIButton *addImgButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *viewImgButton;
@property (weak, nonatomic, nullable) IBOutlet UIButton *deleteImgButton;

@property (weak, nonatomic, nullable) IBOutlet UITextField *linkTextField;

@property (weak, nonatomic, nullable) IBOutlet UITextView *memoTextView;

@end
