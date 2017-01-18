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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
