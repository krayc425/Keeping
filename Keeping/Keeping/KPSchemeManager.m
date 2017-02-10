//
//  KPSchemeManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeManager.h"
#import <AVOSCloud/AVOSCloud.h>

#define GB18030_ENCODING CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

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
        [self getSchemes];
    }
    return self;
}

- (void)getSchemes{
    schemes = [[NSMutableArray alloc] init];
    AVQuery *query = [AVQuery queryWithClassName:@"AppScheme"];
    for(AVObject *object in [query findObjects]){
        [schemes addObject:[NSDictionary dictionaryWithObject:object[@"scheme"] forKey:object[@"name"]]];
    }
}

- (NSArray *)getSchemeArr{
    return [schemes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSString *number1 = [[[obj1 allKeys] objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:GB18030_ENCODING];
        NSString *number2 = [[[obj2 allKeys] objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:GB18030_ENCODING];;
        
        NSComparisonResult result = [number1 compare:number2];
        
        return result == NSOrderedDescending; // 升序
    }];
}

@end
