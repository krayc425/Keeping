//
//  KPTodayTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTodayTableViewCell.h"
#import "Utilities.h"
#import "CardsView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation KPTodayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setFont];
    
    self.myCheckBox.delegate = self;
    [self.myCheckBox setOnAnimationType:BEMAnimationTypeFill];
    [self.myCheckBox setOffAnimationType:BEMAnimationTypeFill];
    
    [self.myCheckBox setOnTintColor:[Utilities getColor]];
    [self.myCheckBox setOnCheckColor:[Utilities getColor]];
    [self.myCheckBox setOnFillColor:[UIColor clearColor]];
    [self.contentView addSubview:self.myCheckBox];
    
    //自定义"更多"view
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth,
                                                                  0,
                                                                  300,
                                                                  70)];
    
    deleteView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(0, 5, 90, 55)];
    cardView.cornerRadius = 10.0;
    [deleteView addSubview:cardView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cardView.frame.size.width / 2 - 30,
                                                               cardView.frame.size.height / 2 - 25,
                                                               60,
                                                               50)];
    [label setText:@"详情"];
    [label setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [label setTextColor:[Utilities getColor]];
    [label setNumberOfLines:2];
    [label setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:label];
    
    [self.contentView addSubview:deleteView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)animationDidStopForCheckBox:(BEMCheckBox *)checkBox{
    [self.delegate checkTask:self];
}

- (void)setIsFinished:(BOOL)isFinished{
    [self.myCheckBox setOn:isFinished];
}

- (IBAction)moreAction:(id)sender{
    [self.delegate moreAction:self withButton:(UIButton *)sender];
}

- (void)setFont{
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    
    [self.appButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.linkButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.imageButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.memoButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
}

@end
