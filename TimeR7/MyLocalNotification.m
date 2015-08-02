//
//  MyLocalNotification.m
//  Stop7Watches
//
//  Created by oki on 2014/04/06.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#import "MyLocalNotification.h"

@implementation MyLocalNotification


#pragma mark 通知削除
+(void)delLocalNotification:(int)viewTag
{
    NSLog(@"%s", __FUNCTION__);;

    
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];

    
    UILocalNotification *row = nil;
    
    
    NSString* string = [NSString stringWithFormat:@"%d",viewTag];


    
    for (row in notificationArray)
    {
        NSLog(@"row.userInfo = %@",row.userInfo);
        NSString* str = [row.userInfo objectForKey:string];
        NSLog(@"str = %@",str);

        if([[row.userInfo valueForKey:str] isEqualToString:string])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:row];
            NSLog(@"%@ 通知が削除されました。",string);
        }
    }
}


#pragma mark 通知設定

+(void)setLocalNotification:(int)viewTag afterSec:(int)sec
{
                NSLog(@"set LocalNotification");
    [self delLocalNotification:viewTag];
    NSLog(@"viewTag= %d : sec = %d",viewTag,sec);
    NSString *message = [NSString stringWithFormat:@"TimeR%d Alarm Time. The set time %dmin.",viewTag+1,(int)sec/60];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    
    NSDate *fireDate = [[NSDate alloc] initWithTimeInterval:sec sinceDate:[NSDate date]];
    // 通知の時間
    notification.fireDate = fireDate;
    NSLog(@"現在時刻＝%@",[NSDate date]);
    NSLog(@"通知時刻＝%@", fireDate);
    
    notification.timeZone = [NSTimeZone systemTimeZone];
    // 通知時に表示されるメッセージ
    notification.alertBody = message;
    // 通知時のサウンド（鳴動時間＝表示時間）
    notification.soundName = @"Notification.caf";
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    NSString* str = [NSString stringWithFormat:@"%d",viewTag];
    
    [userInfo setObject:str forKey:str];
    
    // アイコンのバッチ

    notification.applicationIconBadgeNumber = viewTag+1;
    notification.userInfo = userInfo;
    NSLog(@"%@",userInfo);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    NSLog(@"通知を設定しました");
}

@end
