//
//  TaskDataHelper.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskDataHelper : NSObject

+ (NSArray *)sortTasks:(NSArray *)tasks withSortFactor:(NSString *)factor isAscend:(BOOL)isAscend;

+ (NSArray *)filtrateTasks:(NSArray *)tasks withType:(int)typeNum;

+ (NSArray *)filtrateTasks:(NSArray *)tasks withString:(NSString *)str;

@end
