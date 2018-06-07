//
//  KPTabBar.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/15.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBar.h"
#import "KPTaskDetailTableViewController.h"
#import "Utilities.h"

@implementation KPTabBar

@dynamic delegate;

- (void)publishClick:(id)sender{
    if ([self.addDelegate respondsToSelector:@selector(tabBar:didTappedAddButton:)]) {
        [self.addDelegate tabBar:self didTappedAddButton:sender];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    // tabBar的尺寸
    CGFloat width = self.frame.size.width;
    
    BOOL isiPhoneX = SCREEN_WIDTH == 375 && SCREEN_HEIGHT == 812;
    
    CGFloat height = self.frame.size.height - (isiPhoneX ? 25.0 : 0.0);
    CGFloat buttonWidth = 50.0;
    
    // 添加发布按钮
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [publishButton setBackgroundImage:[UIImage imageNamed:@"TAB_ADD"] forState:UIControlStateNormal];
    [publishButton setBackgroundImage:[UIImage imageNamed:@"TAB_ADD_SELECTED"] forState:UIControlStateHighlighted];
    [publishButton sizeToFit];
    [publishButton addTarget:self
                      action:@selector(publishClick:)
            forControlEvents:UIControlEventTouchUpInside];
    [publishButton setCenter:CGPointMake(width * 0.5, isiPhoneX ? buttonWidth / 4.0 : 7.5)];
    [publishButton setBounds:CGRectMake(0, 0, buttonWidth, buttonWidth)];
    [self addSubview:publishButton];
    self.publishButton = publishButton;
    
    // 按钮索引
    int index = 0;
    
    // 按钮的尺寸
    CGFloat tabBarButtonW = (width - CGRectGetWidth(publishButton.frame)) / 2;
    CGFloat tabBarButtonH = height;
    CGFloat tabBarButtonY = 0;
    
    // 设置TabBarButton的frame
    for (UIView *tabBarButton in self.subviews) {
        if (![NSStringFromClass(tabBarButton.class) isEqualToString:@"UITabBarButton"]){
            continue;
        }
        
        // 计算按钮的X值
        CGFloat tabBarButtonX = index * tabBarButtonW;
        if (index == 1) { // 给后面1个button增加一个宽度的X值
            tabBarButtonX += CGRectGetWidth(publishButton.frame);
        }
        
        // 设置按钮的frame
        tabBarButton.frame = CGRectMake(tabBarButtonX, tabBarButtonY, tabBarButtonW, tabBarButtonH);
        
        // 增加索引
        index++;
    }
}

@end
