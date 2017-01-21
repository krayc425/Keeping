//
//  KPTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCircleProgressView.h"

@protocol PassImgDelegate <NSObject>

- (void)passImg:(UIImage *)img;

@end

@interface KPTaskTableViewCell : UITableViewCell

@property (nonatomic, nonnull) id<PassImgDelegate> delegate;
//任务名
@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;
//哪几天要做
@property (nonatomic, nonnull) IBOutlet UILabel *daysLabel;
//已经添加了几天
@property (nonatomic, nonnull) IBOutlet UILabel *totalDayLabel;
//完成进度
@property (nonatomic, nonnull) IBOutlet HYCircleProgressView *progressView;
//缩略图
@property (nonatomic, nonnull) IBOutlet UIButton *taskImgViewBtn;

- (IBAction)imgAction:(id)sender;

@end
