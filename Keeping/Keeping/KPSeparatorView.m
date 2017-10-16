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
    [self.textLabel setTextColor:[Utilities getColor]];
}

- (void)setText:(NSString *)text{
    [self.textLabel setText:text];
}

@end
