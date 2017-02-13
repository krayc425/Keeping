//
//  KPTaskTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskTableViewCell.h"
#import "Utilities.h"

@implementation KPTaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self setFont];
    
    [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
    [self.progressView setProgressStrokeColor:[Utilities getColor]];
    
    self.weekdayView.isAllButtonHidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)imgAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self.delegate passImg:btn.currentBackgroundImage];
}

- (void)setFont{
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.daysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    
    [self.progressView setFont];
    
    [self.weekdayView setFont];
    self.weekdayView.fontSize = 12.0;
}

@end
