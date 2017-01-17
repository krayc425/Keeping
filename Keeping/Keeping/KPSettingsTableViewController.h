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

@end
