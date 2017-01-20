//
//  KPTaskDetailTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/20.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "FSCalendar.h"

@interface KPTaskDetailTableViewController : UITableViewController <FSCalendarDataSource, FSCalendarDelegate>

@property (nonnull, nonatomic) Task *task;

@property (nonnull, nonatomic) IBOutlet UITextField *taskNameField;
@property (nonnull, nonatomic) IBOutlet UIStackView *weekDayStack;
@property (nonnull, nonatomic) IBOutlet UIButton *allButton;

@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;

@property (nonnull, nonatomic) IBOutlet FSCalendar *calendar;
@property (nonnull, nonatomic) UIButton *previousButton;
@property (nonnull, nonatomic) UIButton *nextButton;
@property (nonnull, nonatomic) NSCalendar *gregorian;

@end
