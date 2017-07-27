//
//  KPTabBar.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/15.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KPTabBarDelegate <UITabBarDelegate>
@optional
- (void)tabBar:(UITabBar *_Nonnull)tabBar didTappedAddButton:(UIButton *_Nonnull)addButton;

@end

@interface KPTabBar : UITabBar

@property (nonatomic, weak) UIButton *publishButton;

@property (nonatomic, weak) _Nullable id<KPTabBarDelegate> addDelegate;

@end
