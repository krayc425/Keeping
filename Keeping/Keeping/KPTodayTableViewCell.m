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

@implementation KPTodayTableViewCell{
    UILabel *infoLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setFont];
//    [self setIsSelected:NO];
    
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
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(cardView.frame.size.width / 2 - 30,
                                                               cardView.frame.size.height / 2 - 25,
                                                               60,
                                                               50)];
    [infoLabel setText:@"详情"];
    [infoLabel setTextColor:[Utilities getColor]];
    [infoLabel setNumberOfLines:2];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [cardView addSubview:infoLabel];
    
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

- (void)setIsSelected:(BOOL)isSelected{
    self.selected = isSelected;
    if(isSelected){
        self.cardView2 = [[CardsView alloc] initWithFrame:CGRectMake(10, 70, self.frame.size.width - 20, 45)];
        self.cardView2.cornerRadius = 10.0;
        [self addSubview:self.cardView2];
        
        self.buttonStackView = [[UIStackView alloc] initWithFrame:self.cardView2.frame];
        
        self.appButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.appButton.tag = 0;
        self.linkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.linkButton.tag = 1;
        self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.imageButton.tag = 2;
        self.memoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.memoButton.tag = 3;

        [self setButtonFont];
        
        self.buttonStackView = [self.buttonStackView initWithArrangedSubviews:@[self.appButton,self.linkButton,self.imageButton,self.memoButton]];
        for(UIButton *btn in self.buttonStackView.subviews){
            [btn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.buttonStackView.alignment = UIStackViewAlignmentCenter;
        self.buttonStackView.distribution = UIStackViewDistributionFillEqually;
        [self addSubview:self.buttonStackView];
    }else{
        [self.buttonStackView removeFromSuperview];
        [self.cardView2 removeFromSuperview];
        self.buttonStackView = nil;
        self.cardView2 = nil;
    }
}

- (void)moreAction:(id)sender{
    [self.delegate moreAction:self withButton:(UIButton *)sender];
}

- (void)setFont{
    NSNumber *fontSize = [Utilities getFontSizeArr][[[NSUserDefaults standardUserDefaults] integerForKey:@"fontSize"]];
    float f = [fontSize floatValue];
    
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    [self.reminderLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    
    [infoLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
}

- (void)setButtonFont{
    NSNumber *fontSize = [Utilities getFontSizeArr][[[NSUserDefaults standardUserDefaults] integerForKey:@"fontSize"]];
    float f = [fontSize floatValue];
    
    [self.appButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    [self.linkButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    [self.imageButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
    [self.memoButton.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:f]];
}

@end
