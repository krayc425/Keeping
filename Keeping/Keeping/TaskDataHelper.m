//
//  TaskDataHelper.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TaskDataHelper.h"

@implementation TaskDataHelper

+ (NSArray *)sortTasks:(NSArray *)tasks withSortFactor:(NSString *)factor isAscend:(BOOL)isAscend{
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for(NSString *str in [factor componentsSeparatedByString:@"|"]){
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:str ascending:isAscend];
        [sortDescriptors addObject:sortDescriptor];
    }
    return [NSMutableArray arrayWithArray:[tasks sortedArrayUsingDescriptors:sortDescriptors]];
}

+ (NSArray *)filtrateTasks:(NSArray *)tasks withType:(int)typeNum{
    if(typeNum <= 0){
        return tasks;
    }else{
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF.type == %d", typeNum];
        return [NSMutableArray arrayWithArray:[tasks filteredArrayUsingPredicate:predicate2]];
    }
}

+ (NSArray *)filtrateTasks:(NSArray *)tasks withString:(NSString *)str{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS %@", str];
    return [NSMutableArray arrayWithArray:[tasks filteredArrayUsingPredicate:predicate]];
}

@end
