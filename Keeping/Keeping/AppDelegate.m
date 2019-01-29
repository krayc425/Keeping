//
//  AppDelegate.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "AppDelegate.h"
#import "DBManager.h"
#import "TaskManager.h"
#import "KPNavigationViewController.h"
#import "KPTabBarViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UNManager.h"
#import "AppKeys.h"
#import "KPSchemeManager.h"
#import "IQKeyboardManager.h"
#import "Utilities.h"
@import CoreSpotlight;
#import "CoreSpotlightHelper.h"
@import Bugly;

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //键盘
    [[IQKeyboardManager sharedManager] setToolbarTintColor:[Utilities getColor]];
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:NSLocalizedString(@"Done", nil)];
    
    // Bugly
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.applicationGroupIdentifier = GROUP_ID;
    [Bugly startWithAppId:buglyKey config:config];
    
    //先删除所有通知
    [UNManager reconstructNotifications];
    
    [self replyPushNotificationAuthorization:application];
    [self registerForRemoteNotification];

    [AVOSCloud setApplicationId:avCloudID clientKey:avCloudKey];
    [AVOSCloud setAllLogsEnabled:NO];
    [AVOSCloud setLogLevel:AVLogLevelWarning | AVLogLevelError];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //第一次启动
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"animation"];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"fontSize"];
    }
    if([[NSUserDefaults standardUserDefaults] valueForKey:@"sort"] == NULL){
        [[NSUserDefaults standardUserDefaults] setValue:@{@"sortName" : @true} forKey:@"sort"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //下载 schemes
    NSArray *r = [[KPSchemeManager shareInstance] getSchemeArr];
    
    NSLog(@"%lu apps", (unsigned long)r.count);
    
    //启动数据库
    [DBManager shareInstance];
    [[CoreSpotlightHelper shareInstance] createCoreSpotlightIndexes];
    
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
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"badgeCount"]) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"refreshToday"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh_today_task_and_date" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    //关闭数据库
    [[DBManager shareInstance] closeDB];
}

// iOS 12 API
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {

    NSString *wordID = userActivity.userInfo[CSSearchableItemActivityIdentifier];
    Task *task = [[TaskManager shareInstance] getTasksOfID:[wordID intValue]];
    
    UINavigationController *naviVC = (UINavigationController *)self.window.rootViewController;
    UITabBarController *tabVC = (UITabBarController *)naviVC.viewControllers[0];
    [tabVC setSelectedIndex:1];

    KPTaskTableViewController *taskVC = (KPTaskTableViewController *)tabVC.selectedViewController;
    [taskVC performSegueWithIdentifier:@"detailTaskSegue" sender:task];
    
    return YES;
}

#pragma mark - 申请通知权限

- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //必须写代理，不然无法监听通知的接收与点击事件
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error && granted) {
            NSLog(@"注册通知成功");
        }else{
            NSLog(@"注册通知失败 %@", error.description);
        }
    }];
    
    //可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
    //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"========%@",settings);
    }];
}

/**
 * 初始化UNUserNotificationCenter
 */
- (void)registerForRemoteNotification {
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter *uncenter = [UNUserNotificationCenter currentNotificationCenter];
    // 监听回调事件
    [uncenter setDelegate:self];
    //iOS10 使用以下方法注册，才能得到授权
    [uncenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound)
                            completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                dispatch_queue_t queue = dispatch_get_main_queue();
                                dispatch_async(queue, ^{
                                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                                    //TODO:授权状态改变
                                    NSLog(@"%@" , granted ? @"授权成功" : @"授权失败");
                                });
                            }];
    // 获取当前的通知授权状态, UNNotificationSettings
    [uncenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
            NSLog(@"未选择");
        } else if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
            NSLog(@"未授权");
        } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"已授权");
        }
    }];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
}

#pragma mark - iOS10 收到通知（本地和远端） UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    //收到推送的内容
    UNNotificationContent *content = request.content;
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    NSInteger notibadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    notibadge--;//读了一个，所以减1
    notibadge = notibadge >= 0 ? : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = notibadge;
    
    NSString *categoryIdentifier = content.categoryIdentifier;
    //识别需要被处理的拓展
    if ([categoryIdentifier isEqualToString:@"taskLocalCategory"]) {
        //识别用户点击的是哪个 action
        if ([response.actionIdentifier isEqualToString:@"action.done"]) {
            //打卡
            [[TaskManager shareInstance] punchForTaskWithID:(NSNumber *)userInfo[@"taskid"] onDate:[NSDate date]];
        }
    }
    
    if (![userInfo[@"taskapp"] isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:userInfo[@"taskapp"]] options:@{} completionHandler:nil];
    }
    
    completionHandler(); // 系统要求执行这个方法, 不然报错
}

#pragma mark - 3D Touch

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler{
    if([shortcutItem.type isEqualToString:@"newTask"]){
        KPNavigationViewController *naviVC = (KPNavigationViewController *)self.window.rootViewController;
        KPTabBarViewController *tabBarC = (KPTabBarViewController *)naviVC.viewControllers[0];
        [tabBarC performSegueWithIdentifier:@"addTaskSegue" sender:nil];
    }
}

#pragma mark - Login

// For application on system equals or larger ios 9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    return NO;
//    return [AVOSCloudSNS handleOpenURL:url];
}

@end
