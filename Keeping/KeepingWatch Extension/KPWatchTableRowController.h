//
//  KPWatchTableRowController.h
//  KeepingWatch Extension
//
//  Created by 宋 奎熹 on 2017/10/22.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface KPWatchTableRowController : NSObject

@property (weak, nonatomic, nullable) IBOutlet WKInterfaceLabel *taskNameLabel;
@property (weak, nonatomic, nullable) IBOutlet WKInterfaceImage *taskDoneImage;

@end
