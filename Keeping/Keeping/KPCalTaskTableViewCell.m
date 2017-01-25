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
    
//    self.myCheckBox.delegate = self;
//    [self.myCheckBox setOnAnimationType:BEMAnimationTypeFill];
//    [self.myCheckBox setUserInteractionEnabled:NO];
//    [self.myCheckBox setOnFillColor:[UIColor clearColor]];
//    [self.contentView addSubview:self.myCheckBox];
//    
    [self setIsSelected:NO];
//
//    
//    
//    //先藏着
//    [self.myCheckBox setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

//- (void)setIsFinished:(BOOL)isFinished{
//    [self.myCheckBox setOn:isFinished];
//}

- (void)setIsSelected:(BOOL)isSelected{
    if(isSelected){
        [self.cardView setBackgroundColor:[Utilities getColor]];
        [self.taskNameLabel setTextColor:[UIColor whiteColor]];
        [self.punchDaysLabel setTextColor:[UIColor whiteColor]];
//        [self.myCheckBox setOnTintColor:[UIColor whiteColor]];
//        [self.myCheckBox setOnCheckColor:[UIColor whiteColor]];
    }else{
        [self.cardView setBackgroundColor:[UIColor whiteColor]];
        [self.taskNameLabel setTextColor:[UIColor blackColor]];
        [self.punchDaysLabel setTextColor:[UIColor blackColor]];
//        [self.myCheckBox setOnTintColor:[Utilities getColor]];
//        [self.myCheckBox setOnCheckColor:[Utilities getColor]];
    }
}

- (void)setFont{
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.punchDaysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
}

@end
