//
//  RunningViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/22.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "RunningViewController.h"

#import "MenuDrawerViewController.h"
#import "AddDrawerViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"

@interface RunningViewController ()

@end

@implementation RunningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.alarmButton setTitle:@"スタート" forState:UIControlStateNormal];
    alarmFlag = TIMER_START;
    
    NSDate *now = [NSDate date];
    NSCalendar *calender = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *nowComponents = [calender components:flags fromDate:now];
    int hour = [nowComponents hour];
    int min = [nowComponents minute];
    
    //NSLog(@"%02d:%02d",hour,min);
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,min];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.goalValueLabel.text = [NSString stringWithFormat:@"%.02fkm", [ud floatForKey:@"GoalRunning"]];
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
    int hour = [nowComponents hour];
    int min = [nowComponents minute];
    
    //NSLog(@"%02d:%02d",hour,min);
    self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,min];
    //self.nowTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",hour,min];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alarmStartButtonAction:(UIButton *)sender {
    if(alarmFlag == TIMER_START){
        self.goalCaptionLabel.hidden = YES;
        self.leftButton.hidden = YES;
        self.rightButton.hidden = YES;
        self.timerLabel.hidden = NO;
        self.typeLabel.hidden = NO;
        self.unitLabel.hidden = NO;
        
        startTime = [NSDate date];
        
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        
        //今現在の歩数を取得
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [formatter stringFromDate:startTime];
        startStep = [dbHelper getCurrentStep:dayString];
        
        //最初にinsert
        [dbHelper insertRunDetail:0 startDateTime:startTime endDateTime:startTime];
        
        tm =[NSTimer
             scheduledTimerWithTimeInterval:1.0
             target:self
             selector:@selector(runSave:)
             userInfo:nil repeats:YES];
        
        [self.alarmButton setTitle:@"ストップ" forState:UIControlStateNormal];
        self.alarmButton.titleLabel.textColor = [UIColor redColor];
        alarmFlag = TIMER_STOP;
        
        self.goalValueLabel.hidden = YES;
        self.goalCaptionLabel.hidden = YES;
        self.currentValueLabel.hidden = NO;
        
        self.currentValueLabel.text = @"0.00km";
        
        steps = 0;
        
        if(![CMStepCounter isStepCountingAvailable]){
            //motionManager起動
            self.motionManager = [[CMMotionManager alloc] init];
            self.motionManager.accelerometerUpdateInterval =  1.0f/5.0f;
            
            [self startMoving];
        }
        
        //画面をフリップ回転させる
        UIView *tempView = [[UIView alloc] initWithFrame:self.view.frame];
        [UIView transitionFromView:self.view toView:tempView duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            [UIView transitionFromView:tempView toView:self.view duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
                
            }];
        }];
        
        //スリープしない
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }else{
        [tm invalidate];
        
        endTime = [NSDate date];
        
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        
        //ランニング中の歩数を取得
        int totalStep = steps;
        
        //データの更新
        [dbHelper updateRunDetail:totalStep startDateTime:startTime endDateTime:endTime];
        
        //タイムラインへの保存
        //日付の設定（日付はランニング開始の日）
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dateString = [formatter stringFromDate:endTime];
        //値を設定（走った距離）
        float totalDist = [self calcuDist:totalStep];
        NSString *value = [NSString stringWithFormat:@"%.2fkm", totalDist];
        //目標値から達成度を設定
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        int goalRunningDist = [ud integerForKey:@"GoalRunning"];
        int percent = totalDist * 100 / goalRunningDist;
        
        [dbHelper insertTimeline:dateString value:value percent:percent type:TIMELINE_TYPE_RUN];
        
        //サーバにも保存する
        NSString *userID = [ud objectForKey:@"UserID"];
        int shareActivity = [ud integerForKey:@"ShareActivity"];
        
        NSDateFormatter *phpFormatter = [[NSDateFormatter alloc] init];
        [phpFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSURL *url = [NSURL URLWithString:URL_INSERT_TIMELINE];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [request setTimeOutSeconds:60];
        [request setPostValue:userID forKey:@"UserID"];
        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"InsertCount"];
        [request setPostValue:[phpFormatter stringFromDate:startTime] forKey:@"TimeLineStartDateTime0"];
        [request setPostValue:[phpFormatter stringFromDate:endTime] forKey:@"TimeLineEndDateTime0"];
        [request setPostValue:value forKey:@"TimeLineValue0"];
        [request setPostValue:[NSNumber numberWithInt:percent] forKey:@"TimeLineAttainment0"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_TYPE_RUN] forKey:@"TimeLineType0"];
        [request setPostValue:[NSNumber numberWithInt:shareActivity] forKey:@"TimeLineShareStatus0"];
        [request setCompletionBlock:^{
            
            [self.alarmButton setTitle:@"スタート" forState:UIControlStateNormal];
            self.alarmButton.titleLabel.textColor = [UIColor colorWithRed:0.164 green:0.674 blue:0.435 alpha:1.0];
            alarmFlag = TIMER_START;
            
            self.goalValueLabel.hidden = NO;
            self.goalCaptionLabel.hidden = NO;
            self.currentValueLabel.hidden = YES;
            
            if(![CMStepCounter isStepCountingAvailable]){
                [self.motionManager stopAccelerometerUpdates];
            }
            
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

-(void)CMStepCount{
    //データ取得
    NSLog(@"*****");
    
    NSDate *now = [NSDate date];
    CMStepCounter *stepCounter = [[CMStepCounter alloc] init];
    [stepCounter queryStepCountStartingFrom:startTime
                                         to:now
                                    toQueue:[NSOperationQueue mainQueue]
                                withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                    steps = numberOfSteps;
                                    NSLog(@"%d",numberOfSteps);
                                    float dist =[self calcuDist:steps];
                                    self.currentValueLabel.text = [NSString stringWithFormat:@"%.2f",dist];
                                }];
}

//歩数と身長から歩行距離を計算
-(float)calcuDist:(int)step{
    float dist = 0;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    float height = [ud floatForKey:@"UserHeight"];
    float stride = height * 0.45;
    dist = (steps * stride) / 100000;
    
    return dist;
}

-(void)startMoving{
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData,NSError *error){
        CMAcceleration acceleration = accelerometerData.acceleration;
        
        //絶対値変換＆高周期除外処理
        xx = xx * 0.9 + fabs(acceleration.x) * 0.1;
        yy = yy * 0.9 + fabs(acceleration.y) * 0.1;
        zz = zz * 0.9 + fabs(acceleration.z) * 0.1;
        
        //三軸値合成
        float sumAcceleration = xx+yy+zz;
        
        //下限を超えたらカウントフラグon
        if(!counted && sumAcceleration < LowOldSumAcceleration){
            counted = TRUE;
        }
        
        //カウントフラグon後上限を超えた場合歩数カウント
        if(counted && sumAcceleration > HighOldAcceleration){
            counted = FALSE;
            double now = CFAbsoluteTimeGetCurrent();
            
            //誤カウント用バッファ
            if(now - pastTime > 0.1f){
                steps++;
                NSLog(@"steps:%d",steps);
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                float height = [ud floatForKey:@"UserHeight"];
                float stride = height * 0.45;
                float dist = (steps * stride) / 100000;
                self.currentValueLabel.text = [NSString stringWithFormat:@"%.2f",dist];
            }
        }
        
        //下限更新
        LowOldSumAcceleration = sumAcceleration - 0.02f;
        
        //上限更新
        HighOldAcceleration = sumAcceleration + 0.02f;
    }];
}

/***** バックグラウンド動作用位置情報処理 *****/
-(void)startLocationMonitoring{
    if(locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    locationManager.distanceFilter = 10000.0f;
    locationManager.pausesLocationUpdatesAutomatically = NO;
    
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"GPS");
}
/***** バックグラウンド動作用位置情報処理ここまで *****/

-(void)runSave:(NSTimer *)timer{
    NSLog(@"runSave");
    
    NSDate *today = [NSDate date];
    
    /***** 日にちフォーマット *****/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    todayString = [formatter stringFromDate:today];
    /***** 日にちフォーマット *****/
    NSLog(@"todayString:%@",todayString);
    
    //日にち取得
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
    int todayHour = [todayComponents hour];
    int todayMin = [todayComponents minute];
    
    int arrayIndex = todayHour * 6 + (todayMin/10);
    
    /***** DBよりデータ取得 *****/
    NSMutableDictionary *runs;
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    runs = [dbHelper selectDayRun:todayString];
    /***** DBよりデータ取得ここまで *****/
    
    /***** 睡眠配列 *****/
    runArray = [NSMutableArray array];
    //DBに睡眠配列がなかったら初期化して作成
    if(runs == nil){
        for(int ii = 0; ii < 144; ii++){
            [runArray addObject:@"0"];
        }
        
        [runArray replaceObjectAtIndex:arrayIndex withObject:@"1"];
        
        //ArrayをDBに保存する処理
        NSString *runValue = [runArray componentsJoinedByString:@","];
        [dbHelper insertRun:todayString value:runValue];
    }else{
        NSString *runValue = [runs objectForKey:@"run_value"];
        runArray = [runValue componentsSeparatedByString:@","];
        
        [runArray replaceObjectAtIndex:arrayIndex withObject:@"1"];
        //ArrayをDBに保存する処理(更新)
        runValue = [runArray componentsJoinedByString:@","];
        [dbHelper updateRun:todayString value:runValue];
    }
    /***** 睡眠配列ここまで *****/
    
    //M７チップ搭載端末判定
    if([CMStepCounter isStepCountingAvailable]){
        [self CMStepCount];
    }else{
        
    }
    
    NSLog(@"runArray");
}

- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)leftButtonAction:(id)sender {
}

- (IBAction)rightButtonAction:(id)sender {
}

@end
