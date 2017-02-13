//
//  KPWeekdayPickerView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KPWeekdayPickerView;

@protocol KPWeekdayPickerDelegate

/**
 *  选择日期变化之后的代理方法
 */
- (void)didChangeWeekdays:(NSArray *_Nonnull)selectWeekdays;

@end

@interface KPWeekdayPickerView : UIView

/**
 *  默认是否全选
 */
@property (nonatomic) BOOL isAllSelected;

/**
 *  默认选中的日期
 */
@property (nonnull, nonatomic) NSMutableArray *selectedWeekdayArr;

@property (nonatomic) float fontSize;

@property (nonatomic) BOOL isAllButtonHidden;

@property (nonnull, nonatomic) id<KPWeekdayPickerDelegate> weekdayDelegate;

- (void)selectWeekdaysInArray:(NSArray *_Nonnull)weekdayArr;

- (void)setFont;

@end
