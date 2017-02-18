//
//  KPAboutTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPAboutTableViewController : UITableViewController

@property (nonatomic, nonnull) IBOutlet UILabel *nameLabel;

@property (nonatomic, nonnull) IBOutlet UILabel *versionLabel;

@property (nonatomic, nonnull) IBOutletCollection(UILabel) NSArray *labels;

@end
