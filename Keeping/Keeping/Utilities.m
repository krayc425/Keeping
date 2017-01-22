//
//  Utilities.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "Utilities.h"
#import "DateTools.h"

@implementation Utilities

+ (UIColor *)getColor{
    return [UIColor colorWithRed:59.0/255.0 green:134.0/255.0 blue:207.0/255.0 alpha:1.0];
}

+ (NSString *)getFont{
    return @"FZSSJW--GB1-0";
}

+ (NSString *)getAPPID{
    return @"1197272196";
}

+ (NSDictionary *)getTaskSortArr{
    return @{
             @"任务名" : @"name",
             @"添加日期" : @"addDate",
             @"提醒时间" : @"reminderTime"
             };
}

@end
