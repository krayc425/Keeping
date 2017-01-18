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
    [self.accessoryLabel setFont:[UIFont fontWithName:[Utilities getFont] size:12.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
