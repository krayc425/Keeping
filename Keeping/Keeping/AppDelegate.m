//
//  AppDelegate.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"
#import "KPSchemeManager.h"
#import "TaskManager.h"
#import "KPNavigationViewController.h"
#import "KPTabBarViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UNManager.h"
#import "YFStartView.h"
#import "StartButtomView.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define IOS10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IOS9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IOS8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IOS7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define GROUP_ID @"group.com.krayc.keeping"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //先删除所有通知
    [UNManager reconstructNotifications];
    
    [self replyPushNotificationAuthorization:application];
    
    //LeanCloud
    [AVOSCloud setApplicationId:@"sabdEOhaMdwIEc2zbKRBQk56-gzGzoHsz" clientKey:@"byONReV9r125hlRuN1mAvv9I"];
    [AVOSCloud setAllLogsEnabled:NO];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    
    //第一次启动
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"font"] isEqualToString:@""]
       || [[NSUserDefaults standardUserDefaults] valueForKey:@"font"] == NULL){
        [[NSUserDefaults standardUserDefaults] setValue:@"STHeitiSC-Light" forKey:@"font"];
    }
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:GROUP_ID];
    if([shared valueForKey:@"fontwidget"] == NULL
       || [[shared valueForKey:@"fontwidget"] isEqualToString:@""]){
        [shared setValue:@"STHeitiSC-Light" forKey:@"fontwidget"];
        [shared synchronize];
    }

    
    //启动动画
    YFStartView *startView = [YFStartView startView];
    startView.isAllowRandomImage = YES;
    startView.randomImages = [NSMutableArray arrayWithObjects:@"Intro_Screen_Four", @"Intro_Screen_Three", @"Intro_Screen_Two", @"Intro_Screen_One", nil];
    
    //LogoPositionCenter & UIView
    startView.logoPosition = LogoPositionButtom;
    StartButtomView *startButtomView = [[[NSBundle mainBundle] loadNibNamed:@"StartButtomView" owner:self options:nil] lastObject];
    startView.logoView = startButtomView;
    
    [startView configYFStartView];
    
    //下载 schemes
    NSArray *r = [[KPSchemeManager shareInstance] getSchemeArr];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    //关闭数据库
    [[DBManager shareInstance] closeDB];
    
    [self saveContext];
}

#pragma mark - 申请通知权限
// 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    
    if (IOS10_OR_LATER) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"注册通知成功");
            }else{
                //用户点击不允许
                NSLog(@"注册通知失败");
            }
        }];
        
        //可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//            NSLog(@"========%@",settings);
        }];
    }else if (IOS8_OR_LATER){
      //iOS 8 - iOS 10系统
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
        
    }
}

#pragma mark - iOS10 收到通知（本地和远端） UNUserNotificationCenterDelegate

//App处于前台接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    //收到推送消息body
    NSString *body = content.body;
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    // 推送消息的标题
    NSString *title = content.title;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
}

//App通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    //收到推送消息body
    NSString *body = content.body;
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    // 推送消息的标题
    NSString *title = content.title;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    NSInteger notibadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    notibadge--;//读了一个，所以减1
    notibadge = notibadge >= 0 ? notibadge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = notibadge;
    
    NSString *categoryIdentifier = response.notification.request.content.categoryIdentifier;
    //识别需要被处理的拓展
    if ([categoryIdentifier isEqualToString:@"taskLocalCategory"]) {
        //识别用户点击的是哪个 action
        if ([response.actionIdentifier isEqualToString:@"action.done"]) {
            //打卡
            [[TaskManager shareInstance] punchForTaskWithID:(NSNumber *)[userInfo valueForKey:@"taskid"] onDate:[NSDate date]];
        }
    }
    
    if(![[userInfo objectForKey:@"taskapp"] isEqual: @{}]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[userInfo objectForKey:@"taskapp"] allValues][0]] options:@{} completionHandler:nil];
    }
    
    completionHandler(); // 系统要求执行这个方法, 不然报错
}

#pragma mark - 3D Touch

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    if([shortcutItem.type isEqualToString:@"newTask"]){
        KPNavigationViewController *naviVC = (KPNavigationViewController *)self.window.rootViewController;
        KPTabBarViewController *tabBarC = (KPTabBarViewController *)[naviVC.viewControllers objectAtIndex:0];
        [[tabBarC.viewControllers objectAtIndex:1] performSegueWithIdentifier:@"addTaskSegue" sender:nil];
    }
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Keeping"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
