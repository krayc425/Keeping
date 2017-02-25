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
    
    [self setIsSelected:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsSelected:(BOOL)isSelected{
    if(isSelected){
        [self.cardView setBackgroundColor:[Utilities getColor]];
        [self.taskNameLabel setTextColor:[UIColor whiteColor]];
        [self.punchDaysLabel setTextColor:[UIColor whiteColor]];
        
        [self.progressView setBackgroundStrokeColor:[Utilities getColor]];
        [self.progressView setProgressStrokeColor:[UIColor whiteColor]];
        [self.progressView setDigitTintColor:[UIColor whiteColor]];

    }else{
        [self.cardView setBackgroundColor:[UIColor whiteColor]];
        [self.taskNameLabel setTextColor:[UIColor blackColor]];
        
        [self.punchDaysLabel setTextColor:[UIColor grayColor]];
        
        [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
        [self.progressView setProgressStrokeColor:[Utilities getColor]];
        [self.progressView setDigitTintColor:[UIColor blackColor]];

    }
}

- (void)setFont{
    [self.taskNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.punchDaysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    [self.progressView setFont];
}

@end
