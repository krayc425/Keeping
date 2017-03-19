//
//  KPCalInfoView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPCalInfoView : UIView

@property (nonnull, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@property (nonnull, nonatomic) IBOutlet UIStackView *stackView;

@end
