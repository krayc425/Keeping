//
//  KPTabBar+BadgeTabBar.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/15.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTabBar.h"

@interface KPTabBar (BadgeTabBar)

- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
