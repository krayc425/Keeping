//
//  KPSchemeManager.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPSchemeManager : NSObject

+ (_Nonnull instancetype)shareInstance;

- (void)getSchemes;
- (NSArray *_Nonnull)getSchemeArr;

@end
