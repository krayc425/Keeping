//
//  KPCalInfoView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPCalInfoView.h"
#import "Utilities.h"
#import "DateTools.h"

static BOOL _loadingXib = NO;

@implementation KPCalInfoView{
    NSArray *statusArr;
    NSArray *colorArr;
    NSArray *textArr;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self commitInit];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit{
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    
    statusArr = @[@0,@1,@1,@0];
    colorArr = [[NSArray alloc] initWithObjects:
                [UIColor redColor],
                [Utilities getColor],
                [UIColor lightGrayColor],
                [Utilities getColor],
                nil
                 ];
    textArr = @[
                @"代表过去未打卡的日期",
                @"代表过去已经打卡的日期",
                @"代表过去跳过打卡的日期",
                @"代表未来需要打卡的日期"
                ];
    
    for(UILabel *label in self.labels){
        [label setFont:[UIFont systemFontOfSize:15.0]];
    }
    
    for(UIStackView *stack in self.stackView.subviews){
        int i = (int)stack.tag;
        
        UIButton *button = (UIButton *)stack.subviews[0];
        [button setTintColor:colorArr[i]];
        
        UIImage *img;
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if([statusArr[i]  isEqual: @0]){
            img = [UIImage imageNamed:@"CIRCLE_BORDER"];
        }else{
            img = [UIImage imageNamed:@"CIRCLE_FULL"];
        }
        [button setImage:img forState:UIControlStateNormal];
        
        UILabel *label = stack.subviews[1];
        [label setText:textArr[i]];
    }
    
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {
    if(_loadingXib) {
        // xib
        return self;
    } else {
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

@end
