//
//  KPProgressLabel.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/5/30.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

#import "KPProgressLabel.h"
#import "Utilities.h"
#import "KCEdgeInsetLabel.h"

@implementation KPProgressLabel{
    float progress;
    KCEdgeInsetLabel *maskLabel;
}

- (void)setProgressWithFinished:(NSUInteger)finished andTotal:(NSUInteger)total{
    if (total == 0) {
        progress = 0.0;
        [self setText:@"0 / 0"];
    } else {
        progress = (float)finished / (float)total;
        [self setText:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)finished, (unsigned long)total]];
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize size = [self.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, nil]];
    CGFloat maskWidth = CGRectGetWidth(self.frame) * progress;
    CGFloat startX = (CGRectGetWidth(self.frame) - size.width) / 2.0;
    
    if (maskLabel != nil) {
        [maskLabel removeFromSuperview];
    }
    
    maskLabel = [[KCEdgeInsetLabel alloc] initWithFrame:CGRectMake(0, 0, maskWidth, CGRectGetHeight(self.bounds))
                                           andEdgeInset:UIEdgeInsetsMake(0, startX, 0, 0)];
    maskLabel.text = self.text;
    maskLabel.font = self.font;
    maskLabel.backgroundColor = [Utilities getColor];
    maskLabel.textColor = [UIColor whiteColor];
    maskLabel.lineBreakMode = NSLineBreakByCharWrapping;
    maskLabel.textAlignment = NSTextAlignmentLeft;
    maskLabel.layer.cornerRadius = self.layer.cornerRadius;
    maskLabel.layer.masksToBounds = YES;
    [self addSubview:maskLabel];
}

@end
