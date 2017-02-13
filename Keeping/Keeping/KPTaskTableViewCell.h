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

@protocol PassImgDelegate <NSObject>

- (void)passImg:(UIImage *_Nullable)img;

@end

@interface KPTaskTableViewCell : UITableViewCell

@property (nonatomic, nonnull) id<PassImgDelegate> delegate;
//任务名
@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;
//改成：时间 label
@property (nonatomic, nonnull) IBOutlet UILabel *daysLabel;
//完成进度
@property (nonatomic, nonnull) IBOutlet HYCircleProgressView *progressView;
//要做的天数
@property (nonnull, nonatomic) IBOutlet KPWeekdayPickerView *weekdayView;
//缩略图
@property (nonatomic, nonnull) IBOutlet UIButton *taskImgViewBtn;
//类别
@property (nonatomic, nonnull) IBOutlet UIImageView *typeImg;

- (IBAction)imgAction:(_Nonnull id)sender;

- (void)setFont;

@end
