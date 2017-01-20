//
//  TaskManager.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskManager : NSObject

@property (nonnull, nonatomic) NSMutableArray *taskArr;

+ (_Nonnull instancetype)shareInstance;
- (BOOL)addTask:(Task *_Nonnull)task;
- (BOOL)deleteTask:(int)id;
- (NSMutableArray *_Nonnull)getTasks;
- (NSMutableArray *_Nonnull)getTodayTasks;
- (NSMutableArray *_Nonnull)getTasksOfDate:(NSDate *_Nonnull)date;
- (BOOL)punchForTask:(Task *_Nonnull)task;

- (int)totalPunchNumberOfTask:(Task *_Nonnull)task;

@end
