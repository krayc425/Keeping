
//
//  TaskManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TaskManager.h"
#import "DBManager.h"
#import "Utilities.h"
#import "DateUtil.h"
#import "DateTools.h"
#import "UNManager.h"

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
    
    NSArray *punchArr = task.punchDateArr;
    NSString *punchJsonStr;
    if([punchArr count] > 0 || punchArr != NULL){
        NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchArr options:NSJSONWritingPrettyPrinted error:&err];
        punchJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchJsonStr = nil;
    }
    
    if(task.reminderTime != nil){
        [UNManager createLocalizedUserNotification:task];
    }
    
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"INSERT INTO t_task (name, appScheme, reminderDays, addDate, reminderTime, punchDateArr, image, link) VALUES (?, ?, ?, ?, ?, ?, ?, ?);",
            task.name,
            schemeJsonStr,
            daysJsonStr,
            task.addDate,
            task.reminderTime,
            punchJsonStr,
            task.image,
            task.link
            ];
}

- (BOOL)updateTask:(Task *_Nonnull)task{
    
    NSError *err = nil;
    
    NSDictionary *schemeDict = task.appScheme;
    NSString *schemeJsonStr;
    if(schemeDict != NULL){
        NSData *schemeJsonData = [NSJSONSerialization dataWithJSONObject:schemeDict options:NSJSONWritingPrettyPrinted error:&err];
        schemeJsonStr = [[NSString alloc] initWithData:schemeJsonData encoding:NSUTF8StringEncoding];
    }else{
        schemeJsonStr = NULL;
    }
    
    NSArray *daysArr = task.reminderDays;
    NSString *daysJsonStr;
    if([daysArr count] > 0 || daysArr != NULL){
        NSData *daysJsonData = [NSJSONSerialization dataWithJSONObject:daysArr options:NSJSONWritingPrettyPrinted error:&err];
        daysJsonStr = [[NSString alloc] initWithData:daysJsonData encoding:NSUTF8StringEncoding];
    }else{
        daysJsonStr = NULL;
    }
    
    NSArray *punchArr = task.punchDateArr;
    NSString *punchJsonStr;
    if([punchArr count] > 0 || punchArr != NULL){
        NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchArr options:NSJSONWritingPrettyPrinted error:&err];
        punchJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchJsonStr = NULL;
    }
    
    if(task.reminderTime != nil){
        [UNManager deleteLocalizedUserNotification:task];
        [UNManager createLocalizedUserNotification:task];
    }
    
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"UPDATE t_task SET name = ?, appScheme = ?, reminderDays = ?, addDate = ?, reminderTime = ?, punchDateArr = ?, image = ?, link = ? WHERE id = ?;",
            task.name,
            schemeJsonStr,
            daysJsonStr,
            task.addDate,
            task.reminderTime,
            punchJsonStr,
            task.image,
            task.link,
            @(task.id)
            ];
    return YES;
}

- (BOOL)deleteTask:(Task *_Nonnull)task{
    [UNManager deleteLocalizedUserNotification:task];
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"delete from t_task where id = ?;",
            @(task.id)];
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
        
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchDateArr = punchArr;
        }
        
        t.addDate = [resultSet dateForColumn:@"addDate"];
        t.reminderTime = [resultSet dateForColumn:@"reminderTime"];
        t.image = [resultSet dataForColumn:@"image"];
        t.link = [resultSet stringForColumn:@"link"];
        
        [self.taskArr addObject:t];
    }
}

- (NSMutableArray *)getTasks{
    [self loadTask];
    return self.taskArr;
}

- (NSMutableArray *)getTodayTasks{
    NSMutableArray *taskArr = [[NSMutableArray alloc] init];
    for (Task *task in [self getTasks]) {
        if([task.reminderDays containsObject:[NSNumber numberWithInt:(int)[[NSDate date] weekday]]]){
            [taskArr addObject:task];
        }
    }
    return taskArr;
}

- (NSMutableArray *)getTasksOfDate:(NSDate *)date{
    NSMutableArray *taskArr = [[NSMutableArray alloc] init];
    for (Task *task in [self getTasks]) {
        if([task.reminderDays containsObject:[NSNumber numberWithInt:(int)date.weekday]]
           && [task.addDate isEarlierThanOrEqualTo:date]){
            [taskArr addObject:task];
        }
    }
    return taskArr;
}

- (int)totalPunchNumberOfTask:(Task *)task{
    NSDate *date = task.addDate;
    NSArray *weekDays = task.reminderDays;
    int count = 0;
    while (date.day != [[[NSDate date] dateByAddingDays:1] day] ) {
        if([weekDays containsObject:@(date.weekday)]){
            count++;
        }
        date = [date dateByAddingDays:1];
    }
    return count;
}

- (BOOL)punchForTaskWithID:(NSNumber *)taskid{
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task where id = ?;", taskid];
    while([resultSet next]){
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *punchArr = [[NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
            
            if([punchArr count] <= 0){
                punchArr = [[NSMutableArray alloc] init];
            }
            
            if(![punchArr containsObject:[DateUtil transformDate:[NSDate date]]]){
                [punchArr addObject:[DateUtil transformDate:[NSDate date]]];
            }
            
            NSError *err = nil;
            NSString *punchJsonStr;
            if([punchArr count] > 0 || punchArr != NULL){
                NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchArr options:NSJSONWritingPrettyPrinted error:&err];
                punchJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
            }else{
                punchJsonStr = nil;
            }
            
            return [[[DBManager shareInstance] getDB] executeUpdate:@"update t_task set punchDateArr = ? where id = ?;", punchJsonStr, taskid];
        }
    }
    return NO;
}

- (BOOL)unpunchForTaskWithID:(NSNumber *)taskid{
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task where id = ?;", taskid];
    while([resultSet next]){
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *punchArr = [[NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
            
            if([punchArr count] <= 0){
                punchArr = [[NSMutableArray alloc] init];
            }
            
            if([punchArr containsObject:[DateUtil transformDate:[NSDate date]]]){
                [punchArr removeObject:[DateUtil transformDate:[NSDate date]]];
            }
            
            NSError *err = nil;
            NSString *punchJsonStr;
            if([punchArr count] > 0 || punchArr != NULL){
                NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchArr options:NSJSONWritingPrettyPrinted error:&err];
                punchJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
            }else{
                punchJsonStr = nil;
            }
            
            return [[[DBManager shareInstance] getDB] executeUpdate:@"update t_task set punchDateArr = ? where id = ?;", punchJsonStr, taskid];
        }
    }
    return NO;
}

@end
