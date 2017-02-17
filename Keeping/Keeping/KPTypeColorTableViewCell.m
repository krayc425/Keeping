//
//  KPTypeColorTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTypeColorTableViewCell.h"
#import "Utilities.h"

@implementation KPTypeColorTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.colorText setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    
    self.colorText.placeholder = @"点击添加备注";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
