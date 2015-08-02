//
//  FlipsideViewController.m
//  Stop7Watches
//
//  Created by oki on 2014/03/16.
//  Copyright (c) 2014年 youring. All rights reserved.
//
#define BUTTON_SIZE 44

#define FIRST_SHOW_STOPWATCH 2
#define ALARM_SOUND_REPEART_COUNT 1
#define SOUND_EFFECT_SELECT 2
#define PRESET_TIMERS_COUNT 7
#define HOUR_COUNT 10
#define MIN_COUNT 60
#define SEC_COUNT 60

#define kSET 102
#define kCANCEL 101

#define kHOUR 0
#define kMIN 1
#define kSECOND 2

#import "FlipsideViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "StopWatch.h"





@interface FlipsideViewController ()

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic)BOOL isDispPicker;
@property (nonatomic)UIImageView* imageView;
@property (nonatomic)UIView* myView;
@property (nonatomic)UIButton* btn_cancel;
@property (nonatomic)UIButton* btn_Set;

@end

@implementation FlipsideViewController
{
    CFURLRef       soundURL;
    SystemSoundID  soundID;
    BOOL        _bannerIsVisible;
    NSArray*    _rainbowColors;
    
    NSMutableArray*    ary_PresetTimes;
    
    UIButton*   btn_presetTimes[PRESET_TIMERS_COUNT];
    
    NSMutableArray* ary_Hour;
    NSMutableArray* ary_Min;
    NSMutableArray* ary_Sec;
    
    NSUInteger newPresetTimes;
    NSInteger selected_PresetNum;
    
    BOOL    _isNotSleepMode;

}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"%s",__FUNCTION__);
    [self read_UserDefaults];
    [self make_PresetButtons];
    [self change_SleepModeText];
}

#pragma mark 設定値の読み出し
-(void)read_UserDefaults{
    NSLog(@"%s", __FUNCTION__);
    // 設定値読み出し////////////////////////////
    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    
    NSUInteger firstStopWatch = [userDefult integerForKey:@"KEY_FIRST_STOP_WATCH"];
    if(firstStopWatch == 0) firstStopWatch = FIRST_SHOW_STOPWATCH;
    self.firstStopWatchesCount.text = [NSString stringWithFormat:@"%d",(int)firstStopWatch];
    
    self.stepper.value = firstStopWatch;
    
    NSUInteger alarmSoundRepeatCount = [userDefult integerForKey:@"KEY_ALARM_SOUND_REPEART_COUNT"];
    if(alarmSoundRepeatCount == 0) alarmSoundRepeatCount = ALARM_SOUND_REPEART_COUNT;
    
    self.alarmSoundRepeatCount.text = [NSString stringWithFormat:@"%d",(int)alarmSoundRepeatCount];
    self.stepper_AlarmSoundRepeatCount.value = alarmSoundRepeatCount;
    
    NSUInteger soundEffectSelect = [userDefult integerForKey:@"SOUND_EFFECT_SELECT"];
    self.segment_SEandVoice.selectedSegmentIndex = soundEffectSelect;
    
    // スリープキャンセルスイッチ
    _sw_Sleep.on = [userDefult boolForKey:@"NON_SLEEP"];
    _isNotSleepMode = _sw_Sleep.on;
    
    //   NSLog(@"ary_PresetTimes = OK");
    
    ary_PresetTimes = [userDefult mutableArrayValueForKey:@"PRESET_TIMES"];
    //
    if(ary_PresetTimes.count == 0){
        NSLog(@"ary_PresetTimes = 0");
        ary_PresetTimes = @[@"60",@"180",@"300",@"420",@"600",@"1800",@"3600"].mutableCopy;
    }
    
}


#pragma mark ピッカーの準備
-(void)configurrePickerView{
    
    ary_Hour = [NSMutableArray arrayWithCapacity:HOUR_COUNT];
    ary_Min = [NSMutableArray arrayWithCapacity:MIN_COUNT];
    ary_Sec = [NSMutableArray arrayWithCapacity:SEC_COUNT];
    // ピッカー用　時間データ
    for (int i = 0; i < HOUR_COUNT; i++) {
        //        NSLog(@"Hour = %d",i);
        [ary_Hour addObject:@(i)];
    }
    //    NSLog(@"ary_HourCount = %d",(int)ary_Hour.count);
    //　ピッカー用　分データ
    for (int i = 0; i < MIN_COUNT; i++) {
        //        NSLog(@"min = %d",i);
        
        [ary_Min addObject:@(i)];
    }
    //    NSLog(@"ary_MinCount = %d",(int)ary_Min.count);
    //　ピッカー用秒データ
    for (int i = 0; i < SEC_COUNT; i++) {
        //        NSLog(@"sec = %d",i);
        
        [ary_Sec addObject:@(i)];
    }
    //    NSLog(@"ary_SecCount = %d",(int)ary_Sec.count);
    
    // タイムピッカーを隠す
    _isDispPicker = NO;
    
}


#pragma mark プリセットタイマーボタン作成
-(void)make_PresetButtons{
    
    CGSize size = CGSizeMake(BUTTON_SIZE,BUTTON_SIZE);
    // プリセットタイム　ボタンを貼り付け
    for (int i = 0; i< ary_PresetTimes.count; i++) {
        //        NSLog(@"Button = %d",i);
        
        int presetTime = [ary_PresetTimes[i] intValue];
        
        //        NSLog(@"プリセットタイム ＝ %d",presetTime);
        
        int h = presetTime / 3600; // Hour
        //        NSLog(@"%d時間",h);
        int m = (presetTime - (h*3600)) / 60; // Min
        //        NSLog(@"%d分",m);
        int s = presetTime - (h*3600) - (m*60); // Sec
        //        NSLog(@"%d時 %02d分 %02d秒",h,m,s);
        NSString* str_PresetTime = [NSString stringWithFormat:@"%d:%02d:%02d",h,m,s];
        
        //        btn_presetTimes[i] = [UIButton new];
        
        btn_presetTimes[i] = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn_presetTimes[i].alpha = 0.7f;
        btn_presetTimes[i].tintColor = [UIColor blackColor];
        btn_presetTimes[i].frame = CGRectMake(6+(i * (BUTTON_SIZE*2)), 0, size.width * 2,size.height);
        //        [btn_presetTimes[i]  setTitle:ary_PresetTimes[i] forState:UIControlStateNormal];
        [btn_presetTimes[i]  setTitle:str_PresetTime forState:UIControlStateNormal];
        
        btn_presetTimes[i].backgroundColor = _rainbowColors[i];
        btn_presetTimes[i].tag =i;
        [btn_presetTimes[i] addTarget:self action:@selector(setting_PresetTimers:) forControlEvents:UIControlEventTouchUpInside];
        
        btn_presetTimes[i].layer.borderColor = [UIColor clearColor].CGColor;
        btn_presetTimes[i].layer.borderWidth = 1.0f;
        btn_presetTimes[i].layer.cornerRadius = 7.5f;
        
        _scrolView.contentSize = CGSizeMake(BUTTON_SIZE*2+(BUTTON_SIZE*2)*i, size.height);
        [self.scrolView addSubview:btn_presetTimes[i]];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
     
     // 虹色設定
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
     
     //　ステッパー設定　最初に表示されるタイマーの数
     self.stepper.value          = 2;
     self.stepper.minimumValue   = 1;
     self.stepper.maximumValue   = 7;
     self.stepper.stepValue      = 1;
     // ステッパー設定　アラームの繰り返し回数
     self.stepper_AlarmSoundRepeatCount.value          = 1;
     self.stepper_AlarmSoundRepeatCount.minimumValue   = 1;
     self.stepper_AlarmSoundRepeatCount.maximumValue   = 9;
     self.stepper_AlarmSoundRepeatCount.stepValue      = 1;
     
     selected_PresetNum = 999;
     
     //////////////////////////////////////////////////
     
     [self configurrePickerView];
     //    [self loadAD];
    /*
    // 画面上部に標準サイズのビューを作成する
    // 利用可能な広告サイズの定数値は GADAdSize.h で説明されている
    bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 20, 320, 50)];
    //        bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    
    // 広告ユニット ID を指定する
    bannerView_.adUnitID = @"ca-app-pub-2897992595879125/6438970498";
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する
    bannerView_.rootViewController = self;
    
    [self.view addSubview:bannerView_];
    
    // 一般的なリクエストを行って広告を読み込む
    [bannerView_ loadRequest:[GADRequest request]];
     */
    
}


#pragma mark プリセットタイム設定値を返す
-(NSInteger)presetTimes:(NSInteger)presetNumber{
    NSString* str_presetTimes = ary_PresetTimes[presetNumber];
    NSInteger presetTimes = [str_presetTimes intValue];
    NSLog(@"プリセットタイム　＝ %d",(int)presetTimes);
    return presetTimes;
    
}


-(void)setting_PresetTimers:(UIButton*)presetButton{
    NSLog(@"%s", __FUNCTION__);
    [self playSE1];
    // 呼ばれたプリセットボタン
    selected_PresetNum = presetButton.tag;
    
    
    _imageView.backgroundColor = _rainbowColors[presetButton.tag];
    if(!_isDispPicker){
        
        [self call_TimerPicker:presetButton];
        
    }
    
}
#pragma mark ピッカーを呼ぶ
-(void)call_TimerPicker:(UIButton*)presetButton{
    
    //-(void)call_TimerPicker:(NSInteger)time{
    NSLog(@"%s", __FUNCTION__);
    if(!_isDispPicker){
        
        [self disp_TimerPicker];
        
        // プリセット時間
        NSInteger time = [self presetTimes:presetButton.tag];
        NSInteger rowHour = [StopWatch secondToOnlyHour:time];
        
        [_pickerView selectRow:rowHour inComponent:0 animated:YES];
        // 分
        
        NSInteger rowMin = [StopWatch secondToOnlyMin:time];
        
        [_pickerView selectRow:rowMin inComponent:1 animated:YES];
        // 秒
        NSInteger rowSec = [StopWatch secondToOnlySec:time];
        
        [_pickerView selectRow:rowSec inComponent:2 animated:YES];
        
        
        
    }
}
#pragma mark ビッカーを表示準備
-(void)disp_TimerPicker{
    // ピッカーを乗せる土台
    NSLog(@"%s", __FUNCTION__);
    
    CGRect frame = CGRectMake(0, self.view.bounds.size.height, 320, 200);
    _myView = [[UIImageView alloc]initWithFrame:frame];
    
    _myView.backgroundColor = _rainbowColors[selected_PresetNum];
    //    _myView.backgroundColor = [UIColor orangeColor];
    _myView.alpha = 0.8f;
    _myView.userInteractionEnabled = YES;
    [self.view addSubview:_myView];
    
    
    
    _pickerView = [[UIPickerView alloc]init];
    _pickerView.center = CGPointMake(160,_myView.bounds.size.height/2);
    _pickerView.tintColor = [UIColor blackColor];
    
    
    // picker view delegate
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    _pickerView.showsSelectionIndicator = YES;
    [_myView addSubview:_pickerView];
    
    
    
    // Cancel Button
    
    _btn_cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btn_cancel.frame = CGRectMake(0, self.view.bounds.size.height, 160, 44);
    
    _btn_cancel.backgroundColor = [UIColor redColor];
    _btn_cancel.tag = kCANCEL;
    _btn_cancel.tintColor = [UIColor blackColor];
    [_btn_cancel setTitle:@"Cansel" forState:UIControlStateNormal];
    [_btn_cancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:35]];//文字の種類];
    
    [_btn_cancel addTarget:self action:@selector(action_Cancel:) forControlEvents:UIControlEventTouchUpInside];
    //        [button addTarget:self action:@selector(pushed_Button:)
    _btn_cancel.layer.borderColor = [UIColor wzy_silverFlatColor].CGColor;
    _btn_cancel.layer.borderWidth = 0.9f;
    _btn_cancel.layer.cornerRadius = 0.0f;
    
    
    [self.view addSubview:_btn_cancel];
    
    
    
    // SET Button
    //   [self make_PresetTimesSETButton];
    _btn_Set = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btn_Set.frame = CGRectMake(160, self.view.bounds.size.height, 160, 44);
    
    _btn_Set.backgroundColor = [UIColor blueColor];
    _btn_Set.tag = kSET;
    
    _btn_Set.tintColor = [UIColor whiteColor];
    
    [_btn_Set setTitle:@"SET" forState:UIControlStateNormal];
    [_btn_Set.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:35]];//文字の種類];
    
    [_btn_Set addTarget:self action:@selector(action_TimesSet:) forControlEvents:UIControlEventTouchUpInside];
    //        [button addTarget:self action:@selector(pushed_Button:) forControlEvents:UIControlEventTouchUpOutside];
    _btn_Set.layer.borderColor = [UIColor wzy_silverFlatColor].CGColor;
    _btn_Set.layer.borderWidth = 1.0f;
    _btn_Set.layer.cornerRadius = 0.0f;
    [self.view addSubview:_btn_Set];
    
    
    // ピッカーを表示
    [self dips_PickerView];
    
    //
}


-(void)dips_PickerView{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         // ピッカーを表示
                         _myView.center = CGPointMake(self.view.center.x, self.view.bounds.size.height-44-100);
                         //　キャンセルボタン　セットボタン
                         _btn_cancel.center = CGPointMake(80,self.view.bounds.size.height-22);
                         _btn_Set.center = CGPointMake(240,self.view.bounds.size.height-22);
                         
                     }completion:^(BOOL fubushed){
                         
                     }];
    _isDispPicker = YES;
    
}

#pragma mark ボタン押下処理
-(void)action_Cancel:(UIButton*)button{
    [self playSE1];
    [self pushButtonAction:button];
    NSLog(@"キャンセルボタン%d",(int)button.tag);
    [self hidden_PickerView];
    // プリセットを非選択　tag　999
    selected_PresetNum = 999;
    
}


-(void)action_TimesSet:(UIButton*)button{
    [self playSE1];
    [self pushButtonAction:button];
    if(newPresetTimes != 0){
        
        NSLog(@"プリセットタイマーボタン%d",(int)button.tag);
        //newPresetTimes
        NSLog(@"プリセットNo.%d %d秒に設定",(int)selected_PresetNum,(int)newPresetTimes);
        
        NSLog(@"OLD PresetTimes");
        //    for(NSString * str in ary_PresetTimes){
        //        NSLog(@"%@",str);
        //
        //    }
        // プリセットタイムの変更（置き換え）
        //指定した場所の要素を入れ替える
        //（例）リストの4番目の要素を"hoge"に入れ替える
        //　[mar replaceObjectAtIndex:3 withObject:@"hoge"];
        NSString* str_Times = [NSString stringWithFormat:@"%d",(int)newPresetTimes];
        
        [ary_PresetTimes replaceObjectAtIndex:selected_PresetNum withObject:str_Times];
        //    ary_PresetTimes[selected_PresetNum] = str_Times;
        
        NSLog(@"NEW PresetTimes");
        //    for(NSString * str in ary_PresetTimes){
        //        NSLog(@"%@",str);
        //    }
        
        //　保存
        NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
        [userDefult setObject:ary_PresetTimes forKey:@"PRESET_TIMES"];
        
        
        // ピッカーを非表示
        [self hidden_PickerView];
        
        //　プリセットボタンの再表示
        //        [self make_PresetButtons];
        [self change_PresetbuttonDisplayTimes:selected_PresetNum];
        // プリセットを非選択　tag　999
        selected_PresetNum = 999;
        
    }else{
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirmation"
                              
                                                       message:@"You did not change the preset time. Or set time is 00 seconds."
                                                      delegate:nil
                                             cancelButtonTitle:nil otherButtonTitles:@"Resetting", nil];
        
        [alert show];
    }
    
}
#pragma mark プリセットタイムボタンの表示時間を変更
-(void)change_PresetbuttonDisplayTimes:(NSInteger)presetButton{
    NSLog(@"%s", __FUNCTION__);
    
    //int presetTime = (int)newPresetTimes;
    
    NSInteger h = [StopWatch secondToOnlyHour:newPresetTimes];
    NSInteger m = [StopWatch secondToOnlyMin:newPresetTimes];
    NSInteger s = [StopWatch secondToOnlySec:newPresetTimes];
    NSString* str_PresetTime = [NSString stringWithFormat:@"%d:%02d:%02d",(int)h,(int)m,(int)s];
    [btn_presetTimes[presetButton]  setTitle:str_PresetTime forState:UIControlStateNormal];
    
    
    [self pushButtonAction_Rotation:btn_presetTimes[presetButton] rotationCount:5];
    
}

-(void)hidden_PickerView{
    NSLog(@"%s", __FUNCTION__);
    //　ピッカーを非表示にする
    if(_isDispPicker){
        [UIView animateWithDuration:0.3f
                         animations:^{
                             //   _imageView.center = CGPointMake(160, - _pickerView.frame.size.height/2);
                             
                             CGPoint point = CGPointMake(160, self.view.bounds.size.height+ _myView.frame.size.height/2);
                             _myView.center = point;
                             _btn_cancel.center = CGPointMake(80,self.view.bounds.size.height+BUTTON_SIZE);
                             _btn_Set.center = CGPointMake(240,self.view.bounds.size.height+BUTTON_SIZE);
                             
                             
                         }completion:^(BOOL fubushed){
                             
                         }];
        
        _isDispPicker = NO;
    }
    
}


// pickerview dalegate methed
//　UIPickerView にて各列の項目を選択したときにコールされる delegate メソッド

# pragma mark - UIPIkerView's Delegate
// 列(component)の数を返す
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // 時間、分、秒　表示するので３列を指定
    return 3;
}

// 列(component)に対する、行(row)の数を返す
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //    NSLog(@"%s", __FUNCTION__);
    switch (component) {
        case 0: // 年(1列目)の場合(配列と同じように0から始まる)
            return [ary_Hour count];   // 時のデータ数を返す
        case 1: // 月(2列目)の場合
            return [ary_Min count];  // 分のデータ数を返す
        case 2: // 月(2列目)の場合
            return [ary_Sec count];  // 分のデータ数を返す
            
    }
    return 0;
}

// 列(component)と行(row)に対応する文字列を返す
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    NSLog(@"%s", __FUNCTION__);
    switch (component) {
        case 0: // 年(1列目)の場合(配列と同じように0から始まる)
            return [NSString stringWithFormat:@"%d",[ary_Hour[row] intValue]];// 年のデータの列に対応した文字列を返す
        case 1: // 月(2列目)の場合
            return [NSString stringWithFormat:@"%02d",[ary_Min[row] intValue]];  // 分のデータの列に対応した文字列を返す
        case 2: // 月(3列目)の場合
            return [NSString stringWithFormat:@"%02d",[ary_Sec[row] intValue]];  // 秒のデータの列に対応した文字列を返す
    }
    return nil;
}


// PickerViewの操作が行われたときに呼ばれる
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row  inComponent:(NSInteger)component
//{

//    // PickerViewの選択されている年と月の列番号を取得
//    int rowOfYear  = (int)[pickerView selectedRowInComponent:0]; // 年を取得
//    int rowOfMonth = (int)[pickerView selectedRowInComponent:1];          // 月を取得
//   // ラベルに現在の日付を表示
//    self.dateLabel.text = [NSString stringWithFormat:@"西暦%@年%@月",
//                           [years objectAtIndex:rowOfYear], [months objectAtIndex:rowOfMonth]];
//}



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"%s", __FUNCTION__);
    
    int h = (int)[pickerView selectedRowInComponent:0]; // Hour
    int m = (int)[pickerView selectedRowInComponent:1]; // Min
    int s = (int)[pickerView selectedRowInComponent:2]; // Sec
    NSLog(@"%d時間 %02d分 %02d秒",h,m,s);
    // 秒に変換
    newPresetTimes = h*3600 + m*60 + s;
    NSLog(@"newPresetTimes = %d秒",(int)newPresetTimes);
    //    int total = h * 60 + m; //**分に変換
    
    
    //    str_presetTimes = [NSString stringWithFormat:@"%d",(int)presetTimes];
}
////////////////////////////////////////////////////////////////////////////////////


-(void)loadAD{
    /*
     NSLog(@"%s", __FUNCTION__);
     
     // 0から3乱数を生成
     int ad = arc4random_uniform(4);
     
     switch (ad) {
     case 0:
     NSLog(@"adMob");
     [self adMob];
     break;
     case 1:
     NSLog(@"nend");
     
     [self nendBunner];
     break;
     
     case 2:
     NSLog(@"i-mobile");
     
     [self imobileBanner];
     break;
     case 3:
     NSLog(@"iAd");
     [self iAD];
     //            NSLog(@"AppVador");
     //            [self AppVador];
     
     
     break;
     
     default:
     break;
     }
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
     [self playSE1];
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)actionStepper:(id)sender {
    if(self.segment_SEandVoice.selectedSegmentIndex != 0) [self playSE1];
    UIStepper *stepper = sender;

    
    self.firstStopWatchesCount.text = [NSString stringWithFormat:@"%d",(int)stepper.value];
    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    [userDefult setInteger:stepper.value
                    forKey:@"KEY_FIRST_STOP_WATCH"];
        NSLog(@"KEY_FIRST_STOP_WATCH = %d",(int)stepper.value);
}


- (IBAction)actionStepper_AlarmSoundRepeatCount:(id)sender {
    if(self.segment_SEandVoice.selectedSegmentIndex != 0) [self playSE1];
    UIStepper *stepper_AlarmSoundRepeatCount = sender;
    NSLog(@"AlarmSoundRepeatCount = %d",(int)stepper_AlarmSoundRepeatCount.value);
    
    self.alarmSoundRepeatCount.text = [NSString stringWithFormat:@"%d",(int)stepper_AlarmSoundRepeatCount.value];
    
    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    [userDefult setInteger:stepper_AlarmSoundRepeatCount.value forKey:@"KEY_ALARM_SOUND_REPEART_COUNT"];

}
- (IBAction)actionSegCon_SEandVoice:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex != 0) [self playSE1];

    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    [userDefult setInteger:sender.selectedSegmentIndex
     forKey:@"SOUND_EFFECT_SELECT"];
    NSLog(@"SOUND_EFFECT_SELECT = %d",(int)sender.selectedSegmentIndex);

}

#pragma mark 効果音
-(void)playSE1{
    //効果音再生
    if(self.stepper_AlarmSoundRepeatCount.value > 0){
        //      AudioServicesPlaySystemSound (soundID);
        //      AudioServicesPlaySystemSound(1035); //タイプライター
        AudioServicesPlaySystemSound(1104); //キーボードタップ音
        NSLog(@"SoundEffect");
    }
}

    
    
    
    -(void)change_SleepModeText{
        if(_isNotSleepMode){
            //        NSLog(@"スリープスイッチはON");
            _lbl_sleep.text = @"Do not Sleep";
            _lbl_sleep.textColor = [UIColor redColor];
        }else{
            //        NSLog(@"スリープスイッチはOFF");
            _lbl_sleep.text = @"Will Sleep";
            _lbl_sleep.textColor = [UIColor blueColor];
            
        }
    }
    
    

#pragma mark スリープスイッチ
- (IBAction)action_SleepSW:(UISwitch *)sender {
    if(sender.on){
        NSLog(@"スリープスイッチはON");
        //        _lbl_sleep.text = @"Do not Sleep";
        //        _lbl_sleep.textColor = [UIColor redColor];
        
        //ロック/スリープの禁止.
        NSLog(@"スリープしない");
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        _isNotSleepMode = YES;
        [self change_SleepModeText];
        
        
    }else{
        NSLog(@"スリープスイッチはOFF");
        //        _lbl_sleep.text = @"Will Sleep";
        //        _lbl_sleep.textColor = [UIColor blueColor];
        //ロック/スリープの禁止の解除.
        NSLog(@"スリープする");
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        _isNotSleepMode = NO;
        [self change_SleepModeText];
        
        
    }
    [self playSE1];
    //　保存
    NSUserDefaults* userDefult =  [NSUserDefaults standardUserDefaults];
    [userDefult setBool:_isNotSleepMode forKey:@"NON_SLEEP"];
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
}

-(void)pushButtonAction_Rotation_B:(UIButton*)button {
    //    for (int i = 0; i<count*2; i++) {
    
    
    [UIView animateWithDuration:0.7f delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         button.transform = CGAffineTransformScale(button.transform, 1 ,-1);
                         
                     }
                     completion:^(BOOL funished){
                         NSLog(@"回転終了");
                         
                     }];
    //   }
}

-(void)pushButtonAction_Rotation:(UIButton*)button rotationCount:(NSUInteger)count{
    //    for (int i = 0; i<count*2; i++) {
    
    
    [UIView animateWithDuration:0.7f delay:0.3f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         button.transform = CGAffineTransformScale(button.transform, 1 ,-1);
                         
                     }
                     completion:^(BOOL funished){
                         [self pushButtonAction_Rotation_B:button];
                         
                     }];
    //   }
}


-(void)pushButtonAction:(UIButton*)button{
    [UIView animateWithDuration:0.15f
                     animations:^{
                         button.transform = CGAffineTransformScale(button.transform, 1.5, 1.5);
                     }completion:^(BOOL finished){
                         
                         button.transform = CGAffineTransformScale(button.transform, 0.75, 0.75);
                     }];
}


@end
