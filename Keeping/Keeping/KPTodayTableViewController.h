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

@interface KPTodayTableViewController : UITableViewController <CheckTaskDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, KPColorPickerDelegate, UIViewControllerPreviewingDelegate>

@property (nonnull, nonatomic) IBOutlet UIButton *dateButton;
@property (nonnull, nonatomic) IBOutlet UILabel *progressLabel;

@property (nonnull, nonatomic) NSMutableArray *unfinishedTaskArr;
@property (nonnull, nonatomic) NSMutableArray *finishedTaskArr;

@property (nonnull, nonatomic) NSDate *selectedDate;

@property (nullable, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonnull, nonatomic) NSString *sortFactor;
@property (nonnull, nonatomic) NSNumber *isAscend;

@property (nonatomic, nonnull) IBOutlet UIStackView *pageStack;

@property (nonatomic, nonnull) IBOutlet UIStackView *dateStack;
@property (nonatomic, nonnull) IBOutlet KPColorPickerView *colorView;  //button tag : 1 ~ 7
@property (nonatomic) int selectedColorNum;

- (void)editAction:(_Nonnull id)sender;

- (void)setBadge;

@property (nonnull, nonatomic) FSCalendar *calendar;
@property (nonnull, nonatomic) UIButton *previousButton;
@property (nonnull, nonatomic) UIButton *nextButton;
@property (nonnull, nonatomic) NSCalendar *gregorian;

@end
