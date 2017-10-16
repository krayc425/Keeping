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
#import "KPTimeView.h"
#import "Task.h"
#import "DateTools.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation KPTodayTableViewCell{
    UILabel *infoLabel;
}

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
    self.beingSelected = isSelected;
    if(self.beingSelected){
        self.cardView2 = [[CardsView alloc] initWithFrame:CGRectMake(10, 70, self.frame.size.width - 20, 40)];
        self.cardView2.cornerRadius = 10.0;
        [self addSubview:self.cardView2];
        
        self.buttonStackView = [[UIStackView alloc] initWithFrame:self.cardView2.frame];
        
        self.appButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.linkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
        self.memoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.buttonStackView.frame.size.width / 4, self.buttonStackView.frame.size.height)];
    
        self.appButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.linkButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.imageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.memoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        self.appButton.tag = 0;
        self.linkButton.tag = 1;
        self.imageButton.tag = 2;
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
    
    [self.taskNameLabel setFont:[UIFont systemFontOfSize:f]];
    
    [infoLabel setFont:[UIFont systemFontOfSize:f]];
    
    [self.reminderTimeView setFont];
}

- (void)setButtonFont{
    NSNumber *fontSize = [Utilities getFontSizeArr][[[NSUserDefaults standardUserDefaults] integerForKey:@"fontSize"]];
    float f = [fontSize floatValue];
    
    [self.appButton.titleLabel setFont:[UIFont systemFontOfSize:f]];
    [self.linkButton.titleLabel setFont:[UIFont systemFontOfSize:f]];
    [self.imageButton.titleLabel setFont:[UIFont systemFontOfSize:f]];
    [self.memoButton.titleLabel setFont:[UIFont systemFontOfSize:f]];
}

- (void)configureWithTask:(Task *)t {
    
    [self.taskNameLabel setText:t.name];
    
    if(t.type > 0){
        [self.typeImg setHidden:NO];
        
        UIImage *img = [UIImage imageNamed:@"Round_S"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.typeImg.tintColor = [Utilities getTypeColorArr][t.type - 1];
        [self.typeImg setImage:img];
    }else{
        [self.typeImg setImage:[UIImage new]];
        [self.typeImg setHidden:YES];
    }
    
    if(t.appScheme != NULL){
        NSDictionary *d = t.appScheme;
        NSString *s = d.allKeys[0];
        [self.appButton setTitle:[NSString stringWithFormat:@"%@", s] forState:UIControlStateNormal];
        [self.appButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [self.appButton setUserInteractionEnabled:YES];
        
        UIImage *appImg = [UIImage imageNamed:@"TODAY_APP"];
        appImg = [appImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.appImg setImage:appImg];
        [self.appButton setHidden:NO];
        [self.appImg setHidden:NO];
        [self.appImg setTintColor:[Utilities getColor]];
    }else{
        [self.appButton setHidden:YES];
        [self.appImg setHidden:YES];
    }
    
    if(t.link != NULL && ![t.link isEqualToString:@""]){
        [self.linkButton setTitle:@"链接" forState:UIControlStateNormal];
        [self.linkButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [self.linkButton setUserInteractionEnabled:YES];
        
        UIImage *linkImg = [UIImage imageNamed:@"TODAY_LINK"];
        linkImg = [linkImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.linkImg setImage:linkImg];
        [self.linkButton setHidden:NO];
        [self.linkImg setHidden:NO];
        [self.linkImg setTintColor:[Utilities getColor]];
    }else{
        [self.linkButton setHidden:YES];
        [self.linkImg setHidden:YES];
    }
    
    if(t.image != NULL){
        [self.imageButton setTitle:@"图片" forState:UIControlStateNormal];
        [self.imageButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [self.imageButton setUserInteractionEnabled:YES];
        
        UIImage *imageImg = [UIImage imageNamed:@"TODAY_IMAGE"];
        imageImg = [imageImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageImg setImage:imageImg];
        [self.imageButton setHidden:NO];
        [self.imageImg setHidden:NO];
        [self.imageImg setTintColor:[Utilities getColor]];
    }else{
        [self.imageButton setHidden:YES];
        [self.imageImg setHidden:YES];
    }
    
    if(t.memo != NULL && ![t.memo isEqualToString:@""]){
        [self.memoButton setTitle:@"备注" forState:UIControlStateNormal];
        [self.memoButton setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        [self.memoButton setUserInteractionEnabled:YES];
        
        UIImage *imageImg = [UIImage imageNamed:@"TODAY_TEXT"];
        imageImg = [imageImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.memoImg setImage:imageImg];
        [self.memoButton setHidden:NO];
        [self.memoImg setHidden:NO];
        [self.memoImg setTintColor:[Utilities getColor]];
        
    }else{
        [self.memoButton setHidden:YES];
        [self.memoImg setHidden:YES];
    }
    
    if(t.reminderTime != NULL){
        [self.reminderTimeView setTime:t.reminderTime];
        [self.reminderTimeView setHidden:NO];
    }else{
        [self.reminderTimeView setHidden:YES];
    }
    
    [self.moreButton setHidden:!t.hasMoreInfo];
}

@end
