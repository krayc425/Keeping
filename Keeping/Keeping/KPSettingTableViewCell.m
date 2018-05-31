//
//  KPSettingTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/5/31.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

#import "KPSettingTableViewCell.h"
#import "Utilities.h"

@implementation KPSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *img = self.imageView.image;
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageView setImage:img];
    [self.imageView setContentMode:UIViewContentModeScaleToFill];
    [self.imageView setTintColor:[Utilities getColor]];
}

@end
