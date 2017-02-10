//
//  KPSettingsTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface KPSettingsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, nonnull) IBOutlet UILabel *versionLabel;

@property (nonatomic, nonnull) IBOutlet UILabel *fontLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *typeLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *scoreLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *mailLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *numberLabel;

@end
