//
//  KPCalViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface KPCalViewController : UIViewController <FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonnull, nonatomic) FSCalendar *calendar;
@property (nonnull, nonatomic) UIButton *previousButton;
@property (nonnull, nonatomic) UIButton *nextButton;
@property (nonnull, nonatomic) NSCalendar *gregorian;
- (void)previousClicked:(_Nonnull id)sender;
- (void)nextClicked:(_Nonnull id)sender;

@property (nonnull, nonatomic) UITableView *taskTableView;

@property (nonnull, nonatomic) NSDate *selectedDate;
@property (nonnull, nonatomic) NSMutableArray *taskArr;

@end
