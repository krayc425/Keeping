//
//  KPWidgetTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPWidgetTableViewCell.h"
#import "Utilities.h"

@implementation KPWidgetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.nameLabel setTextColor:[Utilities getColor]];
    
    self.checkBox.delegate = self;
    [self.checkBox setOnAnimationType:BEMAnimationTypeFill];
    [self.checkBox setOffAnimationType:BEMAnimationTypeFill];
    
    [self.checkBox setOnTintColor:[Utilities getColor]];
    [self.checkBox setOnCheckColor:[Utilities getColor]];
    [self.checkBox setOnFillColor:[UIColor clearColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)animationDidStopForCheckBox:(BEMCheckBox *)checkBox{
    [self.delegate checkTask:self];
}

- (void)setFont{
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
}

@end
