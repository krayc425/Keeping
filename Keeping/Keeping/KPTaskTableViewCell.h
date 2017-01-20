//
//  KPTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCircleProgressView.h"

@interface KPTaskTableViewCell : UITableViewCell

//任务名
@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;
//哪几天要做
@property (nonatomic, nonnull) IBOutlet UILabel *daysLabel;
//已经添加了几天
@property (nonatomic, nonnull) IBOutlet UILabel *totalDayLabel;
//完成进度
@property (nonatomic, nonnull) IBOutlet HYCircleProgressView *progressView;

@end
