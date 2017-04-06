//
//  KPFontTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/23.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPFontTableViewCell.h"

@implementation KPFontTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
//    [[UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0] setFill];
//    [[UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0] setStroke];
//    
//    float y = self.frame.size.height;
//    float xLeft1 = 18.0;
//    float xRight1 = self.frame.size.width;
//    
//    UIBezierPath *path1 = [UIBezierPath bezierPath];
//    [path1 moveToPoint:CGPointMake(xLeft1, y)];
//    [path1 addLineToPoint:CGPointMake(xRight1, y)];
//    [path1 stroke];
//    [path1 setLineWidth:0.5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
