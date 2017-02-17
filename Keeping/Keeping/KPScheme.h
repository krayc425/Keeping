//
//  KPScheme.h
//  Keeping
//
//  Created by 宋 奎熹 on 2017/2/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface KPScheme : NSObject

@property (nonnull, nonatomic) NSString *name;
@property (nonnull, nonatomic) NSString *scheme;
@property (nonnull, nonatomic) AVFile *iconFile;

@end
