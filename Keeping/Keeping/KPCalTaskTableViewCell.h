//
//  KPCalTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface KPCalTaskTableViewCell : UITableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, nonnull) IBOutlet UILabel *taskNameLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *punchDaysLabel;

@property (nonnull, nonatomic) IBOutlet BEMCheckBox *myCheckBox;

- (void)setIsFinished:(BOOL)isFinished;

- (void)setFont;

@end
