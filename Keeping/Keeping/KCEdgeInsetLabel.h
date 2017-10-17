//
//  KCEdgeInsetLabel.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCEdgeInsetLabel : UILabel

@property (nonatomic) UIEdgeInsets textEdgeInsets;

- (instancetype _Nonnull)initWithFrame:(CGRect)frame andEdgeInset:(UIEdgeInsets)inset;

@end
