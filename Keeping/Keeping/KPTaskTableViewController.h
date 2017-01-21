//
//  KPTaskTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTaskTableViewCell.h"

@interface KPTaskTableViewController : UITableViewController <PassImgDelegate>

@property (nonnull, nonatomic) NSMutableArray *taskArr;

@property (nonnull, nonatomic) IBOutlet UIStackView *weekDayStack;
@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;
@property (nonnull, nonatomic) IBOutlet UIButton *allButton;

- (void)addAction:(_Nonnull id)senders;
- (void)editAction:(_Nonnull id)senders;

@end
