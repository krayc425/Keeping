//
//  KPTaskAddTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPTaskAddTableViewController : UITableViewController

@property (nonnull, nonatomic) IBOutlet UITextField *taskNameField;
@property (nonnull, nonatomic) IBOutlet UIStackView *weekDayStack;
@property (nonnull, nonatomic) IBOutlet UIButton *allButton;

@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;

@end
