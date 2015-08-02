//
//  AppDelegate.m
//  TimeR7
//
//  Created by 義晴井上 on 2015/07/05.
//  Copyright (c) 2015年 youringtone. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"アプリがフォアグラウンドでプッシュ通知を受け取った");
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s", __FUNCTION__);
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"アプリケーションがアクティブでなくなる直前");
    
    // ローカル通知を設定する
    
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"アプリケーションがバックグラウンドになったら呼ばれる");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"アプリケーションがバックグラウンドから復帰する直前に呼ばれる");
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"アプリケーションがアクティブになったら呼ばれる");
// バッジを消す

    //old    MyLocalNotification* notification = [MyLocalNotification new];

    UILocalNotification* notification = [UILocalNotification new];

    notification.applicationIconBadgeNumber = -1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /*
     NSLog(@"Terminated");
     
     UILocalNotification *notification = [[UILocalNotification alloc] init];
     if (notification)
     {
     notification.timeZone = [NSTimeZone defaultTimeZone];
     notification.repeatInterval = 0;
     notification.alertBody = @"The end of application＜TimeR7＞";
     notification.alertAction = @"ReStart";
     notification.soundName = UILocalNotificationDefaultSoundName;
     [[UIApplication sharedApplication] scheduleLocalNotification:notification];
     }
     */
}

//
//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
//    return YES;
//}
//
//- (void)applicationWillResignActive:(UIApplication *)application {
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//}
//
//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//}

@end
