//
//  Utilities.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface Utilities : NSObject

+ (UIColor *)getColor;

+ (NSArray *)getFontSizeArr;

+ (NSString *)getAPPID;

+ (NSDictionary *)getTaskSortArr;

+ (NSArray *)getTypeColorArr;

+ (NSString *)getAnimationType;

@end
