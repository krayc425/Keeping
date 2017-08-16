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

@property (nonatomic, strong) id<CheckTaskDelegate> delegate;
//任务名
@property (nonatomic, strong) IBOutlet UILabel *taskNameLabel;
//提醒时间
//@property (nonatomic, nonnull) IBOutlet UILabel *reminderLabel;
@property (nonatomic, strong) IBOutlet KPTimeView *reminderTimeView;
//打钩
@property (strong, nonatomic) IBOutlet BEMCheckBox *myCheckBox;
//类别
@property (nonatomic, strong) IBOutlet UIImageView *typeImg;

//更多 按钮
@property (strong, nonatomic) IBOutlet UIButton *moreButton;
//小图片提示
@property (strong, nonatomic) IBOutlet UIImageView * _Nullable appImg;
@property (strong, nonatomic) IBOutlet UIImageView *linkImg;
@property (strong, nonatomic) IBOutlet UIImageView *imageImg;
@property (strong, nonatomic) IBOutlet UIImageView *memoImg;
//子 cardview
@property (strong, nonatomic) IBOutlet CardsView *cardView2;
//按钮 stackview
@property (strong, nonatomic) IBOutlet UIStackView *buttonStackView;
//APP 按钮
@property (strong, nonatomic) IBOutlet UIButton *appButton;    //tag = 0
//链接 按钮
@property (strong, nonatomic) IBOutlet UIButton *linkButton;   //tag = 1
//图片 按钮
@property (strong, nonatomic) IBOutlet UIButton *imageButton;  //tag = 2
//备注 按钮
@property (strong, nonatomic) IBOutlet UIButton *memoButton;  //tag = 3

@property (nonatomic) BOOL beingSelected;

- (void)setIsSelected:(BOOL)isSelected;

- (void)setIsFinished:(BOOL)isFinished;

- (void)setFont;

@end
