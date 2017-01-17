//
//  KPCalViewController.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface KPCalViewController : UIViewController <FSCalendarDataSource, FSCalendarDelegate>

@property (nonnull, nonatomic) FSCalendar *calendar;

@end
