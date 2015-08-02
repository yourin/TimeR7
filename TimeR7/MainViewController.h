//
//  MainViewController.h
//  Stop7Watches
//
//  Created by oki on 2014/03/16.
//  Copyright (c) 2014年 youring. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FlipsideViewController.h"
#import "StopWatch.h"
#import "MyLocalNotification.h"



#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>





@interface MainViewController : UIViewController <UIAlertViewDelegate,FlipsideViewControllerDelegate>
{
    // インスタンス変数として 1 つ宣言する
//    GADBannerView *bannerView_;
    
     CFURLRef       soundURL;
     SystemSoundID  soundID;
    
    AVSpeechSynthesizer* speechSynth;
}

-(void)playSE1;


@end
