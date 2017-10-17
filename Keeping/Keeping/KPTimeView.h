//
//  KPTimeView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/3/28.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPTimeView : UIView

- (void)setTime:(NSDate *_Nullable)date;

@property (weak, nonatomic, nullable) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *minuteLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *colonLabel;

- (void)setFont;

@end
