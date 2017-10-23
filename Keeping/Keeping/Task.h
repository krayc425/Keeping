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
//提醒的日子（星期 x）
@property (nonatomic, nonnull) NSArray *reminderDays;
//创建日期
@property (nonatomic, nonnull) NSDate *addDate;

//结束日期
@property (nonatomic, nullable) NSDate *endDate;
//跳转 app 的 scheme
@property (nonatomic, nullable) NSDictionary *appScheme;
//提醒时间
@property (nonatomic, nullable) NSDate *reminderTime;
//打卡日期数组
@property (nonatomic, nullable) NSArray *punchDateArr;
//图片
@property (nonatomic, nullable) NSData *image;
//链接
@property (nonatomic, nullable) NSString *link;
//备注
@property (nonatomic, nullable) NSString *memo;
//类别
@property (nonatomic) int type;
//打卡备注数组
@property (nonatomic, nullable) NSArray *punchMemoArr;
//跳过打卡日期数组
@property (nonatomic, nullable) NSArray *punchSkipArr;

//完成率
@property (nonatomic) float progress;
//排序的任务名
@property (nonatomic, nonnull) NSString *sortName;

//有没有更多信息
- (BOOL)hasMoreInfo;
//在 date 上有没有打过卡
- (BOOL)hasPunchedOnDate:(NSDate *_Nonnull)date;

@end
