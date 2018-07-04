//
//  KPTaskTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTaskTableViewCell.h"
#import "KPWeekdayPickerView.h"
#import "KPColorPickerView.h"
#import "KPWeekdayPickerView.h"
#import "KPNavigationTitleView.h"
#import "KPBaseTableViewController.h"

@interface KPTaskTableViewController : KPBaseTableViewController <PassImgDelegate, KPWeekdayPickerDelegate, KPColorPickerDelegate, KPNavigationTitleDelegate>

@property (nonatomic, nonnull) NSMutableArray *taskArr;
@property (nonatomic, nonnull) NSMutableArray *historyTaskArr;

@property (nonatomic) int selectedColorNum;

@property (nonatomic, nonnull) NSMutableArray *selectedWeekdayArr;
@property (nonatomic, nonnull) IBOutlet KPWeekdayPickerView *weekDayView;

@end
