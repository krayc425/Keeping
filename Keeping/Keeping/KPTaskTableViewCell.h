//
//  KPTaskTableViewCell.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPTaskTableViewCell : UITableViewCell

@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *daysLabel;

@property (nonnull, nonatomic) IBOutlet UILabel *accessoryLabel;

@end
