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

@interface KPSchemeTableViewController : UITableViewController <UISearchResultsUpdating, UISearchDisplayDelegate>

@property (nonatomic, nonnull) id<SchemeDelegate> delegate;

@property (nonatomic, nullable) NSIndexPath *selectedPath;

@property (nonatomic, nonnull) NSMutableArray *searchResults;
@property (nonatomic, nonnull) NSMutableArray *schemeArr;

@property (nonatomic ,nonnull) UISearchController *searchController;

@property (nonatomic, nonnull) IBOutlet UILabel *noneLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *refreshLabel;
@property (nonatomic, nonnull) IBOutlet UILabel *insLabel;

@end
