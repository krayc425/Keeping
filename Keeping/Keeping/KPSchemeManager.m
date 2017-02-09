//
//  KPSchemeManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeManager.h"
#import <AVOSCloud/AVOSCloud.h>

static NSMutableArray *_Nullable schemes = nil;

@implementation KPSchemeManager

//添加完别忘了去 info.plist 也加一个

static KPSchemeManager* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [KPSchemeManager shareInstance] ;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        schemes = [[NSMutableArray alloc] init];
        [self getSchemes];
    }
    return self;
}

- (void)getSchemes{
    AVQuery *query = [AVQuery queryWithClassName:@"AppScheme"];
    for(AVObject *object in [query findObjects]){
        [schemes addObject:[NSDictionary dictionaryWithObject:object[@"scheme"] forKey:object[@"name"]]];
    }
}

- (NSArray *)getSchemeArr{
    return schemes;
}

@end
