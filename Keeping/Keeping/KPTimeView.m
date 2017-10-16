//
//  KPTimeView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTimeView.h"
#import "Utilities.h"
#import "DateTools.h"

#define BORDER_WIDTH 1
#define CORNER_RADIUS 5

static BOOL _loadingXib = NO;

@implementation KPTimeView

- (void)drawRect:(CGRect)rect {
    [self setFont];
    // Drawing code
    self.hourLabel.layer.borderColor = [Utilities getColor].CGColor;
    self.hourLabel.layer.borderWidth = BORDER_WIDTH;
    self.hourLabel.layer.cornerRadius = CORNER_RADIUS;
    self.minuteLabel.layer.borderColor = [Utilities getColor].CGColor;
    self.minuteLabel.layer.borderWidth = BORDER_WIDTH;
    self.minuteLabel.layer.cornerRadius = CORNER_RADIUS;
}

- (void)setTime:(NSDate *)date{
    if(date == NULL){
        [self.colonLabel setHidden:YES];
        [self.minuteLabel setHidden:YES];
        [self.hourLabel setText:@"全天"];
    }else{
        [self.hourLabel setText:[NSString stringWithFormat:@"%02ld", (long)date.hour]];
        [self.minuteLabel setText:[NSString stringWithFormat:@"%02ld", (long)date.minute]];
    }
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if(_loadingXib) {
        // xib
        return self;
    }
    else {
        // storyboard
        _loadingXib = YES;
        typeof(self) view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                           owner:nil
                                                         options:nil] objectAtIndex:0];
        view.frame = self.frame;
        view.autoresizingMask = self.autoresizingMask;
        view.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints;
        
        // copy autolayout constraints
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        for(NSLayoutConstraint *constraint in self.constraints) {
            id firstItem = constraint.firstItem;
            id secondItem = constraint.secondItem;
            if(firstItem == self) firstItem = view;
            if(secondItem == self) secondItem = view;
            [constraints addObject:[NSLayoutConstraint constraintWithItem:firstItem
                                                                attribute:constraint.firstAttribute
                                                                relatedBy:constraint.relation
                                                                   toItem:secondItem
                                                                attribute:constraint.secondAttribute
                                                               multiplier:constraint.multiplier
                                                                 constant:constraint.constant]];
        }
        
        // move subviews
        for(UIView *subview in self.subviews) {
            [view addSubview:subview];
        }
        [view addConstraints:constraints];
        
        _loadingXib = NO;
        return view;
    }
}

- (void)setFont{
    [self.hourLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.hourLabel setTextColor:[Utilities getColor]];
    [self.minuteLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.minuteLabel setTextColor:[Utilities getColor]];
    [self.colonLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.colonLabel setTextColor:[Utilities getColor]];
}

@end
