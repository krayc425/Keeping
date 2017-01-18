
//
//  TaskManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TaskManager.h"
#import "DBManager.h"

@implementation TaskManager

static TaskManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [TaskManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.taskArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [TaskManager shareInstance] ;
}

#pragma mark - Add, Update, Delete, Search

- (BOOL)addTask:(Task *)task{
    
    NSError *err = nil;
    
    NSDictionary *schemeDict = task.appScheme;
    NSString *schemeJsonStr;
    if(schemeDict != NULL){
        NSData *schemeJsonData = [NSJSONSerialization dataWithJSONObject:schemeDict options:NSJSONWritingPrettyPrinted error:&err];
        schemeJsonStr = [[NSString alloc] initWithData:schemeJsonData encoding:NSUTF8StringEncoding];
    }else{
        schemeJsonStr = nil;
    }
    
    NSArray *daysArr = task.reminderDays;
    NSString *daysJsonStr;
    if([daysArr count] > 0 || daysArr != NULL){
        NSData *daysJsonData = [NSJSONSerialization dataWithJSONObject:daysArr options:NSJSONWritingPrettyPrinted error:&err];
        daysJsonStr = [[NSString alloc] initWithData:daysJsonData encoding:NSUTF8StringEncoding];
    }else{
        daysJsonStr = nil;
    }
    
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"INSERT INTO t_task (name, appScheme, reminderDays) VALUES (?, ?, ?);",
            task.name,
            schemeJsonStr,
            daysJsonStr
            ];
}

- (BOOL)deleteTask:(int)id{
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"delete from t_task where id = ?;",
            @(id)];
}

- (void)loadTask{
    [self.taskArr removeAllObjects];
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task;"];
    while ([resultSet next]){

//TODO: TASK UPDATE HERE
        
        Task *t = [Task new];
        t.id = [resultSet intForColumn:@"id"];
        t.name = [resultSet stringForColumn:@"name"];
        
        NSString *schemeJsonStr = [resultSet stringForColumn:@"appScheme"];
        if(schemeJsonStr != NULL){
            NSData *schemeData = [schemeJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *schemeDict = [NSJSONSerialization JSONObjectWithData:schemeData options:NSJSONReadingAllowFragments error:nil];
            t.appScheme = schemeDict;
        }
        
        NSString *daysJsonStr = [resultSet stringForColumn:@"reminderDays"];
        if(daysJsonStr != NULL){
            NSData *daysData = [daysJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *daysArr = [NSJSONSerialization JSONObjectWithData:daysData options:NSJSONReadingAllowFragments error:nil];
            t.reminderDays = daysArr;
        }

        [self.taskArr addObject:t];
    }
}

- (NSMutableArray *)getTasks{
    [self loadTask];
    return self.taskArr;
}

@end
