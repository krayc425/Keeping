//
//  KCEdgeInsetLabel.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KCEdgeInsetLabel.h"

@implementation KCEdgeInsetLabel

- (instancetype)initWithFrame:(CGRect)frame andEdgeInset:(UIEdgeInsets)inset {
    self = [super initWithFrame:frame];
    if (self) {
        self.textEdgeInsets = inset;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [super initWithCoder:aDecoder];
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textEdgeInsets)];
}

@end
