
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
#import "KPWatchManager.h"

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

#pragma mark - Add, Update, Delete Tasks

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
    
    NSArray *punchMemoArr = task.punchMemoArr;
    NSString *punchMemoJsonStr;
    if([punchMemoArr count] > 0 || punchMemoArr != NULL){
        NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchMemoArr options:NSJSONWritingPrettyPrinted error:&err];
        punchMemoJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchMemoJsonStr = nil;
    }
    
    NSArray *punchSkipArr = task.punchSkipArr;
    NSString *punchSkipJsonStr;
    if([punchSkipArr count] > 0 || punchSkipArr != NULL){
        NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchSkipArr options:NSJSONWritingPrettyPrinted error:&err];
        punchSkipJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchSkipJsonStr = nil;
    }
    
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"INSERT INTO t_task (name, appScheme, reminderDays, addDate, reminderTime, punchDateArr, image, link, endDate, memo, type, punchMemoArr, punchSkipArr) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);",
            task.name,
            schemeJsonStr,
            daysJsonStr,
            task.addDate,
            task.reminderTime,
            punchJsonStr,
            task.image,
            task.link,
            task.endDate,
            task.memo,
            @(task.type),
            punchMemoJsonStr,
            punchSkipJsonStr
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
    
    NSArray *punchMemoArr = task.punchMemoArr;
    NSString *punchMemoJsonStr;
    if([punchMemoArr count] > 0 || punchMemoArr != NULL){
        NSData *punchMemoJsonData = [NSJSONSerialization dataWithJSONObject:punchMemoArr options:NSJSONWritingPrettyPrinted error:&err];
        punchMemoJsonStr = [[NSString alloc] initWithData:punchMemoJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchMemoJsonStr = nil;
    }
    
    NSArray *punchSkipArr = task.punchSkipArr;
    NSString *punchSkipJsonStr;
    if([punchSkipArr count] > 0 || punchSkipArr != NULL){
        NSData *punchSkipJsonData = [NSJSONSerialization dataWithJSONObject:punchSkipArr options:NSJSONWritingPrettyPrinted error:&err];
        punchSkipJsonStr = [[NSString alloc] initWithData:punchSkipJsonData encoding:NSUTF8StringEncoding];
    }else{
        punchSkipJsonStr = nil;
    }
    
    if(task.reminderTime != nil){
        [UNManager deleteLocalizedUserNotification:task];
        [UNManager createLocalizedUserNotification:task];
    }
    
    return [[[DBManager shareInstance] getDB] executeUpdate:
            @"UPDATE t_task SET name = ?, appScheme = ?, reminderDays = ?, addDate = ?, reminderTime = ?, punchDateArr = ?, image = ?, link = ?, endDate = ?, memo = ?, type = ?, punchMemoArr = ?, punchSkipArr = ? WHERE id = ?;",
            task.name,
            schemeJsonStr,
            daysJsonStr,
            task.addDate,
            task.reminderTime,
            punchJsonStr,
            task.image,
            task.link,
            task.endDate,
            task.memo,
            @(task.type),
            punchMemoJsonStr,
            punchSkipJsonStr,
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

#pragma mark - Load/Get Tasks

- (void)loadTask{
    [self.taskArr removeAllObjects];
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task;"];
    while ([resultSet next]){
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
        
        NSString *punchMemoJsonStr = [resultSet stringForColumn:@"punchMemoArr"];
        if(punchMemoJsonStr != NULL){
            NSData *punchData = [punchMemoJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchMemoArr = punchArr;
        }
        
        NSString *punchSkipJsonStr = [resultSet stringForColumn:@"punchSkipArr"];
        if(punchSkipJsonStr != NULL){
            NSData *punchData = [punchSkipJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchSkipArr = punchArr;
        }
        
        t.addDate = [resultSet dateForColumn:@"addDate"];
        t.reminderTime = [resultSet dateForColumn:@"reminderTime"];
        t.image = [resultSet dataForColumn:@"image"];
        t.link = [resultSet stringForColumn:@"link"];
        t.endDate = [resultSet dateForColumn:@"endDate"];
        t.memo = [resultSet stringForColumn:@"memo"];
        t.type = [resultSet intForColumn:@"type"];
        
        [self.taskArr addObject:t];
    }
}

- (NSMutableArray *)getTasks{
    [self loadTask];
    
    [[KPWatchManager shareInstance] transformTasksToWatchWithTasks:self.taskArr];
    
    return self.taskArr;
}

- (Task *)getTasksOfID:(int)id{
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task where id = ?;", @(id)];
    while ([resultSet next]){
        
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
        
        NSString *punchMemoJsonStr = [resultSet stringForColumn:@"punchMemoArr"];
        if(punchMemoJsonStr != NULL){
            NSData *punchData = [punchMemoJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchMemoArr = punchArr;
        }
        
        NSString *punchSkipJsonStr = [resultSet stringForColumn:@"punchSkipArr"];
        if(punchSkipJsonStr != NULL){
            NSData *punchData = [punchSkipJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchSkipArr = punchArr;
        }
        
        t.addDate = [resultSet dateForColumn:@"addDate"];
        t.reminderTime = [resultSet dateForColumn:@"reminderTime"];
        t.image = [resultSet dataForColumn:@"image"];
        t.link = [resultSet stringForColumn:@"link"];
        t.endDate = [resultSet dateForColumn:@"endDate"];
        t.memo = [resultSet stringForColumn:@"memo"];
        t.type = [resultSet intForColumn:@"type"];
        
        return t;
    }
    
    return NULL;
}

- (NSMutableArray *)getTasksOfDate:(NSDate *)date{
    NSMutableArray *taskArr = [[NSMutableArray alloc] init];
    for (Task *task in [self getTasks]) {
        if([task.reminderDays containsObject:[NSNumber numberWithInt:(int)date.weekday]]
           && [task.addDate isEarlierThanOrEqualTo:date] && (task.endDate == NULL ? TRUE : [task.endDate isLaterThanOrEqualTo:date])){
            [taskArr addObject:task];
        }
    }
    return taskArr;
}

- (NSMutableArray *)getTasksOfWeekdays:(NSArray *)weekdays{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.reminderDays in %@", weekdays];
    return [NSMutableArray arrayWithArray:[[self getTasks] filteredArrayUsingPredicate:predicate]];
}

#pragma mark - Count Numbers

- (int)totalPunchNumberOfTask:(Task *)task{
    NSDate *date = task.addDate;
    NSArray *weekDays = task.reminderDays;
    int count = 0;
    
    NSDate *realEndDate = (task.endDate == NULL ? [NSDate date] : ([task.endDate isLaterThan:[NSDate date]] ? [NSDate date] : task.endDate));
        
    while ([[DateUtil transformDate:date] intValue] < [[DateUtil transformDate:[realEndDate dateByAddingDays:1]]  intValue]) {
        if([weekDays containsObject:@(date.weekday)]){
            count++;
        }
        date = [date dateByAddingDays:1];
    }
    return count;
}

- (int)punchNumberOfTask:(Task *)task{
    int count = 0;
    for(NSString *str in task.punchDateArr){
        if(str.intValue >= [[DateUtil transformDate:task.addDate] intValue]
           && (task.endDate == NULL ? TRUE : str.intValue <= [[DateUtil transformDate:task.endDate] intValue])){
            count++;
        }
    }
    return count;
}

- (int)punchSkipNumberOfTask:(Task *)task{
    int count = 0;
    for(NSString *str in task.punchSkipArr){
        if(str.intValue >= [[DateUtil transformDate:task.addDate] intValue]
           && (task.endDate == NULL ? TRUE : str.intValue <= [[DateUtil transformDate:task.endDate] intValue])){
            count++;
        }
    }
    return count;
}

#pragma mark - Actions

- (BOOL)punchForTaskWithID:(NSNumber *)taskid onDate:(NSDate *)date{
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task where id = ?;", taskid];
    while([resultSet next]){
        
        //如果跳过的数组有，那就移除
        NSString *skipJsonStr = [resultSet stringForColumn:@"punchSkipArr"];
        if(skipJsonStr != NULL){
            NSData *punchData = [skipJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *skipArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            NSMutableArray *tempSkipArr = [NSMutableArray arrayWithArray:skipArr];
            
            if(tempSkipArr != NULL || tempSkipArr.count > 0){
            
                if([tempSkipArr containsObject:[DateUtil transformDate:date]]){
                    [tempSkipArr removeObject:[DateUtil transformDate:date]];
                }
            
                if([tempSkipArr count] > 0 || tempSkipArr != NULL){
                    NSData *punchSkipJsonData = [NSJSONSerialization dataWithJSONObject:tempSkipArr options:NSJSONWritingPrettyPrinted error:nil];
                    skipJsonStr = [[NSString alloc] initWithData:punchSkipJsonData encoding:NSUTF8StringEncoding];
                }else{
                    skipJsonStr = nil;
                }
   
            }
        }
        
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *punchArr = [[NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
            
            if([punchArr count] <= 0){
                punchArr = [[NSMutableArray alloc] init];
            }
            
            if(![punchArr containsObject:[DateUtil transformDate:date]]){
                [punchArr addObject:[DateUtil transformDate:date]];
            }
            
            NSError *err = nil;
            NSString *punchJsonStr;
            if([punchArr count] > 0 || punchArr != NULL){
                NSData *punchJsonData = [NSJSONSerialization dataWithJSONObject:punchArr options:NSJSONWritingPrettyPrinted error:&err];
                punchJsonStr = [[NSString alloc] initWithData:punchJsonData encoding:NSUTF8StringEncoding];
            }else{
                punchJsonStr = nil;
            }
            
            NSLog(@"punch %@", taskid);
            
            return [[[DBManager shareInstance] getDB] executeUpdate:@"update t_task set punchDateArr = ?, punchSkipArr = ? where id = ?;", punchJsonStr, skipJsonStr, taskid];
        }
    }
    return NO;
}

- (BOOL)unpunchForTaskWithID:(NSNumber *)taskid onDate:(NSDate *)date{
    FMResultSet *resultSet = [[[DBManager shareInstance] getDB] executeQuery:@"select * from t_task where id = ?;", taskid];
    while([resultSet next]){
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableArray *punchArr = [[NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil] mutableCopy];
            
            if([punchArr count] <= 0){
                punchArr = [[NSMutableArray alloc] init];
            }
            
            if([punchArr containsObject:[DateUtil transformDate:date]]){
                [punchArr removeObject:[DateUtil transformDate:date]];
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

- (NSString *)getPunchMemoOfTask:(Task *)task onDate:(NSDate *)date{
    NSArray *memoArr = task.punchMemoArr;
    if(memoArr.count == 0){
        return @"";
    }
    for(NSDictionary *dict in memoArr){
        if([dict.allKeys[0] isEqualToString:[DateUtil transformDate:date]]){
            return dict.allValues[0];
        }
    }
    return @"";
}

- (BOOL)modifyMemoForTask:(Task *)task withMemo:(NSString *)memo onDate:(NSDate *)date{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:task.punchMemoArr];
    for(NSDictionary *dict in arr){
        if([dict.allKeys[0] isEqualToString:[DateUtil transformDate:date]]){
            [arr removeObject:dict];
            break;
        }
    }
    [arr addObject:@{[DateUtil transformDate:date] : memo}];
    [task setPunchMemoArr:arr];
    return [self updateTask:task];
}

- (BOOL)skipForTask:(Task *)task onDate:(NSDate *)date{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:task.punchSkipArr];
    if(arr == NULL){
        arr = [[NSMutableArray alloc] init];
    }
    if(![arr containsObject:[DateUtil transformDate:date]]){
        [arr addObject:[DateUtil transformDate:date]];
    }
    [task setPunchSkipArr:arr];
    return [self updateTask:task];
}

- (BOOL)unskipForTask:(Task *)task onDate:(NSDate *)date{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:task.punchSkipArr];
    if(arr == NULL){
        arr = [[NSMutableArray alloc] init];
    }
    if([arr containsObject:[DateUtil transformDate:date]]){
        [arr removeObject:[DateUtil transformDate:date]];
    }
    [task setPunchSkipArr:arr];
    return [self updateTask:task];
}

@end
