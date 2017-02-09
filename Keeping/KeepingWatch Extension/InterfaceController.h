//
//  InterfaceController.h
//  KeepingWatch Extension
//
//  Created by 宋 奎熹 on 2017/2/8.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface InterfaceController : WKInterfaceController

@property (nonatomic, nonnull) FMDatabase *db;

@property (nonatomic, nonnull) NSMutableArray *taskArr;
@property (nonatomic, nonnull) IBOutlet WKInterfaceLabel *dateLabel;

@end
