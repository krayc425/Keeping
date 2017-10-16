//
//  KPWeekdayPickerView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPWeekdayPickerView.h"
#import "Utilities.h"
#import "DateUtil.h"

static BOOL _loadingXib = NO;

@interface KPWeekdayPickerView ()

@property (nonatomic, weak) IBOutlet UIStackView *weekDayStack;
@property (nonatomic, weak) IBOutlet UIButton *allButton;

@end

@implementation KPWeekdayPickerView

- (void)drawRect:(CGRect)rect {
    self.frame = rect;
    
    //星期几选项按钮
    for(UIButton *button in self.weekDayStack.subviews){
        [button setTintColor:[Utilities getColor]];
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        if(button.tag != -1){
            //-1是全选按钮
            UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
            buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
        }
    }
    
    [self setFont];
    
    if(self.selectedWeekdayArr == NULL){
        self.selectedWeekdayArr = [[NSMutableArray alloc] init];
    }
    [self selectWeekdaysInArray:self.selectedWeekdayArr];
    
    [self.allButton setHidden:self.isAllButtonHidden];

    self.weekDayStack.spacing = self.fontSize / 2.5;
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
        NSMutableArray *constraints = [NSMutableArray array];
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

#pragma mark - Select Weekday Action

- (IBAction)selectWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIImage *buttonImg;
    NSNumber *tag = [NSNumber numberWithInteger:btn.tag];
    
    if([self.selectedWeekdayArr containsObject:tag]){
        //包含
        buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
        [self.selectedWeekdayArr removeObject:tag];
        [btn setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    }else{
        //不包含
        buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
        [self.selectedWeekdayArr addObject:tag];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setBackgroundImage:buttonImg forState:UIControlStateNormal];
    
    if([self.selectedWeekdayArr count] > 0){
        [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    }else{
        [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    }
    
    [self.weekdayDelegate didChangeWeekdays:self.selectedWeekdayArr];
}

- (IBAction)selectAllWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([btn.titleLabel.text isEqualToString:@"全选"]){
        [self selectAllWeekDay];
    }else if([btn.titleLabel.text isEqualToString:@"清空"]){
        [self deselectAllWeekDay];
    }
}

- (void)selectAllWeekDay{
    [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            NSNumber *tag = [NSNumber numberWithInteger:button.tag];
            if(![self.selectedWeekdayArr containsObject:tag]){
                [self selectWeekdayAction:button];
            }
        }
    }
}

- (void)deselectAllWeekDay{
    [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            NSNumber *tag = [NSNumber numberWithInteger:button.tag];
            if([self.selectedWeekdayArr containsObject:tag]){
                [self selectWeekdayAction:button];
            }
        }
    }
}

- (void)selectWeekdaysInArray:(NSArray *)weekdayArr{
    self.selectedWeekdayArr = [NSMutableArray arrayWithArray:weekdayArr];
    if([self.selectedWeekdayArr count] > 0){
        [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    }else{
        [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    }
    for(int num = 1; num <= 7; num++){
        if([self.selectedWeekdayArr containsObject:@(num)]){
            UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
            buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.weekDayStack.subviews[num-1] setBackgroundImage:buttonImg forState:UIControlStateNormal];
            [self.weekDayStack.subviews[num-1] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
            buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.weekDayStack.subviews[num-1] setBackgroundImage:buttonImg forState:UIControlStateNormal];
            [self.weekDayStack.subviews[num-1] setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        }
    }
}

- (void)setFont{
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            [button.titleLabel setFont:[UIFont systemFontOfSize:self.fontSize]];
        }else{
            [button.titleLabel setFont:[UIFont systemFontOfSize:self.fontSize / 1.5]];
        }
    }
}

@end
