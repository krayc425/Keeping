//
//  KPReminderViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReminderDelegate <NSObject>

/**
 此方为必须实现的协议方法，用来传值
 */
- (void)passTime:(NSDate *_Nonnull)date;

@end

@interface KPReminderViewController : UIViewController

@property (nonatomic, nonnull) id<ReminderDelegate> delegate;

@end
