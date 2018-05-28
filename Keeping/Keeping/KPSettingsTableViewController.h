//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

// 静态库方式引入
#import <LeanCloudSocial/AVOSCloudSNS.h>
#import <LeanCloudSocial/AVUser+SNS.h>

@interface KPSettingsTableViewController : UITableViewController

@property (nonatomic, weak, nullable) IBOutlet UISwitch *animationSwitch;

@property (nonatomic, weak, nullable) IBOutlet UISwitch *badgeSwitch;

@property (nonatomic, weak, nullable) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, weak, nullable) IBOutlet UILabel *unreadMsgLabel;

@property (nonatomic, weak, nullable) IBOutlet UILabel *cacheLabel;

@property (nonatomic, weak, nullable) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak, nullable) IBOutlet UIStackView *appButtonStack;

@end
