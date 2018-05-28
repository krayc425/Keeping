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
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews{
    self.layer.cornerRadius = _cornerRadius;
}

@end
