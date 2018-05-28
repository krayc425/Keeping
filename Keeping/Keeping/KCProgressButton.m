//
//  KCProgressButton.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KCProgressButton.h"
#import "KCEdgeInsetLabel.h"
#import "Utilities.h"

@implementation KCProgressButton

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    NSArray *countArr = [title componentsSeparatedByString:@" / "];
    [self addMaskLabelWithProgress:[(countArr[0]) floatValue] / [(countArr[1]) floatValue]];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [super initWithCoder:aDecoder];
}

- (void)setProgressWithFinished:(int)finished andTotal:(int)total {
    float progress = 0.0;
    if (total > 0) {
        progress = (float)finished / (float)total;
    }
    [self setTitle:[NSString stringWithFormat:@"%d / %d", finished, total] forState:UIControlStateNormal];
    NSLog(@"title %@", self.titleLabel.text);
    [self addMaskLabelWithProgress:progress];
}

- (void)addMaskLabelWithProgress:(float)progress {
    NSLog(@"progress %f", progress);
    
    if (self.maskLabel != nil) {
        [self.maskLabel removeFromSuperview];
    }
    
    self.maskLabel = [[KCEdgeInsetLabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        self.frame.size.width * progress,
                                                                        self.frame.size.height)
                                                andEdgeInset:UIEdgeInsetsMake(0, self.titleLabel.frame.origin.x, 0, 0)];
    self.maskLabel.text = self.titleLabel.text;
    self.maskLabel.font = self.titleLabel.font;
    self.maskLabel.backgroundColor = [Utilities getColor];
    self.maskLabel.textColor = [UIColor whiteColor];
    self.maskLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.maskLabel.textAlignment = self.titleLabel.textAlignment;
    self.maskLabel.layer.cornerRadius = self.layer.cornerRadius;
    self.maskLabel.layer.masksToBounds = YES;
    [self addSubview:self.maskLabel];
}

@end
