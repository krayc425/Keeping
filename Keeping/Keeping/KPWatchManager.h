//
//  KPWatchManager.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/22.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@class Task;

@interface KPWatchManager : NSObject <WCSessionDelegate>

+ (_Nonnull instancetype)shareInstance;

- (void)transformTasksToWatchWithTasks:(NSArray<Task *> *_Nonnull)tasks;

@end
