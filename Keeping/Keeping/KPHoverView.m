//
//  KPHoverView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/14.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "KPHoverView.h"
#import "UIView+Extensions.h"
#import "Utilities.h"

@implementation KPHoverView{
    CGFloat finalOffsetY;
    BOOL shouldStop;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _isShow = NO;
        self.backgroundColor = [Utilities getColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        _isShow = NO;
        self.backgroundColor = [Utilities getColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)show{
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerScrollView.contentInset = UIEdgeInsetsMake(self.frame.size.height + 10.0, 0, 0, 0);
        self.frame = CGRectMake(self.frame.origin.x,
                                -self.frame.size.height,
                                self.frame.size.width,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    _isShow = YES;
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

- (void)hide{
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerScrollView.contentInset = UIEdgeInsetsZero;
        self.frame = CGRectMake(self.frame.origin.x,
                                - self.frame.size.height,
                                self.frame.size.width,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    _isShow = NO;
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

@end
