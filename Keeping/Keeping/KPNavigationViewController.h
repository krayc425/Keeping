//
//  KPNavigationViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABCIntroView.h"

@interface KPNavigationViewController : UINavigationController <ABCIntroViewDelegate>

@property (nonatomic, nonnull) ABCIntroView *introView;

- (void)setFont;

@end
