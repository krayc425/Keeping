//
//  KPTodayTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTodayTableViewCell.h"

@interface KPTodayTableViewController : UITableViewController <CheckTaskDelegate>

@property (nonnull, nonatomic) IBOutlet UILabel *progressLabel;

@property (nonnull, nonatomic) NSMutableArray *unfinishedTaskArr;
@property (nonnull, nonatomic) NSMutableArray *finishedTaskArr;

@end
