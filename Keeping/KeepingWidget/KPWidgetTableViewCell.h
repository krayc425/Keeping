//
//  KPWidgetTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@protocol WidgetTaskDelegate <NSObject>

- (void)checkTask:(UITableViewCell *_Nonnull)cell;

@end

@interface KPWidgetTableViewCell : UITableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, nonnull) id<WidgetTaskDelegate> delegate;

@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *timeLabel;

@property (nonatomic, nonnull) IBOutlet BEMCheckBox *checkBox;

- (void)setFont;

@end
