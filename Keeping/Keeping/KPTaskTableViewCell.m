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
    
    [self.nameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    [self.daysLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0f]];
    [self.totalDayLabel setFont:[UIFont fontWithName:[Utilities getFont] size:12.0f]];
    
    [self.totalDayLabel setHidden:YES];
    
    [self.progressView setBackgroundStrokeColor:[UIColor groupTableViewBackgroundColor]];
    [self.progressView setProgressStrokeColor:[Utilities getColor]];
    
    for(UIButton *button in self.weekDayStack.subviews){
        [button setTintColor:[Utilities getColor]];
        [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:12.0f]];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)imgAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    [self.delegate passImg:btn.currentBackgroundImage];
}

@end
