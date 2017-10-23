//
//  DateUtil.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateUtil.h"

@implementation DateUtil

+ (NSString *)getWeekdayStr:(int)i{
    switch (i) {
        case 1:
            return @"星期日";
        case 2:
            return @"星期一";
        case 3:
            return @"星期二";
        case 4:
            return @"星期三";
        case 5:
            return @"星期四";
        case 6:
            return @"星期五";
        case 7:
            return @"星期六";
        default:
            return @"";
    }
}

+ (NSString *)transformDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}

+ (NSString *)getTodayDateStringOfDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM EEEE"];
    NSString *todayDateStr = [dateFormatter stringFromDate:date];
    return todayDateStr;
}

+ (NSString *)getDateStringOfDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd EEEE"];
    NSString *todayDateStr = [dateFormatter stringFromDate:date];
    return todayDateStr;
}

@end
