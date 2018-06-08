//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPSettingsTableViewController : UITableViewController

@property (nonatomic, weak, nullable) IBOutlet UISwitch *animationSwitch;

@property (nonatomic, weak, nullable) IBOutlet UISwitch *badgeSwitch;

@property (nonatomic, weak, nullable) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, weak, nullable) IBOutlet UILabel *cacheLabel;

@end
