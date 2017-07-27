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

@class KPTimeView;

@protocol CheckTaskDelegate <NSObject>

- (void)checkTask:(UITableViewCell *_Nonnull)cell;

- (void)moreAction:(UITableViewCell *_Nonnull)cell withButton:(UIButton *_Nonnull)button;

@end

@interface KPTodayTableViewCell : UITableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, weak) id<CheckTaskDelegate> delegate;
//任务名
@property (nonatomic, weak) IBOutlet UILabel *taskNameLabel;
//提醒时间
//@property (nonatomic, nonnull) IBOutlet UILabel *reminderLabel;
@property (nonatomic, weak) IBOutlet KPTimeView *reminderTimeView;
//打钩
@property (weak, nonatomic) IBOutlet BEMCheckBox *myCheckBox;
//类别
@property (nonatomic, weak) IBOutlet UIImageView *typeImg;

//更多 按钮
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
//小图片提示
@property (weak, nonatomic) IBOutlet UIImageView * _Nullable appImg;
@property (weak, nonatomic) IBOutlet UIImageView *linkImg;
@property (weak, nonatomic) IBOutlet UIImageView *imageImg;
@property (weak, nonatomic) IBOutlet UIImageView *memoImg;
//子 cardview
@property (weak, nonatomic) IBOutlet CardsView *cardView2;
//按钮 stackview
@property (weak, nonatomic) IBOutlet UIStackView *buttonStackView;
//APP 按钮
@property (weak, nonatomic) IBOutlet UIButton *appButton;    //tag = 0
//链接 按钮
@property (weak, nonatomic) IBOutlet UIButton *linkButton;   //tag = 1
//图片 按钮
@property (weak, nonatomic) IBOutlet UIButton *imageButton;  //tag = 2
//备注 按钮
@property (weak, nonatomic) IBOutlet UIButton *memoButton;  //tag = 3

@property (nonatomic) BOOL beingSelected;

- (void)setIsSelected:(BOOL)isSelected;

- (void)setIsFinished:(BOOL)isFinished;

- (void)setFont;

@end
