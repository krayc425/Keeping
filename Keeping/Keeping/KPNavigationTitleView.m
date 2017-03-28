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
    UIColor *color;
}

- (instancetype)init{
    self = [super init];
    if(self){
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 64)];
        [titleLabel setText:title];
        [titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:22.0]];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel sizeToFit];
        
        UIImageView *typeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        UIImage *img = [UIImage imageNamed:@"Round_S"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if(color == NULL){
            [typeView setImage:[UIImage new]];
            [typeView setHidden:YES];
        }else{
            typeView.tintColor = color;
            [typeView setImage:img];
            [typeView setHidden:NO];
        }
        
        self.frame = CGRectMake(0, 0, CGRectGetWidth(typeView.frame) + CGRectGetWidth(titleLabel.frame) + 5, 64);
        
        UIStackView *stackView = [[UIStackView alloc] initWithFrame:self.frame];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionEqualCentering;
        stackView.alignment = UIStackViewAlignmentCenter;
        stackView.spacing = 0;
        [stackView addArrangedSubview:titleLabel];
        [stackView addArrangedSubview:typeView];
        stackView.userInteractionEnabled = YES;
        
        [self addSubview:stackView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tapGesture.numberOfTapsRequired = 1;
        [stackView addGestureRecognizer:tapGesture];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)thisTitle andColor:(UIColor *)thisColor{
    title = thisTitle;
    color = thisColor;
    return [self init];
}

- (void)tapAction:(id)sender{
    NSLog(@"tap");
}

@end
