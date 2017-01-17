//
//  KPSeparatorView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSeparatorView.h"
#import "Utilities.h"

@implementation KPSeparatorView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self.textLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0]];
    
    [[UIColor lightGrayColor] setFill];
    
    float y = self.frame.size.height / 2;
    float xLeft1 = 10.0;
    float xLeft2 = self.frame.size.width / 2 - self.textLabel.frame.size.width / 2 - 10;
    float xRight1 = self.frame.size.width / 2 + self.textLabel.frame.size.width / 2 + 10;
    float xRight2 = self.frame.size.width - 10;
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:CGPointMake(xLeft1, y)];
    [path1 addLineToPoint:CGPointMake(xLeft2, y)];
    [path1 stroke];

    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 moveToPoint:CGPointMake(xRight1, y)];
    [path2 addLineToPoint:CGPointMake(xRight2, y)];
    [path2 stroke];
}

- (void)setText:(NSString *)text{
    [self.textLabel setText:text];
}

@end
