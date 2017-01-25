//
//  KPCalTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardsView.h"

@interface KPCalTaskTableViewCell : UITableViewCell

@property (nonnull, nonatomic) IBOutlet CardsView *cardView;

@property (nonatomic, nonnull) IBOutlet UILabel *taskNameLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *punchDaysLabel;

- (void)setIsSelected:(BOOL)isSelected;
- (void)setFont;

@end
