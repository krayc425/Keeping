//
//  KPAboutTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPAboutTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UILabel *versionLabel;

@property (nonatomic, weak) IBOutletCollection(UILabel) NSArray *labels;

@end
