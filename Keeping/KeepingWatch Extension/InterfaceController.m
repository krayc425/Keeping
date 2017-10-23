//
//  InterfaceController.m
//  KeepingWatch Extension
//
//  Created by 宋 奎熹 on 2017/10/19.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "InterfaceController.h"
#import "KPWatchTableRowController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "DateUtil.h"

@interface InterfaceController () <WCSessionDelegate>

@property (nonatomic, nonnull) NSMutableDictionary *taskDict;
@property (nonatomic, nonnull) NSMutableArray *taskIdArray;
@property (nonatomic, nonnull) NSMutableArray *taskNameArray;
@property (nonatomic, nonnull) NSMutableArray *taskStatusArray;
@property (nonatomic, nonnull) NSMutableArray *taskReminderDaysArray;

@property (nonatomic, nonnull) NSMutableArray *todayTaskIndexes;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        [self reloadTableData];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)changeStatusForTaskAtIndex:(NSInteger)index {
    [self.taskDict setObject:@{
                               @"name": self.taskNameArray[[self.todayTaskIndexes[index] integerValue]],
                               @"hasPunched": [self.taskStatusArray[[self.todayTaskIndexes[index] integerValue]] isEqualToString:@"1"] ? @"0" : @"1",
                               @"reminderDays": self.taskReminderDaysArray[[self.todayTaskIndexes[index] integerValue]]
                               }
                      forKey:self.taskIdArray[[self.todayTaskIndexes[index] integerValue]]];
    
    NSDictionary *sendDict = @{
                               @"taskId": self.taskIdArray[[self.todayTaskIndexes[index] integerValue]],
                               @"hasPunched": [self.taskStatusArray[[self.todayTaskIndexes[index] integerValue]] isEqualToString:@"1"] ? @"0" : @"1"
                               };
    
    NSLog(@"%@", sendDict);
    
    [[WCSession defaultSession] transferUserInfo:sendDict];
    
    [self reloadTableData];
}

#pragma mark - Table Methods

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    [self changeStatusForTaskAtIndex:rowIndex];
}

- (void)reloadTableData {
    NSData *dictData = [[NSUserDefaults standardUserDefaults] objectForKey:@"watch_task_dict_data"];
    
    NSDictionary *storedDict = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:dictData];
    
    self.taskDict = [NSMutableDictionary dictionaryWithDictionary:storedDict];
//    NSLog(@"%@", self.taskDict);
    
    self.taskNameArray = [[NSMutableArray alloc] init];
    self.taskStatusArray = [[NSMutableArray alloc] init];
    self.taskIdArray = [[NSMutableArray alloc] init];
    self.taskReminderDaysArray = [[NSMutableArray alloc] init];
    
    self.todayTaskIndexes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.taskDict.count; i++) {
        NSString *taskId = (NSString *)self.taskDict.allKeys[i];
        NSString *taskName = (NSString *)[[self.taskDict objectForKey:taskId] objectForKey:@"name"];
        NSString *hasFinished = (NSString *)[[self.taskDict objectForKey:taskId] objectForKey:@"hasPunched"];
        NSArray *taskReminderDaysArr = (NSArray *)[[self.taskDict objectForKey:taskId] objectForKey:@"reminderDays"];

        [self.taskIdArray addObject:taskId];
        [self.taskNameArray addObject:taskName];
        [self.taskStatusArray addObject:hasFinished];
        [self.taskReminderDaysArray addObject:taskReminderDaysArr];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        
        if ([taskReminderDaysArr containsObject:@(comps.weekday)]) {
            [self.todayTaskIndexes addObject:@(i)];
        }
    }
    
    NSUInteger todayTaskCount = self.todayTaskIndexes.count;
    [self.taskTable setNumberOfRows:todayTaskCount withRowType:@"KPWatchTableRowController"];

    NSUInteger hasDoneTaskCount = 0;
    for (int i = 0; i < todayTaskCount; i++) {
        KPWatchTableRowController *rowVC = [self.taskTable rowControllerAtIndex:i];
        [rowVC.taskNameLabel setText:self.taskNameArray[[self.todayTaskIndexes[i] integerValue]]];
        [rowVC.taskDoneImage setHidden:![self.taskStatusArray[[self.todayTaskIndexes[i] integerValue]] isEqualToString:@"1"]];
        if ([self.taskStatusArray[[self.todayTaskIndexes[i] integerValue]] isEqualToString:@"1"]) {
            hasDoneTaskCount++;
        }
    }
    
    [self.taskProgressLabel setText:[NSString stringWithFormat:@"%d / %d", hasDoneTaskCount, todayTaskCount]];
}

#pragma mark - WCSession Delegate

- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    if (userInfo) {
        NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
        
        [[NSUserDefaults standardUserDefaults] setObject:dictData forKey:@"watch_task_dict_data"];
        [self reloadTableData];
    }
}

- (void)sessionWatchStateDidChange:(nonnull WCSession *)session{
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

@end
