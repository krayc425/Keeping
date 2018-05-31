//
//  KPBaseTableViewCell.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/5/29.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

#import "KPBaseTableViewCell.h"
#import "MGSwipeTableCell.h"
#import "Utilities.h"

@implementation KPBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.swipeBackgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    MGSwipeExpansionSettings *setting = [[MGSwipeExpansionSettings alloc] init];
    setting.buttonIndex = 0;
    setting.fillOnTrigger = YES;
    setting.threshold = 2.0;
    
    self.leftExpansion = setting;
    self.rightExpansion = setting;
    
    self.leftButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"CELL_INFO"] backgroundColor:[UIColor clearColor]]];
    self.leftButtons[0].tintColor = [Utilities getColor];
    
    self.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"CELL_DELETE"] backgroundColor:[UIColor clearColor]]];
    self.rightButtons[0].tintColor = [UIColor redColor];
    
    self.leftSwipeSettings.transition = MGSwipeTransitionStatic;
    self.rightSwipeSettings.transition = MGSwipeTransitionStatic;
}

@end
