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

@property (nonatomic, weak, nullable) id<WidgetTaskDelegate> delegate;

@property (nonatomic, weak, nullable) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak, nullable) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak, nullable) IBOutlet BEMCheckBox *checkBox;

@end
