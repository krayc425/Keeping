//
//  KPTaskDisplayTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/18.
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
#import "FSCalendar.h"

@class CardsView;
@class HYCircleProgressView;
@class KPTimeView;

@interface KPTaskDisplayTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance>

@property (nonatomic) int taskid;
@property (nonnull, nonatomic) Task *task;

@property (nonnull, nonatomic) IBOutlet HYCircleProgressView *progressView;

@property (nonnull, nonatomic) IBOutlet KPWeekdayPickerView *weekdayView;
@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;

@property (nonnull, nonatomic) IBOutlet UIStackView *durationStack;
@property (nonnull, nonatomic) IBOutlet UIButton *startDateButton;
@property (nonnull, nonatomic) IBOutlet UIButton *endDateButton;

@property (nonnull, nonatomic) IBOutlet KPTimeView *reminderTimeView;
@property (nonatomic, nullable) NSDate *reminderTime;

@property (nonnull, nonatomic) IBOutlet UIStackView *imgStackView;
@property (nonnull, nonatomic) IBOutlet UIButton *appBtn;
@property (nonnull, nonatomic) IBOutlet UIButton *linkBtn;
@property (nonnull, nonatomic) IBOutlet UIButton *imageBtn;
@property (nonnull, nonatomic) IBOutlet UIButton *memoBtn;

@property (nonnull, nonatomic) FSCalendar *calendar;
@property (nonnull, nonatomic) UIButton *previousButton;
@property (nonnull, nonatomic) UIButton *nextButton;
@property (nonnull, nonatomic) NSCalendar *gregorian;
- (void)previousClicked:(_Nonnull id)sender;
- (void)nextClicked:(_Nonnull id)sender;

@property (nonnull, nonatomic) IBOutletCollection(CardsView) NSArray *cardsViews;

@end
