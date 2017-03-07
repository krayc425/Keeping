//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPSettingsTableViewController : UITableViewController

@property (nonatomic, nonnull) IBOutlet UISwitch *animationSwitch;

@property (nonatomic, nonnull) IBOutlet UISwitch *badgeSwitch;

@property (nonatomic, nonnull) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, nonnull) IBOutlet UILabel *unreadMsgLabel;

@property (nonatomic, nonnull) IBOutlet UILabel *cacheLabel;

@property (nonatomic, nonnull) IBOutlet UILabel *userNameLabel;
@property (nonatomic, nonnull) IBOutlet UIStackView *appButtonStack;

- (void)checkMessage:(_Nonnull id)sender;

@end
