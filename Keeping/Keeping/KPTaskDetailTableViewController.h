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

@property (weak, nonatomic) IBOutlet UITextField *taskNameField;

@property (weak, nonatomic) IBOutlet KPWeekdayPickerView *weekdayView;
@property (copy, nonatomic) NSMutableArray *selectedWeekdayArr;

@property (weak, nonatomic) IBOutlet UIStackView *durationStack;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;

@property (weak, nonatomic) IBOutlet KPColorPickerView *colorView;    //button tag : 1 ~ 7
@property (nonatomic) int selectedColorNum;

@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (nonatomic, nullable) NSDate *reminderTime;

@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (nullable, nonatomic) KPScheme *selectedApp;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImgView;
@property (nonnull, nonatomic) UIImagePickerController* picker_library_;
@property (weak, nonatomic) IBOutlet UIStackView *imgButtonStack;
@property (weak, nonatomic) IBOutlet UIButton *addImgButton;
@property (weak, nonatomic) IBOutlet UIButton *viewImgButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteImgButton;

@property (weak, nonatomic) IBOutlet UITextField *linkTextField;

@property (weak, nonatomic) IBOutlet UITextView *memoTextView;

@end
