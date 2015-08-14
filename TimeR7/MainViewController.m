//
//  MainViewController.m
//  Stop7Watches
//
//  Created by oki on 2014/03/16.
//  Copyright (c) 2014年 youring. All rights reserved.
//

#define FIRST_SHOW_STOPWATCH 2
#define ALARM_SOUND_REPEART_COUNT 1
#define SOUND_EFFECT_SELECT 2

#define ALL_STOPWATCH       7

#define kStopWatch_MODE     0
#define kKitchenTimer_MODE  1

#define kAlertType_AllClear 91
#define KAlertType_AllReset 92

#define kiPhone4        480
#define kiPhone5        568

#define kTimerLabelSize 45


#import "MyLocalNotification.h"
#import "MainViewController.h"
#import "AppDelegate.h"


@interface MainViewController ()
{

    NSUInteger firstStopWatch;          //初期値　初期表示されるストップウォッチの数
    NSUInteger alarmSoundRepearCount;   //初期値　アラーム鳴動回数
    NSUInteger soundAndVoice;           //初期値　効果音onoff
    
    int         stopWatchCount;                 //現在のストップウォッチの数
    
    int         LapButtonXY;
    int         LapLabelSizeY;
    int         myPhoneHeightSize;              //iPhoneの画面サイズ
    int         myPhoneWidthSize;               //iPhoneの横画面サイズ　v1.2
    int         myPhoneViewSize;
    int         SW_lbl_HeightSize;
    int         lapLabelY;                      //ビューサイズによるラップラベル表示位置変更
    NSTimer *       timer;
    
    
    BOOL            timerFlg    [ALL_STOPWATCH];    //タイマーが動作中か？
    BOOL            reStartFlg  [ALL_STOPWATCH];    //一時停止中か

    NSUInteger      stopWatchMode[ALL_STOPWATCH];   //ストップウォッチモード
    
    StopWatch*      _sw         [ALL_STOPWATCH];    //表示されている数
    
    UIImageView*    _imageView  [ALL_STOPWATCH];
    
    UILabel *       _labelTimer [ALL_STOPWATCH];
    UILabel *       _labelName  [ALL_STOPWATCH];
    
    UILabel *       _labelLap1  [ALL_STOPWATCH];
    UILabel *       _labelLap2  [ALL_STOPWATCH];
    UILabel *       _labelLap3  [ALL_STOPWATCH];
    
    UIButton *      _btnStartStop[ALL_STOPWATCH];
    UIButton *      _btnLap     [ALL_STOPWATCH];
    
    NSArray *        _rainbowColors;
    
    // settingView ///////////////////////
    UIView      * backView;
    UIImageView * iv_setView;
    UIView      * alarmTimePresetView;
    NSArray     * array_PresetTime;
    UILabel     * lbl_AlarmTime;
    UIStepper   * stepper;


    
}

//@property (weak, nonatomic) ADBannerView            *bannerView;
//@property (weak, nonatomic) IBOutlet ADBannerView   *adView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *tbButtonAllStart;
@property (weak, nonatomic) IBOutlet UIToolbar      *toolBar;
// setting view item
@property (nonatomic) BOOL          dispAlarmSetView;
@property (nonatomic) NSUInteger    dispAlarmSetViewTag;
@property (nonatomic) BOOL          dipsAlarmTimePresetView;
@property (nonatomic) NSUInteger    alarmButtonTag;

// toolbar button
- (IBAction)tb_btn_AllClr   :(id)sender;
- (IBAction)tb_btn_Add      :(id)sender;
- (IBAction)tb_btn_AllStart :(id)sender;

// StopWatch Button
- (void)btnLap      :(UIButton *)button;
- (void)btnStartStop:(UIButton *)button;


// settingView Button
- (void)btn_setViewCancel:(int)tag;
- (void)btn_setViewSet:(int)tag;

@end



@implementation MainViewController

#pragma mark - 初期設定
-(void)configureView{

    stopWatchCount = 0;
    myPhoneHeightSize = self.view.bounds.size.height;
    myPhoneWidthSize = self.view.bounds.size.width;//1.2
    
    // タイマー動作フラグをすべて停止に設定
    for (int i = 0; i < ALL_STOPWATCH; i++) {
        timerFlg[i]     = NO;
        reStartFlg[i]   = NO;
    }
    // setting view off screen
  
    
    self.view.tag = 999;

    _dispAlarmSetView       = NO;
    _dispAlarmSetViewTag    = 999;
    _dipsAlarmTimePresetView = NO;
    
    if(_dispAlarmSetView)               [self removeSetView:0.1];
    if(_dipsAlarmTimePresetView)        [self removeAlarmTimePresetView];
    
    [self readSetting];
     
    //起動時に用意しておくストップウォッチの数
    for (int i = 0; i < firstStopWatch ; i++) {
        // 一定時間後に呼ぶメソッド
        [self stopWatchMake];
    }
    
}


#pragma mark 初期値読み込み
-(void)readSetting
{
    
    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    firstStopWatch = [userDefult integerForKey:@"KEY_FIRST_STOP_WATCH"];
    if(firstStopWatch == 0) firstStopWatch = FIRST_SHOW_STOPWATCH;
    
    // アラーム鳴動回数　設定
    alarmSoundRepearCount = [userDefult integerForKey:@"KEY_ALARM_SOUND_REPEART_COUNT"];
    if(alarmSoundRepearCount == 0) alarmSoundRepearCount = ALARM_SOUND_REPEART_COUNT;
    NSLog(@"alarmSoundRepearCount = %d",(int)alarmSoundRepearCount);
    self.tbButtonAllStart.title = @"AllStart";
    self.tbButtonAllStart.tintColor = [UIColor blueColor];
    
    // 効果音　音声　鳴動　on/off
    soundAndVoice = [userDefult integerForKey:@"SOUND_EFFECT_SELECT"];
//    soundAndVoice = SOUND_EFFECT_SELECT;
//    [userDefult registerDefaults:SOUND_EFFECT_SELECT];
    NSLog(@"soundAndVioce = %d",(int)soundAndVoice);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

        self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:1.0
                                                    alpha:1.0];
#pragma mark iPhone　判別
    NSLog(@"width = %3.1f",self.view.bounds.size.width);

    NSLog(@"Height = %3.1f",self.view.bounds.size.height);
    
#pragma mark 画面サイズ別バーツサイズ指定
    
    myPhoneHeightSize   = self.view.bounds.size.height;//v1.2
    myPhoneWidthSize    = self.view.bounds.size.width;//v1.2

    
    if(self.view.bounds.size.height == 480)
    {
        NSLog(@"iPhone4");
        SW_lbl_HeightSize   = 51;
//        myPhoneHeightSize   = 480;
        lapLabelY           = 36;
        LapButtonXY         = 51;
        LapLabelSizeY       = 16;
    }else
        if(self.view.bounds.size.height == 568){
            
            NSLog(@"iPhone5");
            SW_lbl_HeightSize   = 62;
//            myPhoneHeightSize   = 568;
            lapLabelY           = 40;
            LapButtonXY         = 62;
            LapLabelSizeY       = 17;
        }else
            if(self.view.bounds.size.height == 667.0){
                
                // ３．５、４インチ以外のサイズの場合　NewiPhone
                NSLog(@"iPhone6");
                
                SW_lbl_HeightSize   = 62;
                lapLabelY           = 40;
                LapButtonXY         = 62;
                LapLabelSizeY       = 17;
           
        }else
            if(self.view.bounds.size.height == 736.0){

            // ３．５、４インチ以外のサイズの場合　NewiPhone
                NSLog(@"iPhone6+");
    
            SW_lbl_HeightSize   = 62;
            myPhoneHeightSize   = self.view.bounds.size.height;//v1.2
            myPhoneWidthSize    = self.view.bounds.size.width;//v1.2
            lapLabelY           = 40;
            LapButtonXY         = 62;
            LapLabelSizeY       = 17;

        }
    
    
#pragma mark 虹カラー設定
    _rainbowColors = [NSArray new];
    
    _rainbowColors = [[NSArray alloc] initWithObjects:
                      [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                      [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1],
                      [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                      [UIColor colorWithRed:0.5 green:1 blue:0 alpha:1],
                      //[UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                      //[UIColor colorWithRed:0 green:1 blue:0.5 alpha:1],
                      //[UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                      [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],
                      //[UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                      //[UIColor colorWithRed:0.5 green:0 blue:1 alpha:1],
                      [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                      [UIColor colorWithRed:1 green:0 blue:0.5 alpha:1],
                      [UIColor colorWithRed:1 green:0 blue:0.25 alpha:1],nil];
    
/*
        _rainbowColors = [[NSArray alloc] initWithObjects:
                          [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                          [UIColor colorWithRed:1 green:0.25 blue:0 alpha:1],
                          [UIColor colorWithRed:1 green:0.5 blue:0 alpha:1],
                          [UIColor colorWithRed:1 green:0.75 blue:0 alpha:1],
                          [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0.75 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0.5 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0.25 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:0.25 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:0.5 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:0.75 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:1 alpha:1],
                          [UIColor colorWithRed:0 green:0.75 blue:1 alpha:1],
                          [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1],
                          [UIColor colorWithRed:0 green:0.25 blue:1 alpha:1],
                          [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:0.25 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:0.5 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:0.75 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:1 green:0 blue:0.75 alpha:1],
                          [UIColor colorWithRed:1 green:0 blue:0.5 alpha:1],
                          [UIColor colorWithRed:1 green:0 blue:0.25 alpha:1],nil];
*/

    [self configureView];

#pragma mark タイマー
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                             target:self
                                           selector:@selector(onTimer:)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    
  //      [self adMod];
}

#pragma mark N秒に一度呼ばれる
-(void)onTimer:(NSTimer*)timer{
    
    //　画面表示更新
    for (int i = 0; i < stopWatchCount; i++)
    {
        // 現在の時間を取得
        NSDate* now = [NSDate date];
        float tmp = 0.0;
        tmp = [now timeIntervalSinceDate:_sw[i].dateStart];
        
        // 再スタートの場合の計算
        if(_sw[i].tempDateTime != 0)
        {
            //停止までの時間を足す
            tmp = tmp + _sw[i].tempDateTime;
        }
                    // 現在時刻　➡　dateStartの間隔を取得
        
        if (timerFlg[i])
        {
            switch (_sw[i].stopWatchMode) {
                    
                case kStopWatch_MODE:
                    // StopWatch Mode

                     NSLog(@"Don't Check Alam Time ");
                    
                    // 数値を文字に変換
                    _labelTimer[i].text = [StopWatch dateToString:tmp dispMilliSec:YES];
                    
                    break;
                    
                case kKitchenTimer_MODE:
                    // KitchenTimder Mode
                    //アラームチェック
                    
                    if(_sw[i].dateAlartTime != 0)
                    {
                        float alartTime = _sw[i].dateAlartTime - tmp;
                        NSLog(@"alartTime = %.1f tmp = %.1f",_sw[i].dateAlartTime,tmp);
                        
       
                        if(_sw[i].dateAlartTime <= tmp)
                        {
                            // アラーム起動
                            NSLog(@"Alarm Time %d",i);
                            _labelTimer[i].text = [StopWatch dateToString:_sw[i].dateAlartTime dispMilliSec:YES];
                            timerFlg[i] = NO;
                            _sw[i].tempDateTime = 0.0;
                            [self alarm:i];
                            [_btnStartStop[i]  setTitle:@"▶︎" forState:UIControlStateNormal];
                            _imageView[i].alpha = 0.5;

                            
                        }else{
                            
                        NSLog(@"NO Alarm Time");
                            // 数値を文字に変換
                            _labelTimer[i].text = [StopWatch dateToString:alartTime dispMilliSec:YES];
                    }
                        break;
                        
                    default:
                        break;
                    }
                    
            }
            
        }
        
    }
    
}

#pragma mark アラーム鳴動
-(void)alarm:(int)stopwatchTag{
    
    // Making Speak Word


    {
        
        switch (soundAndVoice) {
            case 0:{
                NSString* message = [NSString stringWithFormat:@"TimeR%d AlarmTime. The set time %dmin.",stopwatchTag+1, (int)_sw[stopwatchTag].dateAlartTime/60];
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Check!"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                
                [alert show];
            }
                break;

            case 1:
            {
                
                    //効果音のみ
                    [self playAlarmSound];
 
                
            }
                break;

            case 2:
            {
                NSString* string = [NSString stringWithFormat:@"TimeR%d,AlarmTime. The set time %dmin.",stopwatchTag+1, (int)_sw[stopwatchTag].dateAlartTime/60];

                int x = 0;
                for(int i = 0;i < alarmSoundRepearCount ;i++)
                {
                    //音声アラーム

                    [self playWomanVoice:string];
                    x++;
                    NSLog(@"%d アラーム　鳴動回数 = %d",stopwatchTag,x);
                }
            }
                break;
                
            default:
                break;
        }

        
    }
    [MyLocalNotification delLocalNotification:stopwatchTag];
}

#pragma mark - ストップウォッチ作成
-(void)stopWatchMake{
    
    //　ストップウォッチの数をチェック
    if(stopWatchCount < ALL_STOPWATCH)
    {
        
        _sw[stopWatchCount] = [StopWatch new];
        _sw[stopWatchCount].stopWatchMode = kStopWatch_MODE;
        
        
#pragma mark ストップウォッチの土台の　imegeVIew
        _imageView[stopWatchCount] = [UIImageView new];
        
        // 表示位置
//v1.2
        _imageView[stopWatchCount].frame
        = CGRectMake(-myPhoneWidthSize,  20+(SW_lbl_HeightSize * stopWatchCount),
                     myPhoneWidthSize,SW_lbl_HeightSize);
//v1.1.2
//        _imageView[stopWatchCount].frame
//        = CGRectMake(-320,  20+(SW_lbl_HeightSize * stopWatchCount),
//                    320,SW_lbl_HeightSize);
        
        _imageView[stopWatchCount].backgroundColor = _rainbowColors[stopWatchCount];

        _imageView[stopWatchCount].alpha = 0.0;
        
        _imageView[stopWatchCount].userInteractionEnabled = YES; //imageView　で　タッチの検出する
        _imageView[stopWatchCount].tag = stopWatchCount;//  firstStopWatch;
            [self.view addSubview:_imageView[stopWatchCount]];
        
        
#pragma mark 時間表示ラベル
        _labelTimer[stopWatchCount]         = [UILabel new];
        _labelTimer[stopWatchCount].frame   = CGRectMake(115, 0, 150, kTimerLabelSize);
        
        _labelTimer[stopWatchCount].textAlignment = NSTextAlignmentRight;   //右寄せ
        _labelTimer[stopWatchCount].text = @"0:00:00.0";
        _labelTimer[stopWatchCount].textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        _labelTimer[stopWatchCount].font = [UIFont fontWithName:@"Helvetica-Light" size:35];//文字の種類とサイズ
        _labelTimer[stopWatchCount].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する

        _labelTimer[stopWatchCount].userInteractionEnabled = YES;           // タッチを有効
        _labelTimer[stopWatchCount].tag = stopWatchCount;
        
        [_imageView[stopWatchCount] addSubview:_labelTimer[stopWatchCount]];
       
#pragma mark 名前　ラベル
        _labelName[stopWatchCount]          = [UILabel new];
        _labelName[stopWatchCount].frame    = CGRectMake(53, 10, 62, 25);
        _labelName[stopWatchCount].text = [NSString stringWithFormat:@"TimeR%d",stopWatchCount+1];

        // ストップウォッチ名を一時保存しておく
        _sw[stopWatchCount].stopWatchName = _labelName[stopWatchCount].text;
        _labelName[stopWatchCount].font = [UIFont fontWithName:@"Helvetica-Light" size:18];//文字の種類とサイズ
        _labelName[stopWatchCount].textAlignment = NSTextAlignmentCenter;
        
        NSLog(@"_labelName[stopWatchCount].tag = %d",stopWatchCount);
        
        _labelName[stopWatchCount].tag = stopWatchCount;

        [_imageView[stopWatchCount] addSubview:_labelName[stopWatchCount]];
        
#pragma mark ラップ１表示ラベル
        _labelLap1[stopWatchCount]          = [UILabel new];
        _labelLap1[stopWatchCount].frame    = CGRectMake(63,     lapLabelY, 61, LapLabelSizeY);
        _labelLap1[stopWatchCount].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelLap1[stopWatchCount].textAlignment = NSTextAlignmentCenter;
        _labelLap1[stopWatchCount].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する
        _labelLap1[stopWatchCount].text = @"LAP1";
        _labelLap1[stopWatchCount].font = [UIFont fontWithName:@"Helvetica" size:13];//文字の種類とサイズ
        _labelLap1[stopWatchCount].tag = stopWatchCount;

        [_imageView[stopWatchCount] addSubview:_labelLap1[stopWatchCount]];
        
        
#pragma mark ラップ2表示ラベル
        _labelLap2[stopWatchCount] = [UILabel new];
        _labelLap2[stopWatchCount].frame   = CGRectMake(63+61+6, lapLabelY, 61, LapLabelSizeY);
        _labelLap2[stopWatchCount].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelLap2[stopWatchCount].textAlignment = NSTextAlignmentCenter;
        _labelLap2[stopWatchCount].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する
        _labelLap2[stopWatchCount].text = @"LAP2";
        _labelLap2[stopWatchCount].font = [UIFont fontWithName:@"Helvetica" size:13];//文字の種類とサイズ
        _labelLap2[stopWatchCount].tag = stopWatchCount;

        [_imageView[stopWatchCount] addSubview:_labelLap2[stopWatchCount]];
        
#pragma mark ラップ3表示ラベル
        _labelLap3[stopWatchCount] = [UILabel new];
        _labelLap3[stopWatchCount].frame   = CGRectMake(63+61+6+61+6,    lapLabelY, 61, LapLabelSizeY);
        _labelLap3[stopWatchCount].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelLap3[stopWatchCount].textAlignment = NSTextAlignmentCenter;
        _labelLap3[stopWatchCount].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する
        _labelLap3[stopWatchCount].text = @"LAP3";
        _labelLap3[stopWatchCount].font = [UIFont fontWithName:@"Helvetica" size:13];//文字の種類とサイズ
        _labelLap3[stopWatchCount].tag = stopWatchCount;

        [_imageView[stopWatchCount] addSubview:_labelLap3[stopWatchCount]];
        
        
#pragma mark - ボタン
#pragma mark ラップボタン
        
        _btnLap[stopWatchCount]  = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Button
        //ボタンのタイトル　通常時
        [_btnLap[stopWatchCount]  setTitle:@"LAP" forState:UIControlStateNormal];
        
        
        _btnLap[stopWatchCount].tintColor = [UIColor whiteColor];
        _btnLap[stopWatchCount].tintAdjustmentMode = NSTextAlignmentCenter;
        
        _btnLap[stopWatchCount].tag = stopWatchCount;
        
        
        //ボタンの位置と大きさ
        _btnLap[stopWatchCount] .frame = CGRectMake(myPhoneWidthSize - LapButtonXY, 0, LapButtonXY, LapButtonXY);
        
//OLD        _btnLap[stopWatchCount] .frame = CGRectMake(320-LapButtonXY, 0, LapButtonXY, LapButtonXY);

        //ボタンを押した時のアクション（メソッド）を設定
        [_btnLap[stopWatchCount] addTarget:self
                                    action:@selector(btnLap:)
                          forControlEvents:UIControlEventTouchDown];
        [_imageView[stopWatchCount] addSubview:_btnLap[stopWatchCount]];

#pragma mark スタート＆ストップボタン
        _btnStartStop[stopWatchCount]  = [UIButton buttonWithType:UIButtonTypeRoundedRect];//Button
        //ボタンのタイトル　通常時
        [_btnStartStop[stopWatchCount]  setTitle:@"▶︎" forState:UIControlStateNormal];
        _btnStartStop[stopWatchCount].tintColor = [UIColor whiteColor];
        
        _btnStartStop[stopWatchCount] .tag = stopWatchCount;
        //ボタンの位置と大きさ
        _btnStartStop[stopWatchCount] .frame = CGRectMake(0, 0, LapButtonXY, LapButtonXY);

        
        //ボタンを押した時のアクション（メソッド）を設定
        [_btnStartStop[stopWatchCount] addTarget:self
                                          action:@selector(btnStartStop:)
                                forControlEvents:UIControlEventTouchDown];
        [_imageView[stopWatchCount] addSubview:_btnStartStop[stopWatchCount]];
        
        
        
#pragma mark ストップウォッチ追加　アニメーション

            [UIView beginAnimations:nil context:nil]; //アニメーション
            [UIView setAnimationDuration:1.2]; //アニメーション時間
        
        NSLog(@"ストップウォッチ追加　アニメーション");
        //v1.2
        _imageView[stopWatchCount].frame = CGRectMake(  0,  20 + (SW_lbl_HeightSize * stopWatchCount),myPhoneWidthSize,SW_lbl_HeightSize);

//v1.1.2        _imageView[stopWatchCount].frame = CGRectMake(  0,  20 + (SW_lbl_HeightSize * stopWatchCount),320,SW_lbl_HeightSize);
            _imageView[stopWatchCount].alpha = 0.7;

        
            [UIView commitAnimations]; // アニメーション開始
 
            stopWatchCount++;
        
    }
    
#pragma mark 表示中のストップウォッチがｍａｘの場合
    else{

        NSString* message = [NSString stringWithFormat:@"Maximum of %d",stopWatchCount];
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Warning"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
}

/*
-(void)makeLapButtonTag:(NSInteger)tag labelLapNumber:(int)number{

#pragma mark ラップ4表示ラベル
    if (number == 4) {
        _labelLap4[tag] = [UILabel new];
        _labelLap4[tag].frame   = CGRectMake(320, lapLabelY, 70, 11);
        _labelLap4[tag].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _labelLap4[tag].textAlignment = NSTextAlignmentCenter;
        _labelLap4[tag].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する
        _labelLap4[tag].text = @"LAP4";
        _labelLap4[tag].font = [UIFont fontWithName:@"Helvetica-Bold" size:13];//文字の種類とサイズ
        _labelLap4[tag].backgroundColor = [UIColor whiteColor];
        [_imageView[tag] addSubview:_labelLap4[tag]];
    }
 
    #pragma mark ラップ5表示ラベル
        if (number == 5) {
            _labelLap5[stopWatchCount] = [UILabel new];
        _labelLap5[stopWatchCount].frame   = CGRectMake(320, 40, 70, 11);
            _labelLap5[stopWatchCount].autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _labelLap5[stopWatchCount].textAlignment = NSTextAlignmentCenter;
            _labelLap5[stopWatchCount].adjustsFontSizeToFitWidth = YES;//ラベルの横幅に合わせてフォントサイズを自動調節する
            _labelLap5[stopWatchCount].text = @"LAP5";
            _labelLap5[stopWatchCount].font = [UIFont fontWithName:@"Helvetica-Bold" size:13];//文字の種類とサイズ
            _labelLap5[stopWatchCount].backgroundColor = [UIColor whiteColor];
            [_imageView[stopWatchCount] addSubview:_labelLap5[stopWatchCount]];
 
        }
    
#pragma mark ラップ４表示アニメーション
    [UIView beginAnimations:nil context:nil]; //アニメーション
    [UIView setAnimationDuration:0.5]; //アニメーション時間
    _labelLap1[tag].frame   = CGRectMake(11            , lapLabelY, 70, 11);
    _labelLap2[tag].frame   = CGRectMake(11+(70+6)*1   , lapLabelY, 70, 11);
    _labelLap3[tag].frame   = CGRectMake(11+(70+6)*2   , lapLabelY, 70, 11);
    _labelLap4[tag].frame   = CGRectMake(11+(70+6)*3   , lapLabelY, 70, 11);
    
	[UIView commitAnimations]; // アニメーション開始
    

}
*/
#pragma mark - タッチ検出
// * タッチされたとき
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //タッチされたオブジェクトを取得
    UITouch *touch = [[event allTouches] anyObject];
    
    if(touch.view.tag == 999) return;
    
    NSLog(@"touch.view.tag = %d",(int)touch.view.tag);
    NSLog(@"_labelTimer[touch.view.tag].tag = %d",(int)_labelTimer[touch.view.tag].tag);
    
    if(touch.view.tag == _labelTimer[touch.view.tag].tag){
        NSLog(@"タッチ検出　tag = %d",(int)touch.view.tag);
        if(_dispAlarmSetView != YES)
        {
            [self makedSettingView:(int)touch.view.tag];
        }else{
            //[self removeSetView:0.1];
            NSLog(@"セッティングビュー表示中");
            
        }
    }
    [self playSE1];
}

#pragma mark ストップウォッチモード変更ボタン
-(void)changeStopWatchMode:(NSUInteger)viewTag stopWatchMode:(NSUInteger)stopWatchMode{
    
    NSLog(@"viewTag = %d",(int)viewTag);

    if(_sw[viewTag].stopWatchMode != kKitchenTimer_MODE){
        [self playWomanVoice:@"Change in, kitchen timer mode"];
    }

    
    switch (_sw[viewTag].stopWatchMode) {
        case kStopWatch_MODE:
        {
            // stop watch mode
            NSLog(@"%d ストップウォッチモードに変更",(int)viewTag);
            // lap button disp
            //            _btnLap[viewTag].hidden = NO;
            
            // mother Icon Hiddon
            [_btnLap[viewTag] setTitle:@"LAP" forState:UIControlStateNormal];
            [_btnLap[viewTag] setBackgroundImage:nil forState:UIControlStateNormal];
            [self playManVoice:@"Change in, stop watch mode"];
            _btnLap[viewTag].hidden = NO;
            _labelLap1[viewTag].hidden = NO;
            _labelLap2[viewTag].hidden = NO;
            _labelLap3[viewTag].hidden = NO;
            _sw[viewTag].dateAlartTime = 0;
            _sw[viewTag].dateStart     = 0;
            _sw[viewTag].dateStop      = 0;
            

            break;
        }
            
        case kKitchenTimer_MODE:
        {
            // Kitchen Timer  mode
            NSLog(@"%d キッチンタイマーモードに変更",(int)viewTag);
            // lap button Hidden
            //            _btnLap[viewTag].hidden = YES;
            
            // disp mother Icon
            UIImage *img = [UIImage imageNamed:@"mother.png"];
            
            UIButton* btn_modeChange = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn_modeChange.frame = CGRectMake(myPhoneWidthSize -((SW_lbl_HeightSize/10)*8), 9, (SW_lbl_HeightSize/4)*3, (SW_lbl_HeightSize/4)*3);

//OLD            btn_modeChange.frame = CGRectMake(320-((SW_lbl_HeightSize/10)*8), 9, (SW_lbl_HeightSize/4)*3, (SW_lbl_HeightSize/4)*3);
            [btn_modeChange setBackgroundImage:img forState:UIControlStateNormal];
            btn_modeChange.tag = viewTag;
            NSLog(@"btn_modeChange.tag = %d",(int)btn_modeChange.tag);
            [_imageView[viewTag] addSubview:btn_modeChange];
            
            [btn_modeChange addTarget:self action:@selector(changeInStopWatchMode:) forControlEvents:UIControlEventTouchUpInside];

//            [_btnLap[viewTag] setTitle:@"" forState:UIControlStateNormal];
//            [_btnLap[viewTag] setBackgroundImage:img forState:UIControlStateNormal];

            _btnLap[viewTag].hidden = YES;
            _labelLap1[viewTag].text = @"KITCHEN";
            _labelLap2[viewTag].text = @"TIMER";
            _labelLap3[viewTag].text = @"MODE";
            
                break;
        }
            
        default:
            break;
    }
}

#pragma mark ストップウォッチモード変更
-(void)changeInStopWatchMode:(UIButton *)sender
{
    if(timerFlg[sender.tag]==NO)
    {
        _labelLap1[sender.tag].text = @"PUSH";
        _labelLap2[sender.tag].text = @"START";
        _labelLap3[sender.tag].text = @"BUTTON";
    }
    NSLog(@"%d",(int)sender.tag);
    if(timerFlg[sender.tag] && soundAndVoice == 2){
        [self playWomanVoice:@"Please wait, a little."];
        _labelLap1[sender.tag].text = @"PLEASE";
        _labelLap2[sender.tag].text = @"WAIT A";
        _labelLap3[sender.tag].text = @"LITTLE.";
        

    }

    
    
}


#pragma mark - アラームセッティングビュー
//////////////////////////////////////////////////////////////////////////////
-(void)makedSettingView:(int)viewTag{
    
    // 背景色
    backView = [UIView new];
    backView.backgroundColor = [UIColor blackColor];
    backView.frame = CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height);
    backView.alpha = 0.0;
    
    [self.view addSubview:backView];

    //  土台を作成
    iv_setView = [UIImageView new];
    iv_setView.frame = CGRectMake(  myPhoneWidthSize,  20 + (SW_lbl_HeightSize * viewTag), myPhoneWidthSize, SW_lbl_HeightSize);

//OLD    iv_setView.frame = CGRectMake(  320,  20 + (SW_lbl_HeightSize * viewTag), 320, SW_lbl_HeightSize);
    iv_setView.userInteractionEnabled = YES; //imageView　で　タッチの検出する
    iv_setView.backgroundColor = _imageView[viewTag].backgroundColor;
    iv_setView.tag = viewTag;
    iv_setView.alpha = 0.0;
//    [backView addSubview:iv_setView];
    [self.view addSubview:iv_setView];
    
#pragma mark アラームセッティングビュー　ボタン
    // キャンセルボタン
    UIButton * cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancel.frame = CGRectMake(0, 0, SW_lbl_HeightSize, SW_lbl_HeightSize);
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    
//    cancel.tintColor = [UIColor redColor];
    [cancel setTitleColor:[ UIColor redColor ] forState:UIControlStateNormal ];
    [cancel setTitleShadowColor:[ UIColor grayColor ] forState:UIControlStateNormal ];
    cancel.titleLabel.shadowOffset = CGSizeMake( 1, 1 );
    
    [cancel addTarget:self action:@selector(btn_setViewCancel:) forControlEvents:UIControlEventTouchUpInside];
    cancel.tag = viewTag;
    [iv_setView addSubview:cancel];

    // セットボタン
    UIButton * set = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    set.frame = CGRectMake(myPhoneWidthSize - SW_lbl_HeightSize, 0, SW_lbl_HeightSize, SW_lbl_HeightSize);

//OLD    set.frame = CGRectMake(320 - SW_lbl_HeightSize, 0, SW_lbl_HeightSize, SW_lbl_HeightSize);
    [set setTitle:@"SET" forState:UIControlStateNormal];
    set.tintColor = [UIColor blueColor];
    [set addTarget:self action:@selector(btn_setViewSet:) forControlEvents:UIControlEventTouchUpInside];
    set.tag = viewTag;
    [iv_setView addSubview:set];
    
    stepper = [UIStepper new];

    stepper.frame = CGRectMake(70, 20, 0, 0);
    stepper.value = 1;
    stepper.minimumValue = 1;
    stepper.maximumValue = 60*9;
    stepper.hidden = YES;
    [stepper addTarget:self action:@selector(actionStepper:) forControlEvents:UIControlEventTouchUpInside];
    [iv_setView addSubview:stepper];
    
    // アラームタイムラベル
//    UILabel* lbl_AlarmTime = [UILabel new];
    lbl_AlarmTime = [UILabel new];
    lbl_AlarmTime.frame = CGRectMake(200, 0, 100, SW_lbl_HeightSize);
    
    if(_sw[viewTag].dateAlartTime == 0.0){
          lbl_AlarmTime.text = @"No Set";
    }else{
        int i = (int)(_sw[viewTag].dateAlartTime / 60);
        lbl_AlarmTime.text = [NSString stringWithFormat:@"%dmin",i];
                              
    }
    lbl_AlarmTime.textColor = [UIColor darkGrayColor];
    [iv_setView addSubview:lbl_AlarmTime];
    
    NSString* name = [NSString new];
    name = _sw[viewTag].stopWatchName;
    
    UILabel * lbl_name = [UILabel new];
    lbl_name.frame = CGRectMake(55, 0, 150, 25);
    name = [_sw[viewTag].stopWatchName stringByAppendingString:@" Alarm"];
    lbl_name.text = name;
    lbl_name.font = [UIFont fontWithName:@"Helvetica-Light" size:16];//文字の種類
    [iv_setView addSubview:lbl_name];


    
    [UIView beginAnimations:nil context:nil]; //アニメーション
    [UIView setAnimationDuration:0.5]; //アニメーション時間
    
    NSLog(@"settingViewアニメーションA");
    
    backView.alpha = 0.4f;
    iv_setView.frame = CGRectMake(  0,  20 + (SW_lbl_HeightSize * viewTag), myPhoneWidthSize, SW_lbl_HeightSize);

//OLD    iv_setView.frame = CGRectMake(  0,  20 + (SW_lbl_HeightSize * viewTag), 320, SW_lbl_HeightSize);
    iv_setView.alpha = 1.0f;

    [UIView commitAnimations]; // アニメーション開始
    
    [self makePresetTime:(int)viewTag];
    _dispAlarmSetView       = YES;
    _dispAlarmSetViewTag    = viewTag;

}


#pragma mark プリセットビュー
-(void)makePresetTime:(int)viewTag{
    if(!_dipsAlarmTimePresetView){
        
        //プリセットタイマー
        array_PresetTime = @[@"2",@"3",@"5",@"7",@"10",@"20",@"30"];
        
        alarmTimePresetView = [UIView new];
        alarmTimePresetView.backgroundColor = [UIColor whiteColor];
        alarmTimePresetView.frame = CGRectMake(myPhoneWidthSize, 20, 51,SW_lbl_HeightSize * array_PresetTime.count);

//OLD        alarmTimePresetView.frame = CGRectMake(320, 20, 51,SW_lbl_HeightSize * array_PresetTime.count);
        alarmTimePresetView.alpha = 0.1;
        [self.view addSubview:alarmTimePresetView];
        
        // プリセットボタン配置
        for(int i = 0 ; i<array_PresetTime.count;i++){
            UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            button.frame = CGRectMake(5, ((SW_lbl_HeightSize-44)/2)+(SW_lbl_HeightSize*i), 51, 44);
            
            button.backgroundColor = _rainbowColors[i];
            NSMutableString* str = [NSMutableString stringWithFormat:@"%@",array_PresetTime[i]];
            [str appendString:@"min"];
            button.tintColor = [UIColor blackColor];
            
            [button setTitle:str forState:UIControlStateNormal];
            button.tag = i;
            [button addTarget:self action:@selector(pushesPresetTimeButton:) forControlEvents:UIControlEventTouchUpInside];
            [alarmTimePresetView addSubview:button];
            
            
        }
        [self dispPresetView:viewTag];
        
        
    }else{
        NSLog(@"プリセット表示中");
    }
    
}

-(void)dispPresetView:(int)viewTag{

    [UIView beginAnimations:nil context:nil]; //アニメーション
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDuration:0.4]; //アニメーション時間
    NSLog(@"Insert PresetViewアニメーション");
//    alarmTimePresetView.center = CGPointMake(320 - (SW_lbl_HeightSize/2), alarmTimePresetView.center.y);
//OLD    alarmTimePresetView.center = CGPointMake(320 - 25, alarmTimePresetView.center.y);
    alarmTimePresetView.center = CGPointMake(myPhoneWidthSize - 25, alarmTimePresetView.center.y);

    alarmTimePresetView.alpha = 0.9f;
    [UIView commitAnimations]; // アニメーション開始

    _dipsAlarmTimePresetView = YES;
}

#pragma mark プリセットタイムボタン
-(void)pushesPresetTimeButton:(UIButton *)button{
    if(_dipsAlarmTimePresetView && _dispAlarmSetView){
        
        NSLog(@"プリセットボタン tag = %d",(int)button.tag);
        int i = [array_PresetTime[button.tag] intValue];
        stepper.value = i;
        stepper.hidden = NO;
        lbl_AlarmTime.text = [NSString stringWithFormat:@"%dmin",i];
        
        
    
        NSLog(@"lbl_AlarmTime.text = %d",i);
        _alarmButtonTag = button.tag;
        
 //       NSLog(@"プリセットボタンタイトル　= %@");
 
        //
        [UIView beginAnimations:nil context:nil]; //アニメーション
        [UIView setAnimationDelegate:self];
        
        [UIView setAnimationDuration:0.2]; //アニメーション時間
        [UIView setAnimationDidStopSelector:@selector(removeAlarmTimePresetView)];
        
        NSLog(@"Back PresetViewアニメーション");
        alarmTimePresetView.center = CGPointMake(myPhoneWidthSize + (SW_lbl_HeightSize/2), alarmTimePresetView.center.y);

//OLD        alarmTimePresetView.center = CGPointMake(320 + (SW_lbl_HeightSize/2), alarmTimePresetView.center.y);
        alarmTimePresetView.alpha = 0.1f;
        [UIView commitAnimations]; // アニメーション開始
    }
}

-(void)actionStepper:(id)sender{
    stepper = sender;
    [self playSE1];
    lbl_AlarmTime.text = [NSString stringWithFormat:@"%dmin",(int)stepper.value];
}

#pragma mark キャンセル　ボタン
- (void)btn_setViewCancel:(int)tag {
    NSLog(@"Pushed settingVIew Cancel");
    
    [UIView beginAnimations:nil context:nil]; //アニメーション
    [UIView setAnimationDelegate:self];

    [UIView setAnimationDuration:0.5]; //アニメーション時間
    [UIView setAnimationDidStopSelector:@selector(removeSetView:)];
    NSLog(@"settingViewアニメーション");
    // moving left
    iv_setView.center = CGPointMake(160, iv_setView.center.y);
    //iv_setView.frame = CGRectMake(  -320,  20 + (SW_lbl_HeightSize * tag),320,SW_lbl_HeightSize);
    iv_setView.alpha = 0.0f;
    [UIView commitAnimations]; // アニメーション開始

}

#pragma mark アラームタイム　セット　ボタン
- (void)btn_setViewSet:(int)tag {
   
    NSLog(@"Pushed settingView Set");
    
    // Alarm set
    //アラームを設定
    int i = [lbl_AlarmTime.text intValue];

    _sw[_dispAlarmSetViewTag].dateAlartTime = i * 60; // i 分後
    NSLog(@"%f .dateAlartTime = %.0f",
        (float)_dispAlarmSetViewTag,_sw[_dispAlarmSetViewTag].dateAlartTime );
    
    
    // タイマー動作チェック
    if(timerFlg[_dispAlarmSetViewTag]==NO)
    {
        // 設定したアラーム時間を表示する
        
        NSString* string = [StopWatch  dateToString:_sw[_dispAlarmSetViewTag].dateAlartTime dispMilliSec:YES];
        
        _labelTimer[_dispAlarmSetViewTag].text = string;
        
        // スタートとストップをクリアする
        _sw[_dispAlarmSetViewTag].dateStart = 0;
        _sw[_dispAlarmSetViewTag].dateStop = 0;
    }
    
    // 喋らせる言葉を作る
    NSString* string = [NSString stringWithFormat:@"Set to %d minutes after",i];
    [self playWomanVoice:string];
    

    
    [UIView beginAnimations:nil context:nil]; //アニメーション
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDuration:0.5]; //アニメーション時間
    [UIView setAnimationDidStopSelector:@selector(removeSetView:)];
    
    NSLog(@"settingViewアニメーション");
    // moving right
    iv_setView.center = CGPointMake(-160, iv_setView.center.y);
    iv_setView.alpha = 0.0f;
    
    [UIView commitAnimations]; // アニメーション開始

    _sw[_dispAlarmSetViewTag].stopWatchMode = kKitchenTimer_MODE;
    
    [self changeStopWatchMode:_dispAlarmSetViewTag stopWatchMode:kKitchenTimer_MODE];
    

}


#pragma mark セッティングビュー削除
-(void)removeSetView:(float)delayTime{
    if(_dipsAlarmTimePresetView) {
        
        [UIView beginAnimations:nil context:nil]; //アニメーション
        [UIView setAnimationDelegate:self];
        
        [UIView setAnimationDuration:0.5]; //アニメーション時間
        [UIView setAnimationDidStopSelector:@selector(removeAlarmTimePresetView)];
        
        NSLog(@"Back PresetViewアニメーション");
        alarmTimePresetView.center = CGPointMake(myPhoneWidthSize + (SW_lbl_HeightSize/2), alarmTimePresetView.center.y);

//OLD        alarmTimePresetView.center = CGPointMake(320 + (SW_lbl_HeightSize/2), alarmTimePresetView.center.y);
        alarmTimePresetView.alpha = 0.1f;
        [UIView commitAnimations]; // アニメーション開始
    }

    
    if(delayTime == 0.0) delayTime = 0.3;
    [iv_setView removeFromSuperview];
        [backView removeFromSuperview]   ;
    _dispAlarmSetView = NO;
    _dispAlarmSetViewTag = 999;
    NSLog(@"セッティングビューを削除しました。");
}

#pragma mark セレクトビュー削除
-(void)removeAlarmTimePresetView{
    [alarmTimePresetView removeFromSuperview];
    _dipsAlarmTimePresetView = NO;
    
    NSLog(@"プリセットを削除しました。");
    
}

//////////////////////////////////////////////////////////////////////////////


#pragma mark - ストップウォッチラベル　ボタン
#pragma mark ラップボタン
- (void)btnLap:(UIButton *)button
{
    NSLog(@"Lap Button tag = %d",(int)button.tag);
    
    
    // タイマーが動いている場合
    if (timerFlg[button.tag] == YES) {
        
        NSString * str = [_sw[button.tag] LapTime:[NSDate date]];
        
        //ラップタイムに登録
        if (_sw[button.tag].dateLap1 == nil){
            _labelLap1[button.tag].text = str;
            _sw[button.tag].dateLap1 = [NSDate date];
            
        }else if (_sw[button.tag].dateLap2 == nil){
            _labelLap2[button.tag].text = str;
            _sw[button.tag].dateLap2 = [NSDate date];
            
        }else if(_sw[button.tag].dateLap3 == nil){
            _labelLap3[button.tag].text = str;
            _sw[button.tag].dateLap3 = [NSDate date];

        }
    }else
        // タイマーが動いていない場合はアラートを表示する
        if(timerFlg[button.tag] == NO){
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Check"
                                                       message:@"The timer is not moving."
                                                      delegate:self
                                             cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [self playSE1];
}


#pragma mark スタート/ストップ　ボタン
- (void)btnStartStop:(UIButton *)button{
    NSLog(@"StartStop tag = %d",(int)button.tag);
    
    // タイマー動作中チェック
    if (timerFlg[button.tag] == NO)
    {
/////////////////////////////////////
        _sw[button.tag].dateStart = [NSDate date];
         NSLog(@"%@",_sw[button.tag].dateStop);

        [_btnStartStop[button.tag]  setTitle:@"||" forState:UIControlStateNormal];
        _imageView[button.tag].alpha = 0.8;

        //　タイマー動作中
        timerFlg[button.tag] = YES;

        [self playSE1];
        [self playWomanVoice:@"Start"];
        
#pragma mark 通知を設定する
        if(_sw[button.tag].dateAlartTime != 0)
        {
            [MyLocalNotification setLocalNotification:(int)button.tag
                                                     afterSec:(int)_sw[button.tag].dateAlartTime];
        }

        ////////////////////////////////////
    }else
        if (timerFlg[button.tag] == YES){
        //　タイマーフラグ
            _sw[button.tag].dateStop = [NSDate date];

            timerFlg[button.tag] = NO;
        

        // 経過時間を　(Float).tempDateTime で一時保存しておく
            
            if(_sw[button.tag].tempDateTime != 0){
                
                _sw[button.tag].tempDateTime = _sw[button.tag].tempDateTime + [_sw[button.tag].dateStop timeIntervalSinceDate:_sw[button.tag].dateStart ];
            
            }else _sw[button.tag].tempDateTime
                
                = [_sw[button.tag].dateStop timeIntervalSinceDate:_sw[button.tag].dateStart ];
            
        
            NSLog(@"%.1f",_sw[button.tag].tempDateTime);
            _sw[button.tag].dateStart = 0;
            _sw[button.tag].dateStop = 0;
            
        [_btnStartStop[button.tag]  setTitle:@"▶︎" forState:UIControlStateNormal];
        _imageView[button.tag].alpha = 0.6;
            

            [self playSE1];
            [self playWomanVoice:@"TimerStop"];

#pragma mark 通知を解除する
            if(_sw[button.tag].dateAlartTime != 0)
            {
            [MyLocalNotification delLocalNotification:(int)button.tag];
            }

        }

    
}

#pragma mark - ツールバー　オールクリア
- (IBAction)tb_btn_AllClr:(id)sender {
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirmation"
                                                   message:@"Remove all of the Timers?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
    alert.tag = kAlertType_AllClear;
    
    [alert show];
    
}



#pragma mark ツールバー　プラスボタン
- (IBAction)tb_btn_Add:(id)sender {

    // アラームセッティング中なら画面を消す
    
    if(_dispAlarmSetView)           [self removeSetView:0.1];
    if(_dipsAlarmTimePresetView)    [self removeAlarmTimePresetView];
    [self stopWatchMake];
    [self playSE1];
}


#pragma mark ツールバー　オールスタートボタン
- (IBAction)tb_btn_AllStart:(id)sender {
    
    // アラームセッティング中なら画面を消す
    if(_dispAlarmSetView)           [self removeSetView:0.1];
    if(_dipsAlarmTimePresetView)    [self removeAlarmTimePresetView];

// タイマーが動いていないことをチェックする
    int moveTimer = 0;
    NSMutableArray *mutableArray = [NSMutableArray new];
    
    for (int i = stopWatchCount; i > -1 ; i--) {
        //　現在表示されているストップウォッチが動いているかチェック
        if (timerFlg[i]==YES){
            //NSUInteger stopWatchNumber = i;
            [mutableArray addObject:@(i)];
            moveTimer++;
            NSLog(@"moveTimer = %d",moveTimer);
        }
        
    }

    
    if (moveTimer == 0){
        //　オールスタート
        NSLog(@"オールスタート");
        
        // 表示されているストップウォッチを一斉に動作させる
        _sw[0].dateStart = [NSDate date]; //　全部のストップウォッチの基準時間にする
        
        for (int i = 0; i < stopWatchCount ; i++) {
            
            timerFlg[i] = YES;
            // 現在時刻（基準）をセット
            _sw[i].dateStart = _sw[0].dateStart;
            
            [_btnStartStop[i]  setTitle:@"||" forState:UIControlStateNormal];
            _imageView[i].alpha = 0.8;
            
            // アラームが設定されているか？
            if(_sw[i].dateAlartTime != 0)
            {
            
            [MyLocalNotification setLocalNotification:(int)i
                                             afterSec:(int)_sw[i].dateAlartTime];
            }
            //[self playSE1];
            
        }

        self.tbButtonAllStart.title = @"AllStop";
        self.tbButtonAllStart.tintColor = [UIColor redColor];
        
        [self playWomanVoice:@"all start"];

    }
    
    else{

        NSLog(@"オールストップ");
        
        // 表示されているストップウォッチを全て停止させる
        
        for (int i = 0; i < stopWatchCount ; i++)
        {
        
            if(timerFlg[i]){
                if(_sw[i].dateStart != nil) _sw[i].dateStop = [NSDate date];

                timerFlg[i] = NO;
                
                [_btnStartStop[i]  setTitle:@"▶︎" forState:UIControlStateNormal];
                _imageView[i].alpha = 0.5;
                //[self playSE1];
            }
            
            
            if(_sw[i].tempDateTime != 0)
            {
                NSLog(@"_sw[%d].tempDateTime != 0",i);
            
                _sw[i].tempDateTime = _sw[i].tempDateTime + [_sw[i].dateStop timeIntervalSinceDate:_sw[i].dateStart ];
                
            }else{
                
                if(_sw[i].dateStart == nil) _sw[i].dateStart = [NSDate date];
                NSLog(@"_sw[%d].tempDateTime == 0",i);
                //_sw[i].tempDateTime = 0.0;
                NSLog(@"_sw[%d].dateStart= %@",i,_sw[i].dateStart);

                NSLog(@"_sw[%d].dateStop= %@",i,_sw[i].dateStop);
                
                _sw[i].tempDateTime = [_sw[i].dateStop timeIntervalSinceDate:_sw[i].dateStart ];
                NSLog(@"%.1f",_sw[i].tempDateTime);
                
                [_btnStartStop[i]  setTitle:@"▶︎" forState:UIControlStateNormal];
                _imageView[i].alpha = 0.6;
                
                [self playSE1];
 

            }

        }
        
        for (int i = 0; i < stopWatchCount ; i++) {
            _sw[i].dateStart = 0;
            _sw[i].dateStop = 0;
            
            // 通知の削除
            [MyLocalNotification delLocalNotification:i];

        }
        
        // 経過時間を　(Float).tempDateTime で一時保存しておく
        self.tbButtonAllStart.title = @"AllStart";
        self.tbButtonAllStart.tintColor = [UIColor blueColor];
               [self playWomanVoice:@"stop"];

    }
    
}
//////////////////////////////////////////////////////////////////////
#pragma mark - アラートのボタン判定
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag != 0)
    {
        //        NSNSLog(@"AlertView tag = %d",alertView.tag);
        
        switch (alertView.tag) {
                
            case kAlertType_AllClear:
                switch (buttonIndex) {
                    case 0:
                        //１番目のボタンが押されたときの処理を記述する
                        NSLog(@"AllClear ALert button 1");
                        
                        
                        break;
                    case 1:
                        //２番目のボタンが押されたときの処理を記述する
                        NSLog(@"削除実行");
                        
                        NSLog(@"AllClear ALert button 2");
                        
                        for (int i = stopWatchCount; i > -1; i--)
                        {
                            [UIView beginAnimations:nil context:nil]; //アニメーション
                            [UIView setAnimationDuration:0.5]; //アニメーション時間
                            _imageView[i].center = CGPointMake(myPhoneWidthSize, 600);

//OLD                            _imageView[i].center = CGPointMake(320, 600);
                            _imageView[i].transform = CGAffineTransformMakeScale(0.5f, 0.5f);
                            _imageView[i].alpha = 0.1;
                            
                            [UIView commitAnimations]; // アニメーション開始
                        }
                        [self removeSetView:0.1];
                        [self removeStopWatch];
                        [self configureView];
                        NSLog(@"stopWatchCount = %d",stopWatchCount);
                        break;
                        
                    default:
                        break;
                }
                break;
 
            default:
                break;
                
        }
    }
}
-(void)removeStopWatch{
    
    for (int i = stopWatchCount; i > -1; i--) {
        [UIView beginAnimations:nil context:nil]; //アニメーション
        [UIView setAnimationDuration:2.0f]; //アニメーション時間
        

        NSLog(@"_imageView[%d]削除",i);
        [_imageView[i] removeFromSuperview];
        [UIView commitAnimations]; // アニメーション開始
        
    }

}
/*
////////////////////////////////////////////////////////////////////////////////////
#pragma mark - 広告表示
#pragma mark 広告を画面の下に隠す
-(void)viewDidAppear:(BOOL)animated
{

        
        NSLog(@"viewDidAppear");
        [super viewDidAppear:animated];
        
        CGRect bannerFrame = self.adView.frame;
        bannerFrame.origin.y = 480;
        
        bannerFrame.origin.y = self.view.frame.size.height;
        self.adView.frame = bannerFrame;
 

}



#pragma mark 広告を表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"広告あり");
        CGRect bannerFrame = banner.frame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // iPhone or iPod touch
//         bannerFrame.origin.y = self.view.frame.size.height - banner.frame.size.height - 44;
        
    }
    else {
        // iPad
        banner.hidden = YES;
    }

    
//    bannerFrame.origin.y = self.view.frame.size.height - banner.frame.size.height - 44;
//    bannerFrame.origin.y = self.view.frame.size.height - bannerFrame.size.height - 44;
    
    
    [UIView animateWithDuration:1.0f
                     animations:^{
                         banner.frame = bannerFrame;
                         //NSNSLog(@"banner.frame.origin.y = %f",banner.frame.origin.y);
                     }];
//    NSNSLog(@"広告あり");
     
}
#pragma mark 広告を非表示
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"広告なし");

    CGRect bannerFrame = banner.frame;

//    bannerFrame.origin.y = self.view.frame.size.height - banner.frame.size.height + 44;
//        bannerFrame.origin.y = self.view.frame.size.height - bannerFrame.size.height + 44;
//    bannerFrame.origin.y = 480 - 50 + 44;
        banner.hidden = YES;
    NSLog(@"bannerFrame.origin.y = %f",bannerFrame.origin.y);
    
    
    [UIView animateWithDuration:1.0f
                     animations:^{
                         NSLog(@"広告無しアニメーション");
                         
                         
                         banner.frame = bannerFrame;
                         NSLog(@"banner.frame.origin.y = %f",banner.frame.origin.y);
                     }];

    [self adMod];
    
}
*/
#pragma mark adMod
-(void)adMod{
//    NSLog(@"AdMob起動");
//    // 画面上部に標準サイズのビューを作成する
//    // 利用可能な広告サイズの定数値は GADAdSize.h で説明されている
//    //    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0,myPhoneHeightSize - 44 -50 , 320, 50)];
//
//    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0,myPhoneHeightSize, 320, 50)];
//
//    // 広告ユニット ID を指定する
//    bannerView_.adUnitID = @"ca-app-pub-2897992595879125/6438970498";
//    
//    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
//    // ビュー階層に追加する
//    bannerView_.rootViewController = self;
//    
//    [self.view addSubview:bannerView_];
//    
//    // 一般的なリクエストを行って広告を読み込む
//    [bannerView_ loadRequest:[GADRequest request]];
//    
//    [UIView animateWithDuration:1.0f
//                     animations:^{
//                         bannerView_.frame = CGRectMake(0,myPhoneHeightSize-44-50,320,50);
//
//                         NSLog(@"AdMob Anime");
//                     }];
//    
//    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View 設定画面

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    NSLog(@"%s", __FUNCTION__);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self readSetting];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}
#pragma mark 効果音
-(void)playSE1{
    //効果音再生
    if(soundAndVoice>0){
    //      AudioServicesPlaySystemSound (soundID);
    //      AudioServicesPlaySystemSound(1035); //タイプライター
    AudioServicesPlaySystemSound(1104); //キーボードタップ音
        NSLog(@"SoundEffect");
    }
    
}

#pragma mark アラーム音
-(void)playAlarmSound
{
    CFBundleRef mainBundle;
    mainBundle = CFBundleGetMainBundle ();
    soundURL  = CFBundleCopyResourceURL (mainBundle,CFSTR ("Notification"),CFSTR ("caf"),NULL);
    AudioServicesCreateSystemSoundID (soundURL, &soundID);
    CFRelease (soundURL);
    AudioServicesPlaySystemSound (soundID);
}




#pragma mark - 音声再生
- (void)playWomanVoice:(NSString *)string
{
    if(soundAndVoice>1){
    
        
        if(string != nil)
        {
            AVSpeechSynthesizer* speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
            // NSString* speakingText = string;
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
            AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
            // AVSpeechSynthesisVoiceをAVSpeechUtterance.voiceに指定。
            utterance.voice =  voice;
            utterance.rate              = 0.2f;         // 読み上げる速さ
            utterance.pitchMultiplier   = 0.95f;        // 声の高さ
            utterance.preUtteranceDelay = 0.0f;         // **秒のためを作る
            utterance.volume            = 0.6f;         // 声の大きさ
            [speechSynthesizer speakUtterance:utterance];
            NSLog(@"Voice Effect");
        }
    }
}

- (void)playManVoice:(NSString *)string
{
    if(soundAndVoice>1){
        
        
        if(string != nil)
        {
            AVSpeechSynthesizer* speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
            // AVSpeechUtteranceに再生テキストを設定し、インスタンス作成
            
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
            // 英語に設定し、AVSpeechSynthesisVoiceのインスタンス作成
            AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
            // AVSpeechSynthesisVoiceをAVSpeechUtterance.voiceに指定。
            utterance.voice =  voice;
            // デフォルトは早すぎるので
            utterance.rate              = 0.2;
            // 男性ぽく
            utterance.pitchMultiplier   = 0.55;
            // **秒のためを作る
            utterance.preUtteranceDelay = 0.0f;
            // 声の大きさ
            utterance.volume            = 0.6f;
            // 再生開始
            [speechSynthesizer speakUtterance:utterance];
            
        }
    }
}
@end
