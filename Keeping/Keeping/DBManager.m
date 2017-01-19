//
//  DBManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

static DBManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [DBManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self establishDB];
    }
    return self;
}

- (void)establishDB{
    //1.数据库路径
    NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"task.sqlite"];
    NSLog(@"%@", doc);
    //2.获得数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    //3.使用如下语句，如果打开失败，可能是权限不足或者资源不足。通常打开完操作操作后，需要调用 close 方法来关闭数据库。在和数据库交互之前，数据库必须是打开的。如果资源或权限不足无法打开或创建数据库，都会导致打开失败。
    if ([self.db open]){
    //4.创表
        BOOL result = [self.db executeUpdate:
                       @"CREATE TABLE IF NOT EXISTS t_task (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, appScheme text, reminderDays text, addDate date NOT NULL, reminderTime date, punchDateArr text)"];
        if (result){
            NSLog(@"创建表成功");
        }
    }
}

- (FMDatabase *_Nonnull)getDB{
    return self.db;
}

- (void)closeDB{
    NSLog(@"db close");
    [self.db close];
}

@end
