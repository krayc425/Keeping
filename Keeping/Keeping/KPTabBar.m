//
//  KPTabBar.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/15.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBar.h"
#import "KPTaskDetailTableViewController.h"

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
    CGFloat height = self.frame.size.height;
    
    // 添加发布按钮
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [publishButton setBackgroundImage:[UIImage imageNamed:@"TAB_ADD"] forState:UIControlStateNormal];
    [publishButton setBackgroundImage:[UIImage imageNamed:@"TAB_ADD"] forState:UIControlStateHighlighted];
    [publishButton sizeToFit];
    [publishButton addTarget:self action:@selector(publishClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:publishButton];
    self.publishButton = publishButton;
    // 设置发布按钮的位置
    self.publishButton.center = CGPointMake(width * 0.5, height * 0.5);
    
    // 按钮索引
    int index = 0;
    
    // 按钮的尺寸
    CGFloat tabBarButtonW = width / 5;
    CGFloat tabBarButtonH = height;
    CGFloat tabBarButtonY = 0;
    
    // 设置4个TabBarButton的frame
    for (UIView *tabBarButton in self.subviews) {
        if (![NSStringFromClass(tabBarButton.class) isEqualToString:@"UITabBarButton"]){
            continue;
        }
        
        // 计算按钮的X值
        CGFloat tabBarButtonX = index * tabBarButtonW;
        if (index >= 2) { // 给后面2个button增加一个宽度的X值
            tabBarButtonX += tabBarButtonW;
        }
        
        // 设置按钮的frame
        tabBarButton.frame = CGRectMake(tabBarButtonX, tabBarButtonY, tabBarButtonW, tabBarButtonH);
        
        // 增加索引
        index++;
    }
}

@end
