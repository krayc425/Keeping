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
    return [UIColor colorWithRed:76.0/255.0 green:134.0/255.0 blue:201.0/255.0 alpha:1.0];
}

+ (NSArray *)getFontSizeArr{
    return @[
             @(15),
             @(17),
             @(20)
             ];
}

+ (NSString *)getAPPID{
    return @"1197272196";
}

//多个排序条件用|分割，到那边再 split
+ (NSDictionary *)getTaskSortArr{
    return @{
             NSLocalizedString(@"Task name", nil) : @"sortName",
             NSLocalizedString(@"Start date", nil) : @"addDate",
             NSLocalizedString(@"Reminder time", nil) : @"reminderTime.hour|reminderTime.minute",
             NSLocalizedString(@"End date", nil) : @"endDate",
             NSLocalizedString(@"Progress", nil) : @"progress"
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

+ (NSString *)getAnimationType{
    return @"fade";
}

@end
