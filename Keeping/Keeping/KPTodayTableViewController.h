//
//  KPTodayTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"
#import "KPTodayTableViewCell.h"
#import "KPColorPickerView.h"
#import "KPNavigationTitleView.h"
#import "KPBaseTableViewController.h"

@class KPProgressLabel;

@interface KPTodayTableViewController : KPBaseTableViewController <CheckTaskDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, KPColorPickerDelegate, KPNavigationTitleDelegate>

@property (weak, nonatomic, nullable) IBOutlet UILabel *subDateLabel;
@property (weak, nonatomic, nullable) IBOutlet UIButton *dateButton;
@property (weak, nonatomic, nullable) IBOutlet KPProgressLabel *progressLabel;

@property (nonatomic, nonnull) NSMutableArray *unfinishedTaskArr;
@property (nonatomic, nonnull) NSMutableArray *finishedTaskArr;

@property (nonnull, nonatomic) NSDate *selectedDate;

@property (nullable, nonatomic) NSIndexPath *selectedIndexPath;;

@property (nonatomic) int selectedColorNum;

- (void)setBadge;

@property (nonnull, nonatomic) FSCalendar *calendar;
@property (nonnull, nonatomic) UIButton *previousButton;
@property (nonnull, nonatomic) UIButton *nextButton;
@property (nonnull, nonatomic) NSCalendar *gregorian;

@end
