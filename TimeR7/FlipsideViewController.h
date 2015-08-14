//
//  FlipsideViewController.h
//  Stop7Watches
//
//  Created by oki on 2014/03/16.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#import "WZYFlatUIColor.h"
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

// SDK から GADBannerView の定義をインポートする
//#import "GADBannerView.h"
//#import <AudioToolbox/AudioToolbox.h>
//#import "NADView.h"
//#import "NADIconView.h"
//#import "AdIconViewController.h"
//#import <AppVador/AvAdView.h>




@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
{
    // インスタンス変数として 1 つ宣言する
//    GADBannerView *bannerView_;

}

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;




- (IBAction)done:(id)sender;

@property (weak, nonatomic) IBOutlet UINavigationBar *nabigationBar;

//　最初に表示するストップウォッチの数
@property (weak, nonatomic) IBOutlet UILabel *firstStopWatchesCount;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
- (IBAction)actionStepper:(id)sender;

//　アプリ起動中のスリープ
@property (weak, nonatomic) IBOutlet UILabel *lbl_sleep;
@property (weak, nonatomic) IBOutlet UISwitch *sw_Sleep;

- (IBAction)action_SleepSW:(UISwitch *)sender;


//　アラーム音の繰り返す回数
@property (weak, nonatomic) IBOutlet UILabel *alarmSoundRepeatCount;
@property (weak, nonatomic) IBOutlet UIStepper *stepper_AlarmSoundRepeatCount;
- (IBAction)actionStepper_AlarmSoundRepeatCount:(id)sender;

//　効果音、音声
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment_SEandVoice;
- (IBAction)actionSegCon_SEandVoice:(UISegmentedControl *)sender;

@end
