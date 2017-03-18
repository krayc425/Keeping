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
    float totaldays = ([[TaskManager shareInstance] totalPunchNumberOfTask:self] - [[TaskManager shareInstance] punchSkipNumberOfTask:self]);
    float progress = (float)[[TaskManager shareInstance] punchNumberOfTask:self] / totaldays;
    return totaldays == 0 ? 0 : progress;
}

- (NSString *)sortName{
//    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
//    return [self.name stringByAddingPercentEncodingWithAllowedCharacters:set];
    return [self.name stringByAddingPercentEscapesUsingEncoding:GB18030_ENCODING];
}

- (BOOL)hasMoreInfo{
    return self.image != NULL || (self.memo != NULL && ![self.memo isEqualToString:@""])
    || (self.link != NULL && ![self.link isEqualToString:@""]) || self.appScheme != NULL;
}

@end
