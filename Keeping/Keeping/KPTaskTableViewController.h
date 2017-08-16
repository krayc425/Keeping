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

@interface KPTaskTableViewController : UITableViewController <PassImgDelegate, KPWeekdayPickerDelegate, KPColorPickerDelegate, UIViewControllerPreviewingDelegate, KPNavigationTitleDelegate>

@property (copy, nonatomic) NSMutableArray *taskArr;
@property (copy, nonatomic) NSMutableArray *historyTaskArr;

@property (nonatomic) int selectedColorNum;

@property (nonatomic) NSMutableArray *selectedWeekdayArr;
@property (weak, nonatomic) IBOutlet KPWeekdayPickerView *weekDayView;

@property (copy, nonatomic) NSString *sortFactor;
@property (nonnull, nonatomic) NSNumber *isAscend;

- (void)searchAction:(_Nonnull id)senders;
- (void)editAction:(_Nonnull id)senders;

@end
