//
//  KPWeekdayPickerHeaderView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/15.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "KPWeekdayPickerHeaderView.h"
#import "KPWeekdayPickerView.h"

@implementation KPWeekdayPickerHeaderView

- (void)drawRect:(CGRect)rect{
    self.isAllButtonHidden = YES;
    
    [super drawRect:rect];
    
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    self.weekDayStack.spacing = 10.0;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    return [self initWithCoder:aDecoder];
}

@end
