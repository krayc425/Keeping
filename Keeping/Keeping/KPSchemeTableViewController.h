//
//  KPSchemeTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPScheme.h"

@protocol SchemeDelegate <NSObject>

/**
 此方为必须实现的协议方法，用来传值
 */
- (void)passScheme:(KPScheme *_Nullable)scheme;

@end

@interface KPSchemeTableViewController : UITableViewController <UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, weak, nullable) id<SchemeDelegate> delegate;

@property (nonatomic, nullable) KPScheme *selectedApp;

@property (nonatomic, copy, nonnull) NSMutableArray *searchResults;
@property (nonatomic, copy, nonnull) NSMutableArray *schemeArr;

@property (nonatomic, nonnull) UISearchController *searchController;

@property (nonatomic, weak, nullable) IBOutlet UILabel *noneLabel;
@property (nonatomic, weak, nullable) IBOutlet UILabel *refreshLabel;
@property (nonatomic, weak, nullable) IBOutlet UILabel *insLabel;

@end
