//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPSettingsTableViewController : UITableViewController

@property (nonatomic, nonnull) IBOutlet UILabel *versionLabel;

@property (nonatomic, nonnull) IBOutlet UISwitch *animationSwitch;

@property (nonatomic, nonnull) IBOutlet UISwitch *badgeSwitch;

@property (nonatomic, nonnull) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, nonnull) IBOutlet UILabel *unreadMsgLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *fontLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *typeTextLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *animationLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *scoreLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *mailLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *numberLabel;
//@property (nonatomic, nonnull) IBOutlet UILabel *donateLabel;

- (void)checkMessage:(_Nonnull id)sender;

@end
