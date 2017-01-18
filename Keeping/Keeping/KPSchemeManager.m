//
//  KPSchemeManager.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSchemeManager.h"

@implementation KPSchemeManager

+ (NSArray *)getSchemeArr{
    return @[
             @{@"微博" : @"sinaweibo://"},
             @{@"微信" : @"weixin://"},
             @{@"QQ"  : @"mqq://"},
             @{@"淘宝" : @"taobao://"},
             @{@"支付宝" : @"alipay://"},
             @{@"weico微博" : @"weico://"},
             @{@"QQ 浏览器" : @"mqqbrowser://"},
             @{@"UC 浏览器" : @"ucbrowser://"},
             @{@"百度地图" : @"baidumap://"},
             @{@"Chrome" : @"googlechrome://"},
             @{@"优酷" : @"youku://"},
             @{@"京东" : @"openapp.jdmoble://"},
             @{@"美团" : @"imeituan://"},
             @{@"1号店" : @"wccbyihaodian://"},
             @{@"有道词典" : @"yddictproapp://"},
             @{@"知乎" : @"zhihu://"},
             @{@"微盘" : @"sinavdisk://"},
             @{@"豆瓣 FM" : @"doubanradio://"},
             @{@"网易公开课" : @"ntesopen://"},
             @{@"名片全能王" : @"camcard://"},
             @{@"Safari" : @"http://"},
             ];
}

@end
