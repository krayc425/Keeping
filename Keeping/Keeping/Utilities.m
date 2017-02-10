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
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"font"];
}

+ (NSArray *)getFontArr{
    return @[
             @{@"黑体" : @"STHeitiSC-Light"},
             @{@"苹方" : @"PingFangSC-Regular"},
             @{@"方正书宋" : @"FZSSJW--GB1-0"},
             @{@"方正楷体" : @"FZKTJW--GB1-0"},
             ];
}

+ (NSString *)getAPPID{
    return @"1197272196";
}

//多个排序条件用|分割，到那边再 split
+ (NSDictionary *)getTaskSortArr{
    return @{
             @"开始日期" : @"addDate",
             @"提醒时间" : @"reminderTime.hour|reminderTime.minute",
             @"结束日期" : @"endDate",
             @"完成率" : @"progress"
             };
}

+ (NSArray *)getTypeColorArr{
    return @[
             [UIColor colorWithRed:252.0/255.0 green:99.0/255.0 blue:96.0/255.0 alpha:1.0],
             [UIColor colorWithRed:247.0/255.0 green:165.0/255.0 blue:80.0/255.0 alpha:1.0],
             [UIColor colorWithRed:243.0/255.0 green:205.0/255.0 blue:86.0/255.0 alpha:1.0],
             [UIColor colorWithRed:112.0/255.0 green:202.0/255.0 blue:87.0/255.0 alpha:1.0],
             [UIColor colorWithRed:81.0/255.0 green:185.0/255.0 blue:214.0/255.0 alpha:1.0],
             [UIColor colorWithRed:207.0/255.0 green:139.0/255.0 blue:223.0/255.0 alpha:1.0],
             [UIColor colorWithRed:164.0/255.0 green:164.0/255.0 blue:167.0/255.0 alpha:1.0],
             ];
}

@end
