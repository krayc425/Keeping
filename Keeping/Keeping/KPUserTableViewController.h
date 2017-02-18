//
//  KPUserTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LeanCloudSocial/AVUser+SNS.h>

@interface KPUserTableViewController : UITableViewController

@property (nonatomic, nonnull) AVUser *currentUser;

@property (nonatomic, nonnull) IBOutletCollection(UILabel) NSArray *labels;

@property (nonatomic, nonnull) IBOutlet UILabel *userNameLabel;

@end
