# 今日打卡

## 简介

做 **今日打卡** 的初衷是在某一个寒假，突发奇想想做一个 App，关于日常打卡 + 任务管理。因为看到 App Store 上的这类 App 都是只有打卡或者只有提醒功能，就想把它们整合到一起。同时在开发的过程中，也多了一些实用的小功能，比如任务分类、可以给任务添加图片、添加链接、直接打开其他 App 等。这个 App 的第一个版本用了 10 天就完成了从设计到上架的全过程。

## 开源

由于发现 TODO 类应用实在是太多，然后自己其他的项目也变得多了起来，这个项目只好暂时搁置，所以决定开源公布，希望能给希望入门 iOS 开发的同学一些参考。当然由于我自己开发能力、知识范围都很有限，很多地方还需要修改和提高，希望大家指正。

## 下载

[🍎App Store](https://itunes.apple.com/us/app/keeping/id1197272196)

## 注意事项

* **今日打卡** 使用了 `CocoaPods` 管理第三方库，所以当你 clone 仓库到本地后，需要 `cd` 进项目目录，并打开终端，运行 `pod install`。
* **今日打卡** 发布时用了第三方统计功能，有一些比较敏感的 App ID 和 App Key，为了安全起见没有上传他们。在启动工程后，你需要在 `Utilities` 中新建一个 `AppKeys.m` 文件，并将以下内容复制进去即可。  

```C
#import "AppKeys.h"
    
@implementation AppKeys
    
NSString *const avCloudID = @"";
NSString *const avCloudKey = @"";
NSString *const buglyKey = @"";
    
@end
```
    
## 联系

若有任何问题，欢迎联系：

* 邮箱：[krayc425@gmail.com](krayc425@gmail.com)
* 微信：krayc425