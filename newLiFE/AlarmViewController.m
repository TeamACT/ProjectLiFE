//
//  AlarmViewController.m
//  isSleep
//
//  Created by 八幡 翔一 on 2014/04/23.
//  Copyright (c) 2014年 八幡 翔一. All rights reserved.
//

#import "AlarmViewController.h"

#import "MenuDrawerViewController.h"
#import "AddDrawerViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"

@interface AlarmViewController ()

@end

@implementation AlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.alarmButton setTitle:@"スタート" forState:UIControlStateNormal];
    alarmFlag = TIMER_START;
    
    inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *nowComponents = [calender components:flags fromDate:now];
    int hour = [nowComponents hour];
    int min = [nowComponents minute];
    
    //NSLog(@"%02d:%02d",hour,min);
    self.nowTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,min];
    
    self.timePicker.date = [NSDate date];
    
    NSDateFormatter *viewLabelFormatter = [[NSDateFormatter alloc] init];
    viewLabelFormatter.dateFormat = @"HH:mm";
    NSString *tmpAlarmString = [viewLabelFormatter stringFromDate:self.timePicker.date];
    //NSLog(@"tmpAlarmString:%@",tmpAlarmString);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Letmego" ofType:@"mp3"];
    NSURL *url =[NSURL fileURLWithPath:path];
    alarmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    alarmPlayer.numberOfLoops = -1;
    
    alarmEnabled = TRUE;
    alarmFlag = 0;
    /***** データ配列初期化処理ここまで *****/
    
    clock = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(Clock:)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [clock invalidate];
    clock = nil;
    [tm invalidate];
    tm = nil;
}

-(void)Clock:(NSTimer *)timer{
    NSLog(@"Clock");
    
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *nowComponents = [calender components:flags fromDate:now];
    hour = [nowComponents hour];
    min = [nowComponents minute];
    
    //NSLog(@"%02d:%02d",hour,min);
    self.nowTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,min];
    
    //NSLog(@"hour:%d min:%d alarmHour:%d alarmMin:%d",hour,min,alarmHour,alarmMin);
    
    if(alarmEnabled == TRUE){
        if(hour==alarmHour && min==alarmMin){
            [alarmPlayer play];
        }
    }
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)timePickerAction:(UIDatePicker *)sender {
    NSDateFormatter *viewLabelFormatter = [[NSDateFormatter alloc] init];
    viewLabelFormatter.dateFormat = @"HH:mm";
    NSString *tmpAlartString = [viewLabelFormatter stringFromDate:self.timePicker.date];
    NSLog(@"tmpAlartString:%@",tmpAlartString);
}

- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)leftButtonAction:(id)sender {
}

- (IBAction)rightButtonAction:(id)sender {
}

- (IBAction)alarmStartButtonAction:(UIButton *)sender {
    if(alarmFlag == TIMER_START){
        //睡眠保存処理開始
        beforeX = 0.0f;
        beforeY = 0.0f;
        badSleep = 0;
        
        bedTime = [NSDate date];
        
        //日にち取得
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned components = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *todayComponents = [calendar components:components fromDate:bedTime];
        int todayHour = [todayComponents hour];
        int todayMin = [todayComponents minute];
        
        beforeArrayIndex = todayHour * 6 + (todayMin / 10);
        
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        [dbHelper insertSleepDetail:bedTime endDateTime:bedTime];
        
        tm =[NSTimer
             scheduledTimerWithTimeInterval:1.0
             target:self
             selector:@selector(sleepSave:)
             userInfo:nil repeats:YES];
        
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 1.0f/1.0f;
        
        if(self.motionManager.accelerometerAvailable){
            NSOperationQueue *queue = [NSOperationQueue mainQueue];
            [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData,NSError *error){
                CMAcceleration acceleration = accelerometerData.acceleration;
                
                //nowTime = [NSDate date];
                
                float difX = fabsf(beforeX - acceleration.x);
                int intDifX = difX*1000000;
                
                // NSLog(@"intDif:%d",intDif);
                
                float difY = fabsf(beforeY - acceleration.y);
                int intDifY = difY*1000000;
                //NSLog(@"intDifX:%d intDifY:%d",intDifX,intDifY);
                
                // NSLog(@"intDif:%d",intDif);
                
                if(intDifX>6500){
                    badSleep = badSleep+1;
                    NSLog(@"badSleep:%d",badSleep);
                }
                
                if(intDifY>6500){
                    badSleep = badSleep+1;
                    NSLog(@"badSleep:%d",badSleep);
                }
                
                beforeX = acceleration.x;
                beforeY = acceleration.y;
            }];
        }
        
        NSCalendar *calender = [NSCalendar currentCalendar];
        unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *alarmComponents = [calender components:flags fromDate:self.timePicker.date];
        alarmHour = [alarmComponents hour];
        alarmMin = [alarmComponents minute];
        alarmEnabled = TRUE;
        
        [self.alarmButton setTitle:@"ストップ" forState:UIControlStateNormal];
        self.timePicker.hidden = YES;
        self.backButton.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
        self.nowTimeLabel.hidden = NO;
        self.timerLabel.hidden = NO;
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",alarmHour,alarmMin];
        self.typeLabel.hidden = NO;
        
        alarmFlag = TIMER_STOP;
        
        //画面をフリップ回転させる
        UIView *tempView = [[UIView alloc] initWithFrame:self.view.frame];
        [UIView transitionFromView:self.view toView:tempView duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            [UIView transitionFromView:tempView toView:self.view duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
                
            }];
        }];
        
        //スリープしない
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }else{
        if(self.motionManager.accelerometerActive){
            [self.motionManager stopAccelerometerUpdates];
        }
        
        riseTime = [NSDate date];
        
        //データの保存
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        
        //睡眠詳細の保存
        [dbHelper updateSleepDetail:bedTime endDateTime:riseTime];
        
        //タイムラインへの保存
        //日付の設定（日付は睡眠開始の日）
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dateString = [formatter stringFromDate:riseTime];
        //値を設定（ひとまず睡眠時間のみ）
        NSTimeInterval sleepTime = [riseTime timeIntervalSinceDate:bedTime];//秒に変換
        int sleepHour = sleepTime / (60 * 60);
        int sleepMinute = (sleepTime - sleepHour * 60 * 60) / 60;
        NSString *value = [NSString stringWithFormat:@"%d:%02d", sleepHour, sleepMinute];
        //目標値から達成度を設定
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
        int percent = sleepTime * 100 / goalSleepTime;
        
        [dbHelper insertTimeline:dateString value:value percent:percent type:TIMELINE_TYPE_SLEEP];
        
        //サーバへも保存
        NSString *userID = [ud objectForKey:@"UserID"];
        
        NSDateFormatter *phpFormatter = [[NSDateFormatter alloc] init];
        [phpFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSURL *url = [NSURL URLWithString:URL_INSERT_TIMELINE];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [request setTimeOutSeconds:60];
        [request setPostValue:userID forKey:@"UserID"];
        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"InsertCount"];
        [request setPostValue:[phpFormatter stringFromDate:bedTime] forKey:@"TimeLineStartDateTime0"];
        [request setPostValue:[phpFormatter stringFromDate:riseTime] forKey:@"TimeLineEndDateTime0"];
        [request setPostValue:value forKey:@"TimeLineValue0"];
        [request setPostValue:[NSNumber numberWithInt:percent] forKey:@"TimeLineAttainment0"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_TYPE_SLEEP] forKey:@"TimeLineType0"];
        [request setPostValue:[NSNumber numberWithInt:SHARE_CLOSED] forKey:@"TimeLineShareStatus0"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_ACHIEVE_ONCE] forKey:@"TimeLineAchieveKind0"];
        [request setCompletionBlock:^{
            [tm invalidate];
            
            [alarmPlayer stop];
            alarmEnabled = FALSE;
            
            [self.alarmButton setTitle:@"スタート" forState:UIControlStateNormal];
            self.timePicker.hidden = NO;
            self.backButton.hidden = NO;
            self.leftButton.hidden = NO;
            self.rightButton.hidden = NO;
            self.nowTimeLabel.hidden = YES;
            
            alarmFlag = TIMER_START;
            
            //スリープする
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            
            //日ログ画面に遷移
            [self dismissViewControllerAnimated:NO completion:^{
                UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
                self.slidingViewController.topViewController = newTopViewController;
                [self.slidingViewController resetTopViewAnimated:NO];
            }];
        }];
        [request setFailedBlock:^{
            
        }];
        [request startAsynchronous];
        
        
        
    }
}

-(void)sleepSave:(NSTimer *)timer{
    NSDate *today = [NSDate date];
    
    /***** 日にちフォーマット *****/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    todayString = [formatter stringFromDate:today];
    /***** 日にちフォーマット *****/
    NSLog(@"sleepSave");
    NSLog(@"todayString:%@",todayString);
    NSLog(@"badSleep:%d",badSleep);
    
    //日にち取得
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
    int todayHour = [todayComponents hour];
    int todayMin = [todayComponents minute];
    
    int arrayIndex = todayHour * 6 + (todayMin/10);
    
    if(arrayIndex != beforeArrayIndex){
        badSleep = 0;
    }
    
    beforeArrayIndex = arrayIndex;
    
    /***** DBよりデータ取得 *****/
    NSMutableDictionary *sleeps;
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    sleeps = [dbHelper selectDaySleep:todayString];
    /***** DBよりデータ取得ここまで *****/
    
    /***** 睡眠配列 *****/
    sleepArray = [NSMutableArray array];
    //DBに睡眠配列がなかったら初期化して作成
    if(sleeps == nil){
        for(int ii = 0; ii < 144; ii++){
            [sleepArray addObject:@"-1"];
        }
        
        [sleepArray replaceObjectAtIndex:arrayIndex withObject:[NSString stringWithFormat:@"%d",badSleep]];
        
        //sleepArrayをDBに保存する処理
        NSString *sleepValue = [sleepArray componentsJoinedByString:@","];
        [dbHelper insertSleep:todayString value:sleepValue];
    }else{
        NSString *sleepValue = [sleeps objectForKey:@"sleep_value"];
        sleepArray = [sleepValue componentsSeparatedByString:@","];
        
        [sleepArray replaceObjectAtIndex:arrayIndex withObject:[NSString stringWithFormat:@"%d",badSleep]];
        //stepArrayをDBに保存する処理(更新)
        sleepValue = [sleepArray componentsJoinedByString:@","];
        [dbHelper updateSleep:todayString value:sleepValue];
    }
    /***** 睡眠配列ここまで *****/
}

@end
