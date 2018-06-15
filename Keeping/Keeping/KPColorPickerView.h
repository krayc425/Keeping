//
//  KPColorPickerView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPHoverView.h"

@class KPColorPickerView;

@protocol KPColorPickerDelegate

/**
 *  选择颜色变化之后的代理方法
 */
- (void)didChangeColors:(int)selectColorNum;

@end

@interface KPColorPickerView : KPHoverView

//button tag : 1 ~ 7
@property (nonatomic, weak) IBOutlet UIStackView *colorStack;

@property (nonatomic) int selectedColorNum;

@property (weak, nonatomic) id<KPColorPickerDelegate> colorDelegate;

@end
