//
//  DBManager.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface DBManager : NSObject

@property (nonatomic, nullable) FMDatabase *db;

+ (_Nonnull instancetype)shareInstance;
- (FMDatabase *_Nonnull)getDB;
- (void)closeDB;
- (NSString *_Nonnull)getDBPath;

@end
