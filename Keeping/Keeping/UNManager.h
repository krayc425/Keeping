//
//  UNManager.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/20.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface UNManager : NSObject

+ (void)createLocalizedUserNotification:(Task *)task;
+ (void)deleteLocalizedUserNotification:(Task *)task;
+ (void)printNumberOfNotifications;
+ (void)reconstructNotifications;

@end
