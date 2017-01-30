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
             @{@"Safari" : @"http://"},
             @{@"微博" : @"sinaweibo://"},
             @{@"微信" : @"weixin://"},
             @{@"QQ"  : @"mqq://"},
             @{@"淘宝" : @"taobao://"},
             @{@"支付宝" : @"alipay://"},
//             @{@"QQ 浏览器" : @"mqqbrowser://"},
//             @{@"UC 浏览器" : @"ucbrowser://"},
//             @{@"百度地图" : @"baidumap://"},
//             @{@"Chrome" : @"googlechrome://"},
//             @{@"优酷" : @"youku://"},
//             @{@"美团" : @"imeituan://"},
//             @{@"1号店" : @"wccbyihaodian://"},
             @{@"知乎" : @"zhihu://"},
             @{@"有道词典" : @"yddictproapp://"},
             @{@"扇贝单词" : @"shanbay://"},
             @{@"百词斩" : @"wxce5d9e837051d623://"},
             @{@"单语" : @"danyuapp://"},
             @{@"小站托福" : @"toefl1216c2://"},
             @{@"驾考宝典" : @"jiakaobaodianxingui://"},
             @{@"万得资讯" : @"WindInfoIPhoneFree://"},
             @{@"万得股票" : @"StockMasterIPhoneFree://"},
             @{@"换手率" : @"com.huanshoulv://"},
             @{@"金太阳" : @"iGoldSun://"}
             ];
}

@end
