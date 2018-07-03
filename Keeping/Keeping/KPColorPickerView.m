//
//  KPColorPickerView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPColorPickerView.h"
#import "Utilities.h"
#import "AMPopTip.h"
#import "UIView+Extensions.h"

static BOOL _loadingXib = NO;

@interface KPColorPickerView (){
    AMPopTip *popTip;
    NSArray *colorArr;
}

@end

@implementation KPColorPickerView

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
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 10.0;
    
    colorArr = [Utilities getTypeColorArr];
    //类别按钮
    for (int i = 0; i < [colorArr count]; i++) {
        UIButton *btn = (UIButton *)self.colorStack.subviews[i];
        UIImage *img = [UIImage imageNamed:@"CIRCLE_FULL"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [btn setTintColor:[Utilities getTypeColorArr][i]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:CGRectGetWidth(btn.frame) / 2.0]];
        [btn setTag:i + 1];
    }
    
    if(self.selectedColorNum > 0){
        for(UIButton *btn in self.colorStack.subviews){
            if(btn.tag == self.selectedColorNum){
                [btn setTitle:@"●" forState:UIControlStateNormal];
            }else{
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
        }
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

#pragma mark - Select Color Action

- (IBAction)selectColorAction:(id)sender{
    [self vibrateWithStyle:UIImpactFeedbackStyleLight];
    
    UIButton *button = (UIButton *)sender;
    if(self.selectedColorNum == (int)button.tag){
        self.selectedColorNum = -1;
    }else{
        self.selectedColorNum = (int)button.tag;
    }
    for(UIButton *btn in self.colorStack.subviews){
        if(btn.tag == self.selectedColorNum){
            [btn setTitle:@"●" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"" forState:UIControlStateNormal];
        }
    }
    
    NSString *str = [[[NSUserDefaults standardUserDefaults] objectForKey:@"typeTextArr"] mutableCopy][button.tag - 1];
    
    if(str != NULL && ![str isEqualToString:@""] && self.selectedColorNum != -1){
        popTip = [AMPopTip popTip];
        
        popTip.textColor = [UIColor whiteColor];
        popTip.tintColor = colorArr[button.tag - 1];
        popTip.popoverColor = colorArr[button.tag - 1];
        popTip.borderColor = [UIColor whiteColor];
        
        popTip.radius = 10;
        
        [popTip showText:str
               direction:self.selectedColorNum <= colorArr.count / 2 ? AMPopTipDirectionRight : AMPopTipDirectionLeft
                maxWidth:200
                  inView:self
               fromFrame:CGRectOffset(button.frame, self.selectedColorNum <= colorArr.count / 2 ? -8.0f : 8.0f, 0)
                duration:1.0f];
    }
    
    [self.colorDelegate didChangeColors:self.selectedColorNum];
}

@end
