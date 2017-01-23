//
//  KPCalTaskTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPCalTaskTableViewCell.h"
#import "Utilities.h"

@implementation KPCalTaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setFont];
    
    self.myCheckBox.delegate = self;
    [self.myCheckBox setOnAnimationType:BEMAnimationTypeFill];
    [self.myCheckBox setOnTintColor:[Utilities getColor]];
    [self.myCheckBox setOnCheckColor:[Utilities getColor]];
    [self.myCheckBox setOnFillColor:[UIColor clearColor]];
    [self.myCheckBox setUserInteractionEnabled:NO];
    [self.contentView addSubview:self.myCheckBox];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsFinished:(BOOL)isFinished{
    [self.myCheckBox setOn:isFinished];
}

- (void)setFont{
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.punchDaysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
}

@end
