//
//  KPTodayTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@protocol CheckTaskDelegate <NSObject>

/**
 此方为必须实现的协议方法，用来传值
 */
- (void)checkTask:(UITableViewCell *_Nonnull)cell;

@end

@interface KPTodayTableViewCell : UITableViewCell <BEMCheckBoxDelegate>

@property (nonatomic, nonnull) id<CheckTaskDelegate> delegate;

@property (nonatomic, nonnull) IBOutlet UILabel *taskNameLabel;

@property (nonnull, nonatomic) IBOutlet UILabel *accessoryLabel;

@property (nonnull, nonatomic) IBOutlet BEMCheckBox *myCheckBox;

- (void)setIsFinished:(BOOL)isFinished;

@end
