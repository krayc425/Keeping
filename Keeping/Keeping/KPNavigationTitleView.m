//
//  KPNavigationTitleView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPNavigationTitleView.h"
#import "Utilities.h"

@implementation KPNavigationTitleView{
    NSString *title;
    UIColor *color ;
    CGRect *myFrame;
    UILabel *titleLabel;
    UIImageView *typeView;
    UIStackView *stackView;
    BOOL canTap;
}

- (instancetype)init{
    self = [super init];
    if(self){
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        [titleLabel setText:title];
        [self setFont];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel sizeToFit];
        
        typeView = [[UIImageView alloc] init];
        [typeView setFrame:CGRectMake(0, 0, 10, 10)];
        typeView.layer.masksToBounds = YES;
        typeView.contentMode = UIViewContentModeScaleAspectFit;
        
        stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFill;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.spacing = 5;
        [stackView addArrangedSubview:titleLabel];
        [stackView addArrangedSubview:typeView];
        
        [self addSubview:stackView];
        
        [self setMyFrame];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)thisTitle andColor:(UIColor *)thisColor{
    title = thisTitle;
    color = thisColor;
    return [self init];
}

- (void)changeColor:(UIColor *)thisColor{
    color = thisColor;
    [self setMyFrame];
}

- (void)setCanTap:(BOOL)thisCanTap{
    canTap = thisCanTap;
    
    [stackView setUserInteractionEnabled:thisCanTap];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [stackView addGestureRecognizer:tapGesture];
    
    [self setMyFrame];
}

- (void)tapAction:(id)sender{
    [self.navigationTitleDelegate navigationTitleViewTapped];
}

- (void)setMyFrame{
    if(color == NULL){
        
        if(canTap){
            UIImage *img = [UIImage imageNamed:@"NAV_DONE_CANCEL"];
            [typeView setImage:img];
            [typeView setHidden:NO];
            [stackView setFrame:CGRectMake(0,
                                           0,
                                           CGRectGetWidth(titleLabel.frame) + 15,
                                           44)];
        }else{
            [typeView setImage:[UIImage new]];
            [typeView setHidden:YES];
            [stackView setFrame:CGRectMake(0,
                                           0,
                                           CGRectGetWidth(titleLabel.frame),
                                           44)];
        }
        
    }else{
        UIImage *img = [UIImage imageNamed:@"Round_S"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        typeView.tintColor = color;
        [typeView setImage:img];
        [typeView setHidden:NO];
        [stackView setFrame:CGRectMake(0,
                                       0,
                                       CGRectGetWidth(titleLabel.frame) + 15,
                                       44)];
    }
    
    [self setFrame:CGRectMake(CGRectGetWidth(self.superview.frame) / 2 - CGRectGetWidth(stackView.frame) / 2,
                              0,
                              CGRectGetWidth(stackView.frame),
                              CGRectGetHeight(stackView.frame))];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setFont{
    [titleLabel setFont:[UIFont systemFontOfSize:18.0f weight:UIFontWeightBold]];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
