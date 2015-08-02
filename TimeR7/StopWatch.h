//
//  StopWatch.h
//  StopWatch10
//
//  Created by oki on 2014/03/09.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopWatch : NSObject
{
    
}

@property(nonatomic)NSString    *stopWatchName;

@property(nonatomic)NSDate      *dateStart;
@property(nonatomic)NSDate      *dateStop;

@property(nonatomic)NSDate      *dateLap1;
@property(nonatomic)NSDate      *dateLap2;
@property(nonatomic)NSDate      *dateLap3;

@property(nonatomic)float       tempDateTime;
@property(nonatomic)float       dateAlartTime;
@property(nonatomic)NSUInteger  stopWatchMode;


-(NSString *)LapTime:(NSDate *)date;
+(NSString *)dateToString:(float)dateValue dispMilliSec:(BOOL)millisec;


+(NSInteger)secondToOnlyHour:(NSInteger)second;
+(NSInteger)secondToOnlyMin:(NSInteger)second;
+(NSInteger)secondToOnlySec:(NSInteger)second;
+(NSString*)secondToStringTimes:(NSUInteger)second;
+(NSString*)secondToStringTimes_HMS:(NSUInteger)second;

+(NSString*)secondToStringTimes_UseVioce:(NSInteger)scond;


@end
