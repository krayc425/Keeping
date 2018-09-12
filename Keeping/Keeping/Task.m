//
//  Task.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "Task.h"
#import "TaskManager.h"
#import "DateUtil.h"

@implementation Task

- (float)progress{
    float totaldays = (float)[self totalDays];
    float progress = (float)[self punchDays] / totaldays;
    return totaldays == 0.0 ? 0.0 : progress;
}

- (NSUInteger)totalDays{
    return [[TaskManager shareInstance] totalPunchNumberOfTask:self] - [[TaskManager shareInstance] punchSkipNumberOfTask:self];
}

- (NSUInteger)punchDays{
    return [[TaskManager shareInstance] punchNumberOfTask:self];
}

- (NSString *)sortName{
    return [self.name stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

- (BOOL)hasMoreInfo{
    return self.image != NULL || (self.memo != NULL && ![self.memo isEqualToString:@""])
    || (self.link != NULL && ![self.link isEqualToString:@""]) || self.appScheme != NULL;
}

- (BOOL)hasPunchedOnDate:(NSDate *)date {
    return [self.punchDateArr containsObject:[DateUtil transformDate:date]];
}

@end
