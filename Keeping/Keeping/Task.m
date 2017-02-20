//
//  Task.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "Task.h"
#import "TaskManager.h"

#define GB18030_ENCODING CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

@implementation Task

- (float)progress{
    return (float)[self.punchDateArr count] / [[TaskManager shareInstance] totalPunchNumberOfTask:self];
}

- (NSString *)sortName{
//    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
//    return [self.name stringByAddingPercentEncodingWithAllowedCharacters:set];
    return [self.name stringByAddingPercentEscapesUsingEncoding:GB18030_ENCODING];
}

@end
