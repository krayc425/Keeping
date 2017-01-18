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

@property (nonatomic, nonnull) NSString *name;

@property (nonatomic, nonnull) NSDictionary *appScheme;

@property (nonatomic, nonnull) NSArray *reminderDays;

@end
