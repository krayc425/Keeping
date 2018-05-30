//
//  KPProgressLabel.h
//  Keeping
//
//  Created by 宋 奎熹 on 2018/5/30.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPProgressLabel : UILabel

- (void)setProgressWithFinished:(NSUInteger)finished andTotal:(NSUInteger)total;

@end
