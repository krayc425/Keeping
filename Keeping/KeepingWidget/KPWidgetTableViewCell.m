//
//  KPWidgetTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPWidgetTableViewCell.h"
#import "Utilities.h"

#define GROUP_ID @"group.com.krayc.keeping"

@implementation KPWidgetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[UIColor lightGrayColor] setStroke];
    
    float y = 0;
    float xLeft1 = 0.0;
    float xRight1 = self.frame.size.width;
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(xLeft1, y)];
    [path1 addLineToPoint:CGPointMake(xRight1, y)];
    [path1 stroke];
    
    [self.nameLabel setTextColor:[UIColor blackColor]];
    [self.timeLabel setTextColor:[UIColor blackColor]];
    
    self.checkBox.delegate = self;
    [self.checkBox setOnAnimationType:BEMAnimationTypeFill];
    [self.checkBox setOffAnimationType:BEMAnimationTypeFill];
    
    [self.checkBox setOnTintColor:[Utilities getColor]];
    [self.checkBox setOnCheckColor:[Utilities getColor]];
    [self.checkBox setOnFillColor:[UIColor clearColor]];
    
    [self setFont];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)animationDidStopForCheckBox:(BEMCheckBox *)checkBox{
    [self.delegate checkTask:self];
}

- (void)setFont{
    [self.nameLabel setFont:[UIFont systemFontOfSize:20.0f]];
    [self.timeLabel setFont:[UIFont systemFontOfSize:17.0f]];
}

@end
