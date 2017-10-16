//
//  DateUtil.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

+ (NSString *)getWeekdayStr:(int)i;

+ (NSString *)transformDate:(NSDate *)date;

+ (NSString *)getDateStringOfDate:(NSDate *)date;

+ (NSString *)getTodayDateStringOfDate:(NSDate *)date;

@end
