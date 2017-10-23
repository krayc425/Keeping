//
//  TodayViewController.h
//  KeepingWidget
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "KPWidgetTableViewCell.h"

@interface TodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, WidgetTaskDelegate>

@property (nonatomic, nonnull) FMDatabase *db;

@property (nonatomic, nonnull) NSMutableArray *taskArr;

@property (nonatomic, nonnull) IBOutlet UILabel *countLabel;
@property (nonatomic, nonnull) IBOutlet UITableView *taskTableView;

@end
