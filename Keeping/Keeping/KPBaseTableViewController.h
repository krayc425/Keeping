//
//  KPBaseTableViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2018/7/4.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPHoverView.h"
#import "UIScrollView+EmptyDataSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface KPBaseTableViewController : UITableViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, nonnull, strong) KPHoverView *hoverView;

@property (nonatomic, nonnull) NSString *sortFactor;
@property (nonnull, nonatomic) NSNumber *isAscend;

- (void)editAction:(_Nonnull id)sender;
- (void)fadeAnimation;
    
@end

NS_ASSUME_NONNULL_END
