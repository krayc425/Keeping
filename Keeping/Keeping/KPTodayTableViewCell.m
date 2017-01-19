//
//  KPTodayTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTodayTableViewCell.h"
#import "Utilities.h"

@implementation KPTodayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.accessoryLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    
    self.myCheckBox.delegate = self;
    [self.myCheckBox setOnAnimationType:BEMAnimationTypeFill];
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
    [self.myCheckBox setUserInteractionEnabled:!isFinished];
}

@end
