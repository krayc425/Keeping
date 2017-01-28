//
//  KPSchemeManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeManager.h"

@implementation KPSchemeManager

//添加完别忘了去 info.plist 也加一个

+ (NSArray *)getSchemeArr{
    return @[
             @{@"微博" : @"sinaweibo://"},
             @{@"微信" : @"weixin://"},
             @{@"QQ"  : @"mqq://"},
             @{@"淘宝" : @"taobao://"},
             @{@"支付宝" : @"alipay://"},
//             @{@"Weico 微博" : @"weico://"},
//             @{@"QQ 浏览器" : @"mqqbrowser://"},
//             @{@"UC 浏览器" : @"ucbrowser://"},
//             @{@"百度地图" : @"baidumap://"},
//             @{@"Chrome" : @"googlechrome://"},
//             @{@"优酷" : @"youku://"},
//             @{@"美团" : @"imeituan://"},
//             @{@"1号店" : @"wccbyihaodian://"},
             @{@"有道词典" : @"yddictproapp://"},
             @{@"知乎" : @"zhihu://"},
             @{@"扇贝单词" : @"shanbay://"},
             @{@"百词斩" : @"wxce5d9e837051d623://"},
             @{@"单语" : @"danyuapp://"},
//             @{@"豆瓣 FM" : @"doubanradio://"},
//             @{@"网易公开课" : @"ntesopen://"},
             @{@"Safari" : @"http://"},
             ];
}

@end
