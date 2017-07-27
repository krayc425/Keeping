//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPSettingsTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UISwitch *animationSwitch;

@property (nonatomic, weak) IBOutlet UISwitch *badgeSwitch;

@property (nonatomic, weak) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, weak) IBOutlet UILabel *unreadMsgLabel;

@property (nonatomic, weak) IBOutlet UILabel *cacheLabel;

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIStackView *appButtonStack;

- (void)checkMessage:(_Nonnull id)sender;

@end
