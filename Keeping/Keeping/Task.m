//
//  Task.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "Task.h"
#import "TaskManager.h"

@implementation Task

- (float)progress{
    return (float)[self.punchDateArr count] / [[TaskManager shareInstance] totalPunchNumberOfTask:self];
}

@end
