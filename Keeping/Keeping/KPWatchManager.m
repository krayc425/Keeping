//
//  KPWatchManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/10/22.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPWatchManager.h"
#import "TaskManager.h"
#import "Task.h"

@implementation KPWatchManager

static KPWatchManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [KPWatchManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        if([WCSession isSupported]){
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        }
    }
    return self;
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [KPWatchManager shareInstance] ;
}

- (void)transformTasksToWatchWithTasks:(NSArray<Task *> *)tasks {
    WCSession *session = [WCSession defaultSession];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (Task *t in tasks) {
        [dict setObject:@{
                          @"name": t.name,
                          @"hasPunched": [t hasPunchedOnDate:[NSDate date]] ? @"1" : @"0",
                          @"reminderDays": t.reminderDays
                          }
                 forKey:@(t.id)];
    }
    
    NSLog(@"%@", dict);
    
    [session transferUserInfo:dict];
}

#pragma mark - WCSession Delegate

- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}

- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
    
}

- (void)sessionDidDeactivate:(nonnull WCSession *)session {
    
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    if (userInfo.allKeys.count > 0 && userInfo.allValues.count > 0) {
        NSLog(@"Received %@ %@", userInfo.allKeys[0], userInfo.allValues[0]);
        
        NSInteger taskid = [[userInfo objectForKey:@"taskId"] integerValue];
        BOOL hasPunched = [[userInfo objectForKey:@"hasPunched"] integerValue] == 1;
        if (hasPunched) {
            [[TaskManager shareInstance] punchForTaskWithID:@(taskid) onDate:[NSDate date]];
        } else {
            [[TaskManager shareInstance] unpunchForTaskWithID:@(taskid) onDate:[NSDate date]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_today_task" object:nil];
        });
    }
}

@end
