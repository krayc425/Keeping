//
//  KPHoverView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/14.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KPHoverView : UIView

@property (nonatomic, nonnull) UIScrollView *headerScrollView;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) float baseInsetTop;

- (instancetype)initWithFrame:(CGRect)frame andBaseTop:(CGFloat)baseTop;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
