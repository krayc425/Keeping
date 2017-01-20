//
//  CardsView.m
//  mFinoWallet
//
//  Created by Vishwa Deepak on 31/01/16.
//  Copyright © 2016 mFino. All rights reserved.
//

#import "CardsView.h"
#import "Utilities.h"

@implementation CardsView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
    // Drawing code
//}


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    _cornerRadius = 2;
}

- (void)layoutSubviews{
    self.layer.cornerRadius = _cornerRadius;
//    [[Utilities getColor] setStroke];
//    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:self.frame cornerRadius:_cornerRadius];
//    borderPath.lineWidth = 1;
//    [borderPath stroke];
}

@end
