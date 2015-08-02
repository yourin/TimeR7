//
//  StopWatch.m
//  StopWatch10
//
//  Created by oki on 2014/03/09.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#import "StopWatch.h"

@implementation StopWatch
{

}
-(id)init{
    
    if(self = [super init]){
        self.stopWatchName  = @"";
        
        self.dateAlartTime  = 0.0;
        self.tempDateTime   = 0.0;
        self.dateStart      = 0;
        self.dateStop       = 0;
 
        self.dateLap1       = 0;
        self.dateLap2       = 0;
        self.dateLap3       = 0;
        self.stopWatchMode  = 0;

    }
    return self;
};

// float　を　"*時**分**秒*ミリ秒"　に分解して文字列として返す milli
+(NSString *)dateToString:(float)dateValue dispMilliSec:(BOOL)millisec{
    // 表示用の計算
    
    int hh = (int)(dateValue / 3600);
//    NSNSLog(@"hh = %2d",hh);
    int mm = (int)((dateValue - (hh * 3600)) / 60);
//    NSNSLog(@"mm = %02d",mm);
    
    NSString *string = [[NSString alloc]init];

//　ミリ秒が必要な場合
    if(millisec){
        float ss = dateValue - (float)((hh * 3600) + (mm * 60));
//        NSNSLog(@"ss = %02.1f",(float)hh*3600+mm*60);

        string= [NSString stringWithFormat:@"%d:%02d:%04.1f",hh,mm,ss];
        
    }else{
        int ss = dateValue - (int)(hh*3600+mm*60);
//        NSNSLog(@"ss = %02d",ss);
        
        string= [NSString stringWithFormat:@"%d:%02d:%02d",hh,mm,ss];
        
    }
    
    return string;
}

-(NSString *)LapTime:(NSDate *)date{

    float tmp = [date timeIntervalSinceDate:self.dateStart];
    
    if(self.tempDateTime != 0){
        tmp = tmp + self.tempDateTime;
    }
    int hh = (int)(tmp / 3600);
    int mm = (int)((tmp - (3600 * hh)) / 60);
    float ss = tmp - (float)((hh * 3600) + (mm * 60));
    
    //10時間を越えた場合は9:59:59と表示する。
    if(hh > 9){
        hh = 9;
        mm = 59;
        ss = 59.99;
    }
    NSString * _str = [NSString stringWithFormat:@"%d:%02d:%04.1f",hh,mm,ss];
    
    return  _str;
}


+(NSInteger)secondToOnlyHour:(NSInteger)second{
    
    NSInteger time = second / 3600; // Hour
    NSLog(@"%d時間",(int)time);
    
    return time;
}
+(NSInteger)secondToOnlyMin:(NSInteger)second{
    NSInteger h = second / 3600; // Hour
    NSInteger time = (second - (h*3600)) / 60; // Min
    NSLog(@"%d分",(int)time);
    return time;
}

+(NSInteger)secondToOnlySec:(NSInteger)second{
    NSInteger h = second / 3600; // Hour
    NSInteger m = (second - (h*3600)) / 60; // Min
    NSInteger time = second - (h*3600) - (m*60); // Sec
    NSLog(@"%d秒",(int)time);
    
    return time;
}
+(NSString*)secondToStringTimes:(NSUInteger)second{
    NSString* string = [NSString new];
    NSUInteger h = [self secondToOnlyHour:second];
    NSUInteger m = [self secondToOnlyMin:second];
    NSUInteger s = [self secondToOnlySec:second];
    
    string = [NSString stringWithFormat:@"%d:%02d:%02d.0",(int)h,(int)m,(int)s];
    
    return string;
}
+(NSString*)secondToStringTimes_HMS:(NSUInteger)second{
    NSString* string = [NSString new];
    NSUInteger h = [self secondToOnlyHour:second];
    NSUInteger m = [self secondToOnlyMin:second];
    NSUInteger s = [self secondToOnlySec:second];
    
    string = [NSString stringWithFormat:@"%d:%02d:%02d",(int)h,(int)m,(int)s];
    
    return string;
}

+(NSString*)secondToStringTimes_UseVioce:(NSInteger)second{
    NSMutableString* string = [NSMutableString new];
    
    NSUInteger h = [self secondToOnlyHour:second];
    NSUInteger m = [self secondToOnlyMin:second];
    NSUInteger s = [self secondToOnlySec:second];
    
    if(h == 0 && m == 0 && s == 0) return nil;
    
    if(h != 0){
        NSString* str_Hour = [NSString stringWithFormat:@"%d hour,",(int)h];
        [string appendString:str_Hour];
    }
    
    if(m != 0){
        NSString* str_Min = [NSString stringWithFormat:@"%d Minutes,",(int)m];
        [string appendString:str_Min];
    }
    if(s != 0){
        NSString* str_Sec = [NSString stringWithFormat:@"%d scond,",(int)s];
        [string appendString:str_Sec];
        
    }
    //    if(h != 0) string = [string appendString:str_Hour];
    //                                //appendString:str_Hour];
    //    if(m != 0) string = [string appendString:str_Min];
    //    if(s != 0) string = [string appendString:str_Sec];
    
    
    return string;
    
}
@end
