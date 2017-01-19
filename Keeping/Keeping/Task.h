//
//  Task.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic) int id;
//任务名
@property (nonatomic, nonnull) NSString *name;
//跳转 app 的 scheme
@property (nonatomic, nonnull) NSDictionary *appScheme;
//提醒的日子（星期 x）
@property (nonatomic, nonnull) NSArray *reminderDays;
//创建日期
@property (nonatomic, nonnull) NSDate *addDate;
//提醒时间
@property (nonatomic, nonnull) NSDate *reminderTime;
//打卡日期数组
@property (nonatomic, nonnull) NSArray *punchDateArr;

@end
