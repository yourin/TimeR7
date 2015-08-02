//
//  MyLocalNotification.h
//  Stop7Watches
//
//  Created by oki on 2014/04/06.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLocalNotification : UILocalNotification
{
    
}
@property(nonatomic)NSUInteger badgeCount;
@property(nonatomic)NSMutableDictionary *myUserInfo;

+(void)setLocalNotification:(int)viewTag afterSec:(int)sec;
+(void)delLocalNotification:(int)viewTag;




@end
