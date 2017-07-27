//
//  KPNavigationTitleView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KPNavigationTitleDelegate <NSObject>

- (void)navigationTitleViewTapped;

@end

@interface KPNavigationTitleView : UIView

@property (weak, nonatomic) id<KPNavigationTitleDelegate> navigationTitleDelegate;

//1
- (_Nonnull instancetype)initWithTitle:(NSString *_Nonnull)thisTitle andColor:(UIColor *_Nullable)thisColor;

//2
- (void)setCanTap:(BOOL)thisCanTap;

- (void)changeColor:(UIColor *_Nullable)thisColor;

- (void)setFont;

@end
