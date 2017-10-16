//
//  KPTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYCircleProgressView.h"
#import "KPWeekdayPickerView.h"

@class Task;

@protocol PassImgDelegate <NSObject>

- (void)passImg:(UIImage *_Nullable)img;

@end

@interface KPTaskTableViewCell : UITableViewCell

@property (nonatomic, weak, nullable) id<PassImgDelegate> delegate;
//任务名
@property (nonatomic, weak, nullable) IBOutlet UILabel *nameLabel;
//改成：时间 label
@property (nonatomic, weak, nullable) IBOutlet UILabel *daysLabel;
//完成进度
@property (nonatomic, weak, nullable) IBOutlet HYCircleProgressView *progressView;
//要做的天数
@property (weak, nonatomic, nullable) IBOutlet KPWeekdayPickerView *weekdayView;
//缩略图
@property (nonatomic, weak, nullable) IBOutlet UIButton *taskImgViewBtn;
//类别
@property (nonatomic, weak, nullable) IBOutlet UIImageView *typeImg;

- (IBAction)imgAction:(_Nonnull id)sender;

- (void)setFont;

- (void)configureWithTask:(Task *_Nonnull)t;

@end
