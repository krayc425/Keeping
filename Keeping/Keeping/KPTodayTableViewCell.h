//
//  KPTodayTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"
#import "CardsView.h"
#import "KPBaseTableViewCell.h"

@class KPTimeView;
@class Task;

@protocol CheckTaskDelegate <NSObject>

- (void)checkTask:(UITableViewCell *_Nonnull)cell;

- (void)moreAction:(UITableViewCell *_Nonnull)cell withButton:(UIButton *_Nonnull)button;

@end

@interface KPTodayTableViewCell : KPBaseTableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, weak, nullable) id<CheckTaskDelegate> checkDelegate;
//任务名
@property (nonatomic, strong, nullable) IBOutlet UILabel *taskNameLabel;
//提醒时间
//@property (nonatomic, nonnull) IBOutlet UILabel *reminderLabel;
@property (nonatomic, nullable) IBOutlet KPTimeView *reminderTimeView;
//打钩
@property (nonatomic, nullable) IBOutlet BEMCheckBox *myCheckBox;
//类别
@property (nonatomic, nullable) IBOutlet UIImageView *typeImg;

//更多 按钮
@property (nonatomic, nullable) IBOutlet UIButton *moreButton;
//小图片提示
@property (nonatomic, nullable) IBOutlet UIImageView *appImg;
@property (nonatomic, nullable) IBOutlet UIImageView *linkImg;
@property (nonatomic, nullable) IBOutlet UIImageView *imageImg;
@property (nonatomic, nullable) IBOutlet UIImageView *memoImg;
//子 cardview
@property (nonatomic, nullable) IBOutlet CardsView *cardView2;
//按钮 stackview
@property (nonatomic, nullable) IBOutlet UIStackView *buttonStackView;
//APP 按钮
@property (nonatomic, nullable) IBOutlet UIButton *appButton;    //tag = 0
//链接 按钮
@property (nonatomic, nullable) IBOutlet UIButton *linkButton;   //tag = 1
//图片 按钮
@property (nonatomic, nullable) IBOutlet UIButton *imageButton;  //tag = 2
//备注 按钮
@property (nonatomic, nullable) IBOutlet UIButton *memoButton;  //tag = 3

@property (nonatomic) BOOL beingSelected;

- (void)setIsSelected:(BOOL)isSelected;

- (void)setIsFinished:(BOOL)isFinished;

- (void)setFont;

- (void)configureWithTask:(Task *_Nonnull)t;

@end
