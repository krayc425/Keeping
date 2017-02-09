//
//  KPWidgetTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPWidgetTableViewCell.h"
#import "Utilities.h"

#define GROUP_ID @"group.com.krayc.keeping"

@implementation KPWidgetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.nameLabel setTextColor:[Utilities getColor]];
    [self.timeLabel setTextColor:[Utilities getColor]];
    
//        [self.nameLabel setTextColor:[UIColor blackColor]];
//        [self.timeLabel setTextColor:[UIColor blackColor]];
    
    self.checkBox.delegate = self;
    [self.checkBox setOnAnimationType:BEMAnimationTypeFill];
    [self.checkBox setOffAnimationType:BEMAnimationTypeFill];
    
    [self.checkBox setOnTintColor:[Utilities getColor]];
    [self.checkBox setOnCheckColor:[Utilities getColor]];
    [self.checkBox setOnFillColor:[UIColor clearColor]];
    
    [self setFont];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)animationDidStopForCheckBox:(BEMCheckBox *)checkBox{
    [self.delegate checkTask:self];
}

- (void)setFont{
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:GROUP_ID];
    NSString *fontName = (NSString *)[shared valueForKey:@"fontwidget"];
    
    [self.nameLabel setFont:[UIFont fontWithName:fontName size:20.0f]];
    [self.timeLabel setFont:[UIFont fontWithName:fontName size:17.0f]];
}

@end
