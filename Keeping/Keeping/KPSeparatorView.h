//
//  KPSeparatorView.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPSeparatorView : UIView

@property (weak, nonatomic, nullable) IBOutlet UILabel *textLabel;

- (void)setText:(NSString *_Nonnull)text;

@end
