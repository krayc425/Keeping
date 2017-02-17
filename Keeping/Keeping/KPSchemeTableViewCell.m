//
//  KPSchemeTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeTableViewCell.h"
#import "Utilities.h"

@implementation KPSchemeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.appNameLabel setFont:[UIFont fontWithName:[Utilities getFont] size:20.0f]];
    
    [self.appIconImg.layer setCornerRadius:8.0];
    [self.appIconImg.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
