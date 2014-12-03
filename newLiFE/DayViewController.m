//
//  ViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "DayViewController.h"

#import "MenuDrawerViewController.h"
#import "AddDrawerViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"

@interface DayViewController ()

@end

@implementation DayViewController

@synthesize date;
@synthesize deviceType;
@synthesize dataValueType;
@synthesize pageIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //ナビゲーションバーの色とテキスト色を変更（全画面に適用）
    UIColor *barBackColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:barBackColor];
    UIColor *barItemColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    [[UIBarButtonItem appearance] setTintColor:barItemColor];
    
    //ナビゲーションバーの境界線を消す
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    //戻るボタンの画像を設定
    UIImage *backImg = [[UIImage imageNamed:@"LiFE_Common_BackButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    NSLog(@"queue:%@",queue);
    
    NSLog(@"*****************************************************");
    NSLog(@"date:%@",date);
    [[NSOperationQueue mainQueue] cancelAllOperations];
    
    NSLog(@"***** viewWillApear!! *****");
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSLog(@"name:%@",[ud stringForKey:@"UserName"]);
    NSLog(@"mail:%@",[ud stringForKey:@"UserMailAddress"]);
    NSLog(@"pass:%@",[ud stringForKey:@"UserPassword"]);
    
    if(deviceType == DEVICE_TYPE_IOS){
        NSArray *array = DATA_TYPES_IN_IOS;
        self.pageControl.numberOfPages = array.count;
        //pageIndex = 0;
        self.pageControl.currentPage = pageIndex;
    }
    
    //ピンチ操作準備
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    //タップ操作準備
    /*
     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
     tapGesture.delegate = self;
     [self.view addGestureRecognizer:tapGesture];
     */
    
    //パン操作準備
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    //バックグラウンド処理のため位置情報起動
    [self startLocationMonitoring];
    
    //日にち取得
    if(date == nil){
        date = [NSDate date];
    }
    
    /***** 5S以降の場合CMStepCounterを使用 *****/
    //M７チップ搭載端末判定
    if([CMStepCounter isStepCountingAvailable]){
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        
        saveStepArray = [NSMutableArray array];
        
        for(int ii = 0; ii < 144; ii++){
            [saveStepArray addObject:@"0"];
        }
        
        //CMStepCounter処理
        stepCounter = [[CMStepCounter alloc] init];
        [self startCMStepCounter:0 :0];
    }else{
        //motionManager起動
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval =  1.0f/5.0f;
        [self startMoving];
        
        //現在値用タイマー起動(自作ステップカウンター用のタイマー)
        tm = [NSTimer
              scheduledTimerWithTimeInterval:1.0
              target:self
              selector:@selector(drawNowData:)
              userInfo:nil repeats:YES];
    }
    /***** 5S以降の場合CMStepCounterを使用ここまで *****/
    
    //データ取得
    [self dataBaseAccess];
    
    //arrow表示
    [self drawArrow];
    
    //データ表示
    [self drawData];
    
    //データ数値表示
    [self drawDataValue:arrowIndex];
    
    //リザルト表示
    [self drawResult:arrowIndex];
    
    //アバターと背景の色を変える
    [self changeImageColor:arrowIndex];
    
    //アクティビティの描画
    [self drawActivity];
    
    //時計表示
    TimeGraphView *timeGraphView = [[TimeGraphView alloc] initWithFrame:self.nowActivityView.bounds];
    timeGraphView.date = date;
    [self.nowActivityView addSubview:timeGraphView];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[AddDrawerViewController class]]) {
        UIViewController *add =  [self.storyboard instantiateViewControllerWithIdentifier:@"add"];
        self.slidingViewController.underRightViewController = add;
    }
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    
    self.slidingViewController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [tm invalidate];
    tm = nil;
}

/**********/
//データ処理
/**********/

-(void)dataBaseAccess{
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:date];
    //NSString *formattedTodayString = [dataBaseFormatter stringFromDate:[NSDate date]];
    
    //DBよりデータ取得処理
    stepArray = [NSMutableArray array];
    sleepArray = [NSMutableArray array];
    runArray = [NSMutableArray array];
    photoArray = [NSMutableArray array];
    
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    steps = [dbHelper selectDayStep:formattedDataBaseString];
    sleeps = [dbHelper selectDaySleep:formattedDataBaseString];
    runs = [dbHelper selectDayRun:formattedDataBaseString];
    photoArray = [dbHelper selectDayPhoto:formattedDataBaseString];
    
    //dataStateArray作成
    if(steps != nil){
        NSString *stepValue = [steps objectForKey:@"step_value"];
        stepArray = [stepValue componentsSeparatedByString:@","];
    }else{
        for(int i = 0; i < 144; i++){
            [stepArray addObject:@"0"];
        }
    }
    
    //総歩数
    //stepCount = [NSString stringWithFormat:@"%@",[stepArray objectAtIndex:143]];
    
    if(sleeps != nil){
        NSString *sleepValue = [sleeps objectForKey:@"sleep_value"];
        sleepArray = [sleepValue componentsSeparatedByString:@","];
    }else{
        for(int i = 0; i < 144; i++){
            [sleepArray addObject:@"-1"];
        }
    }
    
    if(runs != nil){
        NSString *runValue = [runs objectForKey:@"run_value"];
        runArray = [runValue componentsSeparatedByString:@","];
    }else{
        for(int i = 0; i < 144; i++){
            [runArray addObject:@"0"];
        }
    }
    
    dataStateArray = [NSMutableArray array];
    
    for(int i = 0; i < 144; i++){
        if([[sleepArray objectAtIndex:i] intValue] > -1){
            [dataStateArray addObject:[NSString stringWithFormat:@"%d",DATA_STATE_TYPE_SLEEP]];
        }else if([[runArray objectAtIndex:i] intValue] > 0){
            [dataStateArray addObject:[NSString stringWithFormat:@"%d",DATA_STATE_TYPE_RUN]];
        }else{
            [dataStateArray addObject:[NSString stringWithFormat:@"%d",DATA_STATE_TYPE_STEP]];
        }
    }
}

-(int)calcuCalory:(int)value{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    float tall = [ud floatForKey:@"UserHeight"];
    float weight = [ud floatForKey:@"UserWeight"];
    
    //歩幅
    float stride = tall * 0.45;
    
    float dist = (value * stride) / 100000;
    int cal = dist * weight;
    
    return cal;
}

-(float)calcuBee:(int)index{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    float tall = [ud floatForKey:@"UserHeight"];
    float weight = [ud floatForKey:@"UserWeight"];
    
    //性別
    int gender = [ud integerForKey:@"UserGender"];
    
    //年齢
    NSDate *birthDate = [ud objectForKey:@"UserBirthDay"];
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:birthDate];
    int age = since / (24 * 60 * 60 * 365);
    
    //基礎代謝・睡眠時年齢補正係数
    float bee;
    float ageCoef;
    if(gender == GENDER_MALE){
        //基礎代謝
        bee = 66.5 + (13.8 * weight) + (5 * tall) - (6.8 * age);
        
        //睡眠時年齢補正係数
        if(age < 30){
            ageCoef = 1.0;
        }else if(age < 40 && age >29){
            ageCoef = 0.96;
        }else{
            ageCoef = 0.94;
        }
    }else{
        //基礎代謝
        bee = 655 + (9.6 * weight) + (1.8 * tall) - (4.7 * age);
        
        //睡眠時年齢補正係数
        if(age < 30){
            ageCoef = 0.95;
        }else if(age < 40 && age >29){
            ageCoef = 0.87;
        }else{
            ageCoef = 0.85;
        }
    }
    
    bee = ((bee * ageCoef) / 144) * index;
    
    return bee;
}

-(float)calcuDist:(int)value{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    float tall = [ud floatForKey:@"UserHeight"];
    
    //歩幅
    float stride = tall * 0.45;
    
    float dist = (value * stride) / 100000;
    
    return dist;
}

/**********/
//描画処理
/**********/

-(void)drawNowData:(NSTimer *)timer{
    NSDate *today = [NSDate date];
    
    /***** 日にちフォーマット *****/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    todayString = [formatter stringFromDate:today];
    prevDayString = [formatter stringFromDate:date];
    /***** 日にちフォーマット *****/
    
    /***** 5S以降の場合CMStepCounterを使用 *****/
    //M７チップ搭載端末判定
    if([CMStepCounter isStepCountingAvailable]){
        /*
         saveStepArray = [NSMutableArray array];
         
         for(int ii = 0; ii < 144; ii++){
         [saveStepArray addObject:@"0"];
         }
         
         //CMStepCounter処理
         stepCounter = [[CMStepCounter alloc] init];
         */
        [self startCMStepCounter:today];
    }
    /***** 5S以降の場合CMStepCounterを使用ここまで *****/
    
    if([todayString isEqualToString:prevDayString]){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *Components = [calendar components:flags fromDate:today];
        int hour = [Components hour];
        int min = [Components minute];
        
        int nowIndex = (hour * 6 + (min/10));
        //arrowMaxIndex = nowIndex;
        
        [self dataBaseAccess];
        
        [self drawNowActivity];
        
        if(arrowIndex == arrowMaxIndex){
            //データ数値表示
            [self drawDataValue:arrowIndex];
            
            //リザルト表示
            [self drawResult:arrowIndex];
        }
        
        if(nowIndex > arrowMaxIndex){
            arrowMaxIndex = nowIndex;
            date = today;
            
            //アクティビティの描画
            [self drawActivity];
        }
        //時計表示
        TimeGraphView *timeGraphView = [[TimeGraphView alloc] initWithFrame:self.nowActivityView.bounds];
        timeGraphView.date = date;
        [self.nowActivityView addSubview:timeGraphView];
    }
}

-(void)drawData{
    for(UIView *subview in [self.drawDataView subviews]){
        [subview removeFromSuperview];
    }
    
    /***** 日にちフォーマット *****/
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.dateFormat = @"MM";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd";
    
    NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
    weekdayFormatter.dateFormat = @"EE";
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    /***** 日にちフォーマット *****/
    
    /***** 日付表示用処理 *****/
    NSString *formattedMonthString = [monthFormatter stringFromDate:date];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    NSString *formattedWeekDayString = [weekdayFormatter stringFromDate:date];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 320, 25)];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:17];
    dateLabel.text = [NSString stringWithFormat:@"%@月%@日 (%@)",formattedMonthString,formattedDateString,formattedWeekDayString];
    [self.drawDataView addSubview:dateLabel];
    
    /*
     NSString *formattedWeekDayString = [weekdayFormatter stringFromDate:date];
     UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 24, 100, 25)];
     weekdayLabel.textAlignment = NSTextAlignmentLeft;
     weekdayLabel.font = [UIFont systemFontOfSize:17];
     weekdayLabel.text = [NSString stringWithFormat:@" (%@)",formattedWeekDayString];
     [self.drawDataView addSubview:weekdayLabel];
     */
    /***** 日付表示用処理ここまで *****/
    
    /***** 写真取得・表示処理 *****/
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image/"];
    
    for(int i = 0; i < photoArray.count; i++){
        NSMutableDictionary *photoDic = [photoArray objectAtIndex:i];
        int photoIndex = [[photoDic objectForKey:@"photo_index"] intValue];
        
        float angle = 270 + 2.5 * photoIndex;
        
        if(angle > 360){
            angle = 2.5 * photoIndex - 90;
        }
        
        float radian = angle * M_PI / 180;
        
        double cosX = cos(radian);
        
        double x = 160 * cosX;
        
        double sinY = sin(radian);
        
        double y = 160 * sinY;
        
        NSString *photoPath = [photoDic objectForKey:@"photo_path"];
        
        NSString *filePath = [dirPath stringByAppendingPathComponent:photoPath];
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake((160 + x - 15), (220 + y - 15), 30, 30)];
        //[imageButton setBackgroundImage:image forState:UIControlStateNormal];
        [imageButton setImage:image forState:UIControlStateNormal];
        
        imageButton.layer.cornerRadius = imageButton.frame.size.width * 0.5f;
        imageButton.clipsToBounds = YES;
        
        [imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.drawDataView addSubview:imageButton];
    }
    /***** 写真取得・表示処理 *****/
    
    [SVProgressHUD dismiss];
}

-(void)drawArrow{
    //arrowImageView配置
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *Components = [calendar components:flags fromDate:date];
    int hour = [Components hour];
    int min = [Components minute];
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSString *arrowDateString = [dataBaseFormatter stringFromDate:date];
    NSString *arrowTodayString = [dataBaseFormatter stringFromDate:[NSDate date]];
    
    if([arrowDateString isEqualToString:arrowTodayString]){
        arrowMaxIndex = (hour * 6 + (min/10));
        arrowIndex = arrowMaxIndex;
    }else{
        arrowMaxIndex = 143;
        arrowIndex = arrowMaxIndex;
    }
    
    float angle = 2.5 * arrowMaxIndex;
    float radian = angle * M_PI / 180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    self.arrowImageView.transform = transform;
}

-(void)drawActivity{
    for(UIView *subview in [self.activityView subviews]){
        [subview removeFromSuperview];
    }
    
    //アクティビティを描画
    ActivityMarkView *activityMarkView = [[ActivityMarkView alloc] initWithFrame:self.activityView.bounds];
    activityMarkView.date = date;
    activityMarkView.dataValueType = dataValueType;
    activityMarkView.steps = steps;
    activityMarkView.sleeps = sleeps;
    activityMarkView.runs = runs;
    [self.activityView addSubview:activityMarkView];
}

-(void)drawNowActivity{
    for(UIView *subview in [self.nowActivityView subviews]){
        [subview removeFromSuperview];
    }
    
    //アクティビティを描画
    NowActivityMarkView *nowActivityMarkView = [[NowActivityMarkView alloc] initWithFrame:self.nowActivityView.bounds];
    nowActivityMarkView.date = [NSDate date];
    nowActivityMarkView.dataValueType = dataValueType;
    nowActivityMarkView.steps = steps;
    nowActivityMarkView.sleeps = sleeps;
    nowActivityMarkView.runs = runs;
    [self.nowActivityView addSubview:nowActivityMarkView];
}

-(void)drawDataValue:(int)index{
    for(UIView *subview in [self.drawView subviews]){
        [subview removeFromSuperview];
    }
    
    int dataStateType = [[dataStateArray objectAtIndex:index] intValue];
    
    if(dataStateType == DATA_STATE_TYPE_STEP){
        //歩数
        stepCount = [[stepArray objectAtIndex:index] intValue];
        
        if(dataValueType == DATA_VALUE_TYPE_STEP){
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithInt:stepCount];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"歩数";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
            //カロリー表示
            
            float tCal = [self calcuCalory:stepCount];
            float bee = [self calcuBee:arrowIndex];
            
            tCal = tCal + bee;
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:tCal];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 0;
            nf.maximumFractionDigits = 0;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@kcal",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"カロリー";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_DIST){
            float dist = [self calcuDist:stepCount];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:dist];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@km",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"距離";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_RUN){
            float dist = [self calcuDist:stepCount];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:dist];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@km",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"ランニング";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }
    }else if(dataStateType == DATA_STATE_TYPE_RUN){
        //歩数
        stepCount = [[stepArray objectAtIndex:index] intValue];
        
        if(dataValueType == DATA_VALUE_TYPE_STEP){
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            //valueLabel.font = [UIFont systemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithInt:stepCount];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"歩数";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
            //カロリー表示
            float cal = [self calcuCalory:stepCount];
            
            float bee = [self calcuBee:arrowIndex];
            
            float tCal = cal + bee;
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:tCal];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 0;
            nf.maximumFractionDigits = 0;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@kcal",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"カロリー";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_DIST){
            float dist = [self calcuDist:stepCount];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:dist];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@km",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"距離";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else if(dataValueType == DATA_VALUE_TYPE_RUN){
            float dist = [self calcuDist:stepCount];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:dist];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@km",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"ランニング";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }
    }else if(dataStateType == DATA_STATE_TYPE_SLEEP){
        if(dataValueType == DATA_VALUE_TYPE_RUN){
            float dist = [self calcuDist:stepCount];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:dist];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            valueLabel.text = [NSString stringWithFormat:@"%@km",valueString];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_TYPE_LABEL_X, DATA_TYPE_LABEL_Y, 150, 25)];
            typeLabel.font = [UIFont systemFontOfSize:11];
            typeLabel.textColor = [UIColor blackColor];
            typeLabel.text = @"ランニング";
            typeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:typeLabel];
        }else{
            //睡眠値
            //int sleepCount = [[sleepArray objectAtIndex:index] intValue];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_VALUE_LABEL_X, DATA_VALUE_LABEL_Y, 150, 25)];
            valueLabel.font = [UIFont boldSystemFontOfSize:18];
            valueLabel.textColor = [UIColor blackColor];
            /*
             NSNumber *valueNumber = [[NSNumber alloc] initWithInt:stepCount];
             NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
             [nf setNumberStyle:NSNumberFormatterDecimalStyle];
             [nf setGroupingSeparator:@","];
             [nf setGroupingSize:3];
             NSString *valueString = [nf stringFromNumber:valueNumber];
             valueLabel.text = valueString;
             */
            valueLabel.text = @"睡眠";
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawView addSubview:valueLabel];
            
            /*
             UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 315, 150, 25)];
             typeLabel.font = [UIFont systemFontOfSize:11];
             typeLabel.textColor = [UIColor blackColor];
             typeLabel.text = @"睡眠";
             typeLabel.textAlignment = NSTextAlignmentCenter;
             [self.drawView addSubview:typeLabel];
             */
        }
    }
}

-(void)drawResult:(int)index{
    for(UIView *subview in [self.drawResultView subviews]){
        [subview removeFromSuperview];
    }
    
    int dataStateType = [[dataStateArray objectAtIndex:index] intValue];
    float value,goal;
    int per;
    
    NSString *resultString;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    stepCount = [[stepArray objectAtIndex:index] intValue];
    
    if(dataStateType == DATA_STATE_TYPE_SLEEP){
        //現在矢印が選んでいるのが睡眠の場合
        if(dataValueType == DATA_VALUE_TYPE_RUN){
            //表示内容がランニング
            //なにも表示しない
        }else{
            //表示内容が歩数、距離、カロリー
            //睡眠の詳細を表示する
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(65, 424, 190, 25)];
            label.font = [UIFont boldSystemFontOfSize:12];
            label.textColor = [UIColor whiteColor];
            label.text = @"睡眠時間";
            label.textAlignment = NSTextAlignmentCenter;
            [self.drawResultView addSubview:label];
            
            NSDateFormatter *fm = [[NSDateFormatter alloc] init];
            fm.dateFormat = @"yyyy-MM-dd";
            NSString *dateString = [fm stringFromDate:date];
            int hour = arrowIndex / 6;
            int min = (arrowIndex % 6) * 10;
            NSString *dateTimeString = [NSString stringWithFormat:@"%@ %d:%d",dateString,hour,min];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *dateTime = [formatter dateFromString:dateTimeString];
            
            DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
            NSMutableDictionary *sleepDetail = [NSMutableDictionary dictionary];
            sleepDetail = [dbHelper selectDaySleepDetail:dateTime];
            NSLog(@"sleepDetail:%@",sleepDetail);
            
            NSDate *bedTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[sleepDetail objectForKey:@"start_datetime"] floatValue]];
            NSDate *riseTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[sleepDetail objectForKey:@"end_datetime"] floatValue]];
            
            //睡眠時間
            NSTimeInterval sleepTime = [riseTime timeIntervalSinceDate:bedTime] / 60;
            int sleepHour = sleepTime / 60;
            int sleepMinute = sleepTime - (sleepHour * 60);
            UILabel *sleepTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 450, 190, 25)];
            sleepTimeLabel.font = [UIFont boldSystemFontOfSize:30];
            sleepTimeLabel.textColor = [UIColor whiteColor];
            sleepTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", sleepHour, sleepMinute];
            sleepTimeLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawResultView addSubview:sleepTimeLabel];
            
            NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:9.0f] };
            NSDictionary *stringAttributes2 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:18.0f] };
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            //就寝時間
            NSDateComponents *bedDateComps = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:bedTime];
            NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"就寝 " attributes:stringAttributes1];
            NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02d:%02d", bedDateComps.hour, bedDateComps.minute] attributes:stringAttributes2];
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
            [mutableAttributedString appendAttributedString:string1];
            [mutableAttributedString appendAttributedString:string2];
            
            UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 480, 190, 25)];
            startLabel.attributedText = mutableAttributedString;
            startLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawResultView addSubview:startLabel];
            
            //起床時間
            NSDateComponents *riseDateComps = [calendar components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:riseTime];
            NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:@"起床 " attributes:stringAttributes1];
            NSAttributedString *string4 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02d:%02d", riseDateComps.hour, riseDateComps.minute] attributes:stringAttributes2];
            NSMutableAttributedString *mutableAttributedString2 = [[NSMutableAttributedString alloc] init];
            [mutableAttributedString2 appendAttributedString:string3];
            [mutableAttributedString2 appendAttributedString:string4];
            
            UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 500, 190, 25)];
            endLabel.attributedText = mutableAttributedString2;
            endLabel.textAlignment = NSTextAlignmentCenter;
            [self.drawResultView addSubview:endLabel];
        }
    }else{
        //現在矢印が選んでいるのが通常の活動値、ランニングの場合
        if(dataValueType == DATA_VALUE_TYPE_STEP){
            //どこを選択していても歩数の情報を表示
            value = [[stepArray objectAtIndex:arrowIndex] floatValue];
            goal = [ud integerForKey:@"GoalSteps"];
            per = (value / goal) * 100;
            NSNumber *valueNumber = [[NSNumber alloc] initWithInt:value];
            NSNumber *goalNumber = [[NSNumber alloc] initWithInt:goal];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            NSString *valueString = [nf stringFromNumber:valueNumber];
            NSString *goalString = [nf stringFromNumber:goalNumber];
            resultString = [NSString stringWithFormat:@"%@ / %@ 歩", valueString, goalString];
            
            [self showResultGraph:resultString percent:per];
        }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
            //どこを選択していてもカロリーの情報を表示
            float cal = [self calcuCalory:[[stepArray objectAtIndex:arrowIndex] floatValue]];
            float bee = [self calcuBee:arrowIndex];
            value = cal + bee;
            goal = [ud floatForKey:@"GoalCalory"];
            per = (value / goal) * 100;
            NSNumber *valueNumber = [[NSNumber alloc] initWithInt:value];
            NSNumber *calNumber = [[NSNumber alloc] initWithInt:cal];
            NSNumber *beeNumber = [[NSNumber alloc] initWithInt:bee];
            NSNumber *goalNumber = [[NSNumber alloc] initWithInt:goal];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            NSString *valueString = [nf stringFromNumber:valueNumber];
            NSString *calString = [nf stringFromNumber:calNumber];
            NSString *beeString = [nf stringFromNumber:beeNumber];
            NSString *goalString = [nf stringFromNumber:goalNumber];
            resultString = [NSString stringWithFormat:@"%@ / %@ kcal",valueString,goalString];
            
            NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:9.0f] };
            NSDictionary *stringAttributes2 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                 NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
            NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"(活動)" attributes:stringAttributes1];
            NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ + %@ ",calString,beeString] attributes:stringAttributes2];
            NSAttributedString *string3 = [[NSAttributedString alloc] initWithString:@"(基礎)" attributes:stringAttributes1];
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
            [mutableAttributedString appendAttributedString:string1];
            [mutableAttributedString appendAttributedString:string2];
            [mutableAttributedString appendAttributedString:string3];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_LABEL_X, DATA_RESULT_LABEL_Y + 20, 190, 25)];
            //label.font = [UIFont boldSystemFontOfSize:14];
            //label.textColor = [UIColor whiteColor];
            label.attributedText = mutableAttributedString;
            label.textAlignment = NSTextAlignmentCenter;
            [self.drawResultView addSubview:label];
            
            [self showResultGraph:resultString percent:per];
        }else if(dataValueType == DATA_VALUE_TYPE_DIST){
            //どこを選択していても距離の情報を表示
            value = [self calcuDist:[[stepArray objectAtIndex:arrowIndex] floatValue]];
            goal = [ud floatForKey:@"GoalDistance"];
            per = (value / goal) * 100;
            NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:value];
            NSNumber *goalNumber = [[NSNumber alloc] initWithFloat:goal];
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            [nf setNumberStyle:NSNumberFormatterDecimalStyle];
            [nf setGroupingSeparator:@","];
            [nf setGroupingSize:3];
            nf.minimumFractionDigits = 2;
            nf.maximumFractionDigits = 2;
            NSString *valueString = [nf stringFromNumber:valueNumber];
            NSString *goalString = [nf stringFromNumber:goalNumber];
            resultString = [NSString stringWithFormat:@"%@ / %@ km",valueString,goalString];
            
            [self showResultGraph:resultString percent:per];
        }else if(dataValueType == DATA_VALUE_TYPE_RUN){
            //ランニングの詳細を表示する
            if(dataStateType == DATA_STATE_TYPE_RUN){
                //ランニングをした時点を選択していたら結果を表示する
        
                //選択している時間からランニングの詳細を取得
                NSDateFormatter *fm = [[NSDateFormatter alloc] init];
                fm.dateFormat = @"yyyy-MM-dd";
                NSString *dateString = [fm stringFromDate:date];
                int hour = arrowIndex / 6;
                int min = (arrowIndex % 6) * 10;
                NSString *dateTimeString = [NSString stringWithFormat:@"%@ %d:%d",dateString,hour,min];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSDate *dateTime = [formatter dateFromString:dateTimeString];
                
                DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
                NSMutableDictionary *runDetail = [dbHelper selectDayRunDetail:dateTime];
                
                //歩数から距離を計算
                int runStep = [[runDetail objectForKey:@"run_step"] intValue];
                float runDist = [self calcuDist:runStep];
                
                NSDate *startTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[runDetail objectForKey:@"start_datetime"] floatValue]];
                NSDate *endTime = [[NSDate alloc] initWithTimeIntervalSince1970:[[runDetail objectForKey:@"end_datetime"] floatValue]];
                
                goal = [ud floatForKey:@"GoalDistance"];
                per = (runDist / goal) * 100;
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:runDist];
                NSNumber *goalNumber = [[NSNumber alloc] initWithFloat:goal];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                NSString *valueString = [nf stringFromNumber:valueNumber];
                NSString *goalString = [nf stringFromNumber:goalNumber];
                resultString = [NSString stringWithFormat:@"%@ / %@ km",valueString,goalString];
                
                //ランニング時間
                NSTimeInterval runSecond = [endTime timeIntervalSinceDate:startTime];
                int runMinute = runSecond / 60;
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, DATA_RESULT_LABEL_Y + 20, 190, 25)];
                timeLabel.font = [UIFont boldSystemFontOfSize:14];
                timeLabel.textColor = [UIColor whiteColor];
                timeLabel.text = [NSString stringWithFormat:@"%d分", runMinute];
                timeLabel.textAlignment = NSTextAlignmentLeft;
                [self.drawResultView addSubview:timeLabel];
                
                //時速
                float speed = runDist * 60 * 60 / runSecond;
                NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                     NSFontAttributeName:[UIFont systemFontOfSize:9.0f] };
                NSDictionary *stringAttributes2 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                                     NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f", speed] attributes:stringAttributes2];
                NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:@"km/h" attributes:stringAttributes1];
                
                NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
                [mutableAttributedString appendAttributedString:string1];
                [mutableAttributedString appendAttributedString:string2];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(160, DATA_RESULT_LABEL_Y + 20, 190, 25)];
                label.attributedText = mutableAttributedString;
                label.textAlignment = NSTextAlignmentLeft;
                [self.drawResultView addSubview:label];
                
                [self showResultGraph:resultString percent:per];
            } else {
                //ランニングをしていない時点はなにも表示しない
            }
            
        }
        
    }
}

-(void)showResultGraph:(NSString *)result percent:(int)percent{
    
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_LABEL_X, DATA_RESULT_LABEL_Y, 190, 25)];
    resultLabel.font = [UIFont boldSystemFontOfSize:18];
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.text = result;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.drawResultView addSubview:resultLabel];
    
    if(percent < 100){
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_PER_LABEL_X, DATA_RESULT_PER_LABEL_Y, 36, 60)];
        valueLabel.font = [UIFont boldSystemFontOfSize:30];
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.text = [NSString stringWithFormat:@"%d", percent];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.drawResultView addSubview:valueLabel];
        
        UILabel *perLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_PER_MARK_LABEL_X, DATA_RESULT_PER_MARK_LABEL_Y, 20, 25)];
        perLabel.font = [UIFont boldSystemFontOfSize:12];
        perLabel.textColor = [UIColor whiteColor];
        perLabel.text = @"%";
        perLabel.textAlignment = NSTextAlignmentCenter;
        [self.drawResultView addSubview:perLabel];
        
        ResultGraphView *resultGraphView = [[ResultGraphView alloc] initWithFrame:self.drawResultView.bounds];
        resultGraphView.value = percent;
        [self.drawResultView addSubview:resultGraphView];
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(65, 475, 190, 25)];
        label.font = [UIFont boldSystemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.text = @"目標達成！";
        label.textAlignment = NSTextAlignmentCenter;
        [self.drawResultView addSubview:label];
        
        UIImage *image = [UIImage imageNamed:@"LiFE_GoalMark_Day"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(125, 411, 70, 64);
        
        [self.drawResultView addSubview:imageView];
    }
}

-(void)changeImageColor:(int)index{
    //アバターと背景の色を変える
    int dataState = [[dataStateArray objectAtIndex:index] intValue];
    NSArray *lightColors = [NSArray array];
    NSArray *darkColors = [NSArray array];
    NSString *animationPrefix;
    NSInteger animationFrames;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int gender = [ud integerForKey:@"UserGender"];
    
    if(dataValueType == DATA_VALUE_TYPE_RUN){
        self.leftCommonButton.hidden = NO;
        [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Red"] forState:UIControlStateNormal];
        //self.leftCommonButton.imageView.image = [UIImage imageNamed:@"LiFE_Left_GoalButton"];
        
        lightColors = RGB_RED_LIGHT;
        darkColors = RGB_RED_DARK;
        
        //アニメーションの設定
        animationFrames = 11;
        
        if(gender == GENDER_MALE){
            animationPrefix = @"LiFE_Avatar_ManRunning_large";
        }else{
            animationPrefix = @"LiFE_Avatar_WomanRunning_large";
        }
    }else{
        switch(dataState) {
            case DATA_STATE_TYPE_STEP:{
                int beforei = index - 1;
                
                int before;
                
                if(beforei < 0){
                    before = 0;
                }else{
                    before = [[stepArray objectAtIndex:beforei] intValue];
                }
                
                int now = [[stepArray objectAtIndex:index] intValue];
                int value = now-before;
                
                if(value > 300){
                    self.leftCommonButton.hidden = NO;
                    [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Orange"] forState:UIControlStateNormal];
                    
                    lightColors = RGB_ORANGE_LIGHT;
                    darkColors = RGB_ORANGE_DARK;
                    
                    //アニメーションの設定
                    animationFrames = 16;
                    
                    if(gender == GENDER_MALE){
                        animationPrefix = @"LiFE_Avatar_ManWalking_large";
                    }else{
                        animationPrefix = @"LiFE_Avatar_WomanWalking_large";
                    }
                }else{
                    self.leftCommonButton.hidden = NO;
                    [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Green"] forState:UIControlStateNormal];
                    
                    lightColors = RGB_GREEN_LIGHT;
                    darkColors = RGB_GREEN_DARK;
                    
                    //アニメーションの設定
                    animationFrames = 1;
                    
                    if(gender == GENDER_MALE){
                        animationPrefix = @"LiFE_Avatar_ManStop_large";
                    }else{
                        animationPrefix = @"LiFE_Avatar_WomanStop_large";
                    }
                }
                
                break;
            }
            case DATA_STATE_TYPE_RUN:{
                self.leftCommonButton.hidden = NO;
                [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Red"] forState:UIControlStateNormal];
                
                lightColors = RGB_RED_LIGHT;
                darkColors = RGB_RED_DARK;
                
                //アニメーションの設定
                animationFrames = 11;
                
                if(gender == GENDER_MALE){
                    animationPrefix = @"LiFE_Avatar_ManRunning_large";
                }else{
                    animationPrefix = @"LiFE_Avatar_WomanRunning_large";
                }
                
                break;
            }
            case DATA_STATE_TYPE_SLEEP:{
                self.leftCommonButton.hidden = YES;
                
                int value = [[sleepArray objectAtIndex:arrowIndex] intValue];
                
                if(value > 80){
                    lightColors = RGB_PURPLE_LIGHT;
                    darkColors = RGB_PURPLE_DARK;
                }else if(value < 38){
                    lightColors = RGB_BLUE_LIGHT;
                    darkColors = RGB_BLUE_DARK;
                }else{
                    lightColors = RGB_AQUA_LIGHT;
                    darkColors = RGB_AQUA_DARK;
                }
                
                //アニメーションの設定
                animationFrames = 1;
                
                if(gender == GENDER_MALE){
                    animationPrefix = @"LiFE_Avatar_ManStop_large";
                }else{
                    animationPrefix = @"LiFE_Avatar_WomanStop_large";
                }
                
                break;
            }
        }
    }
    
    NSInteger animationRepeatNum = 0;
    
    NSArray *animationLocations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0], nil];
    NSArray *animationColors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithRed:[[darkColors objectAtIndex:0] floatValue] green:[[darkColors objectAtIndex:1] floatValue] blue:[[darkColors objectAtIndex:2] floatValue] alpha:1.0f].CGColor,
                                (id)[UIColor colorWithRed:[[lightColors objectAtIndex:0] floatValue] green:[[lightColors objectAtIndex:1] floatValue] blue:[[lightColors objectAtIndex:2] floatValue] alpha:1.0f].CGColor, nil];
    NSMutableArray *animationImageArray = [NSMutableArray array];
    for (int i = 0; i < animationFrames; i++) {
        UIImage *image = [self getGradientImage:[NSString stringWithFormat:@"%@%03d.png", animationPrefix, i] colors:animationColors locations:animationLocations];
        
        [animationImageArray addObject:image];
    }
    self.avatarView.animationImages = animationImageArray;
    self.avatarView.animationDuration = animationFrames / 10.0f;
    self.avatarView.animationRepeatCount = animationRepeatNum;
    [self.avatarView startAnimating];
    
    NSArray *bottomLocations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0], nil];
    NSArray *bottomColors = [NSArray arrayWithObjects:
                             (id)[UIColor colorWithRed:[[lightColors objectAtIndex:0] floatValue] green:[[lightColors objectAtIndex:1] floatValue] blue:[[lightColors objectAtIndex:2] floatValue] alpha:1.0f].CGColor,
                             (id)[UIColor colorWithRed:[[darkColors objectAtIndex:0] floatValue] green:[[darkColors objectAtIndex:1] floatValue] blue:[[darkColors objectAtIndex:2] floatValue] alpha:1.0f].CGColor,nil];
    self.backgroundBottomView.image = [self getGradientImage:@"LiFE_Background_Bottom" colors:bottomColors locations:bottomLocations];
    
    self.backgroundView.image = [self.backgroundView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backgroundView.tintColor = [UIColor colorWithRed:[[lightColors objectAtIndex:0] floatValue] green:[[lightColors objectAtIndex:1] floatValue] blue:[[lightColors objectAtIndex:2] floatValue] alpha:1.0f];
    
    self.arrowImageView.image = [self.arrowImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrowImageView.tintColor = [UIColor colorWithRed:[[lightColors objectAtIndex:0] floatValue] green:[[lightColors objectAtIndex:1] floatValue] blue:[[lightColors objectAtIndex:2] floatValue] alpha:1.0f];
    
    /*
     self.leftCommonButton.imageView.image = [self.leftCommonButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
     self.leftCommonButton.imageView.tintColor = [UIColor colorWithRed:[[lightColors objectAtIndex:0] floatValue] green:[[lightColors objectAtIndex:1] floatValue] blue:[[lightColors objectAtIndex:2] floatValue] alpha:1.0f];
     */
}

//UIImageをグラデーションで塗りつぶす
-(UIImage *)getGradientImage:(NSString *)imageName colors:(NSArray *)colors locations:(NSArray *)locations{
    UIImage *image = [UIImage imageNamed:imageName];
    
    //一度UIImageViewで描画する
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    //レイヤーをマスキングする
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = imageView.bounds;
    maskLayer.contents = (__bridge id)([image CGImage]);
    [imageView.layer setMask:maskLayer];
    //グラデーションのレイヤーを配置
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = imageView.bounds;
    gradientLayer.locations = locations;
    gradientLayer.colors = colors;
    [imageView.layer addSublayer:gradientLayer];
    
    //UIImageViewで描画されているものをUIImageに変換
    UIGraphicsBeginImageContext(imageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [imageView.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)changeBackgroundColor:(NSArray *)colors locations:(NSArray *)locations tintColor:(UIColor *)tintColor{
    UIImage *backgroundImage = self.backgroundView.image;
    backgroundImage = [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backgroundView.image = backgroundImage;
    self.backgroundView.tintColor = tintColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**********/
//UI関係処理
/*********/

-(void)pinchGesture:(UIPinchGestureRecognizer *)sender
{
    NSLog(@"pinch:%f velocity:%f",[sender scale],[sender velocity]);
    
    //メニューが出てる時は機能しない
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) return;
    
    if(sender.state == UIGestureRecognizerStateEnded){
        if(1 < [sender scale]){
            NSLog(@"ピンチアウト");
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionFade;
            //transition.subtype = kCATransitionFromBottom;
            
            [self.view.layer addAnimation:transition forKey:nil];
            
            WeekViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"week"];
            newTopViewController.date = date;
            newTopViewController.dataValueType = dataValueType;
            newTopViewController.pageIndex = pageIndex;
            self.slidingViewController.topViewController = newTopViewController;
        }else if(1 > [sender scale]){
            NSLog(@"ピンチイン");
        }
    }
}

-(void)tapGesture:(UITapGestureRecognizer *)sender{
    if(sender.state == UIGestureRecognizerStateEnded){
        CGPoint point = [sender locationInView:self.view];
        
        //CGPoint org = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        CGPoint org = CGPointMake(self.arrowImageView.frame.size.width / 2, self.arrowImageView.frame.size.height / 2);
        
        float x = point.x - org.x;
        float y = -(point.y - org.y);
        
        float radian = atan2f(x, y);
        
        if(radian < 0){
            radian = radian + 2 * M_PI;
        }
        
        float degree = radian * 360 / (2 * M_PI);
        
        NSLog(@"endDegree:%f",degree);
        
        arrowIndex = degree / 2.5;
        
        if(arrowIndex > arrowMaxIndex){
            float angle = 2.5 * arrowMaxIndex;
            float radian = angle * M_PI / 180;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
        }else{
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
        }
        
        //データベースからデータ更新
        [self dataBaseAccess];
        
        //データ数値表示
        [self drawDataValue:arrowIndex];
        
        //リザルト表示
        [self drawResult:arrowIndex];
        
        //アバターと背景の色を変える
        [self changeImageColor:arrowIndex];
    }
}

-(void)panGesture:(UIPanGestureRecognizer *)sender{
    if ([self.slidingViewController currentTopViewPosition] != ECSlidingViewControllerTopViewPositionCentered) {
        
        [self.slidingViewController detectPanGestureRecognizer:sender];
        return;
    }
    
    CGPoint changePoint;
    CGPoint endPoint;
    
    CGPoint org = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    if(sender.state == UIGestureRecognizerStateChanged){
        changePoint = [sender locationInView:self.view];
        
        float x = changePoint.x - org.x;
        float y = -(changePoint.y - org.y);
        
        float radian = atan2f(x, y);
        
        if(radian < 0){
            radian = radian + 2 * M_PI;
        }
        
        float degree = radian * 360 / (2 * M_PI);
        
        NSLog(@"degree:%f",degree);
        
        arrowIndex = degree / 2.5;
        
        if(arrowIndex > arrowMaxIndex){
            float angle = 2.5 * arrowMaxIndex;
            float radian = angle * M_PI / 180;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
            
            arrowIndex = arrowMaxIndex;
        }else if(arrowIndex == 0){
            CGAffineTransform transform = CGAffineTransformMakeRotation(0);
            self.arrowImageView.transform = transform;
            arrowIndex = 0;
        }else{
            float angle = 2.5 * arrowIndex;
            float radian = angle * M_PI / 180;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
        }
    }else if(sender.state == UIGestureRecognizerStateEnded){
        endPoint = [sender locationInView:self.view];
        
        float x = endPoint.x - org.x;
        float y = -(endPoint.y - org.y);
        
        float radian = atan2f(x, y);
        
        if(radian < 0){
            radian = radian + 2 * M_PI;
        }
        
        float degree = radian * 360 / (2 * M_PI);
        
        NSLog(@"endDegree:%f",degree);
        
        arrowIndex = degree / 2.5;
        
        if(arrowIndex > arrowMaxIndex){
            float angle = 2.5 * arrowMaxIndex;
            float radian = angle * M_PI / 180;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
            arrowIndex = arrowMaxIndex;
        }else{
            float angle = 2.5 * arrowIndex;
            float radian = angle * M_PI / 180;
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
            self.arrowImageView.transform = transform;
        }
        
        //データベースからデータ更新
        [self dataBaseAccess];
        
        //データ数値表示
        [self drawDataValue:arrowIndex];
        
        //リザルト表示
        [self drawResult:arrowIndex];
        
        //アバターと背景の色を変える
        [self changeImageColor:arrowIndex];
    }
}

-(void)imageButtonAction:(UIButton *)button{
    PhotoCheckViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"photo"];
    newTopViewController.image = button.imageView.image;
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

- (IBAction)openDrawerAdd:(id)sender {
    [self.slidingViewController anchorTopViewToLeftAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredLeft) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

- (IBAction)leftDateButtonAction:(id)sender {
    NSLog(@"左日付変更ボタン！");
    //メニューが出てる時は機能しない
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) return;
    
    /***** ページングアニメーション *****/
    [UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.5];
    [UIView setAnimationRepeatCount:1];
    
    self.nowActivityView.center = CGPointMake(-160, 284);
    
    self.nowActivityView.center = CGPointMake(160, 284);
    [UIView commitAnimations];
    /***** ページングアニメーションここまで *****/
    
    for(UIView *subview in [self.nowActivityView subviews]){
        [subview removeFromSuperview];
    }
    
    date = [date initWithTimeInterval:-24*60*60 sinceDate:date];
    
    //データベースからデータ更新
    [self dataBaseAccess];
    
    //arrow表示
    [self drawArrow];
    
    //データ表示
    [self drawData];
    
    //データ数値表示
    [self drawDataValue:arrowIndex];
    
    //リザルト表示
    [self drawResult:arrowIndex];
    
    //アバターと背景の色を変える
    [self changeImageColor:arrowIndex];
    
    //アクティビティの描画
    [self drawActivity];
    
    //時計表示
    TimeGraphView *timeGraphView = [[TimeGraphView alloc] initWithFrame:self.nowActivityView.bounds];
    timeGraphView.date = date;
    [self.nowActivityView addSubview:timeGraphView];
}

- (IBAction)rightDateButtonAction:(id)sender {
    NSLog(@"右日付変更ボタン！");
    //メニューが出てる時は機能しない
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) return;
    
    NSDate *nextDate = [date initWithTimeInterval:24*60*60 sinceDate:date];
    
    NSComparisonResult result = [nextDate compare:[NSDate date]];
    
    if(result == NSOrderedDescending) return;
    
    //日付の更新
    date = [date initWithTimeInterval:24*60*60 sinceDate:date];
    
    /***** ページングアニメーション *****/
        [UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.5];
    [UIView setAnimationRepeatCount:1];
    
    self.nowActivityView.center = CGPointMake(480, 284);
    
    self.nowActivityView.center = CGPointMake(160, 284);
    [UIView commitAnimations];
    /***** ページングアニメーションここまで *****/
    
    for(UIView *subview in [self.nowActivityView subviews]){
        [subview removeFromSuperview];
    }
    
    //データベースからデータ更新
    [self dataBaseAccess];
    
    //arrow表示
    [self drawArrow];
    
    //データ表示
    [self drawData];
    
    //データ数値表示
    [self drawDataValue:arrowIndex];
    
    //リザルト表示
    [self drawResult:arrowIndex];
    
    //アバターと背景の色を変える
    [self changeImageColor:arrowIndex];
    
    //アクティビティの描画
    [self drawActivity];
    
    //時計表示
    TimeGraphView *timeGraphView = [[TimeGraphView alloc] initWithFrame:self.nowActivityView.bounds];
    timeGraphView.date = date;
    [self.nowActivityView addSubview:timeGraphView];
}

- (IBAction)leftPagingButtonAction:(id)sender {
    NSLog(@"左ページングボタン");
    
    if(deviceType == DEVICE_TYPE_IOS){
        NSArray *array = DATA_TYPES_IN_IOS;
        
        pageIndex -= 1;
        
        if(pageIndex < 0){
            pageIndex = array.count - 1;
        }
        
        dataValueType = [[array objectAtIndex:pageIndex] intValue];
    }
    
    self.pageControl.currentPage = pageIndex;
    
    //データ数値表示
    [self drawDataValue:arrowIndex];
    
    //リザルト表示
    [self drawResult:arrowIndex];
    
    //アバターと背景の色を変える
    [self changeImageColor:arrowIndex];
    
    //アクティビティの描画
    [self drawActivity];
}

- (IBAction)rightPagingButtonAction:(id)sender {
    NSLog(@"右ページングボタン");
    
    if(deviceType == DEVICE_TYPE_IOS){
        NSArray *array = DATA_TYPES_IN_IOS;
        
        pageIndex += 1;
        
        if(pageIndex > array.count - 1){
            pageIndex = 0;
        }
        
        dataValueType = [[array objectAtIndex:pageIndex] intValue];
    }
    
    self.pageControl.currentPage = pageIndex;
    
    //データ数値表示
    [self drawDataValue:arrowIndex];
    
    //リザルト表示
    [self drawResult:arrowIndex];
    
    //アバターと背景の色を変える
    [self changeImageColor:arrowIndex];
    
    //アクティビティの描画
    [self drawActivity];
}

- (IBAction)deviceChoiceButtonAction:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] init];
    as.delegate = self;
    as.title = @"選択してください";
    [as addButtonWithTitle:@"VitalConnect"];
    [as addButtonWithTitle:@"キャンセル"];
    
    as.cancelButtonIndex = 1;
    [as showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex){
        case 0:
            NSLog(@"VitalConnect");
            VCDayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VCday"];
            newTopViewController.date = date;
            newTopViewController.dataValueType = dataValueType;
            newTopViewController.pageIndex = pageIndex;
            self.slidingViewController.topViewController = newTopViewController;
            
            break;
    }
}

/**********/
//step関係処理
/**********/

//CMStepCounter処理
-(void)startCMStepCounter:(int)dayCount :(int)minCount{
    //今日の0時0分を取得
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSUInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *components = [calender components:flags fromDate:[NSDate date]];
    NSDate *startDate = [calender dateFromComponents:components];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if(dayCount < 8){
        NSDate *fromDate = [startDate initWithTimeInterval:-dayCount * 24 * 60 *60 sinceDate:startDate];
        
        NSDate *lastUpdateDate = [ud objectForKey:@"LastUpdateDate"];
        
        NSComparisonResult result = [lastUpdateDate compare:fromDate];
        if(result == NSOrderedAscending || result == NSOrderedSame){
            /***** 日にちフォーマット *****/
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            NSString *dayString = [formatter stringFromDate:fromDate];
            /***** 日にちフォーマット *****/
            
            if(minCount < 144){
                NSDate *toDate = [fromDate initWithTimeInterval:((minCount + 1) * 10) * 60 sinceDate:fromDate];
                
                [stepCounter queryStepCountStartingFrom:fromDate
                                                     to:toDate
                                                toQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                                //日にち取得
                                                NSCalendar *calendar = [NSCalendar currentCalendar];
                                                unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
                                                NSDateComponents *Components = [calendar components:flags fromDate:toDate];
                                                int hour = [Components hour];
                                                int min = [Components minute];
                                                
                                                if(minCount == 143){
                                                    int arrayIndex = 143;
                                                    
                                                    [saveStepArray replaceObjectAtIndex:arrayIndex withObject:[NSString stringWithFormat:@"%d",numberOfSteps]];
                                                    
                                                    //saveStepArrayをDBに保存する処理(更新)
                                                    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
                                                    NSMutableDictionary *steps = [dbHelper selectDayStep:dayString];
                                                    
                                                    if(steps == nil){
                                                        //saveStepArrayをDBに保存する処理
                                                        NSString *stepValue = [saveStepArray componentsJoinedByString:@","];
                                                        [dbHelper insertStep:dayString value:stepValue];
                                                    }else{
                                                        NSString *stepValue = [saveStepArray componentsJoinedByString:@","];
                                                        [dbHelper updateStep:dayString value:stepValue];
                                                    }
                                                    
                                                }else{
                                                    int arrayIndex = (hour * 6 + (min/10)) - 1;
                                                    
                                                    [saveStepArray replaceObjectAtIndex:arrayIndex withObject:[NSString stringWithFormat:@"%d",numberOfSteps]];
                                                }
                                                
                                                [self startCMStepCounter:dayCount :(minCount + 1)];
                                            }];
            }else{
                saveStepArray = [NSMutableArray array];
                
                for(int ii = 0; ii < 144; ii++){
                    [saveStepArray addObject:@"0"];
                }
                
                [self startCMStepCounter:(dayCount + 1) :0];
            }
        } else {
            [ud setObject:startDate forKey:@"LastUpdateDate"];
            [ud synchronize];
            
            [SVProgressHUD dismiss];
            
            //現在値用タイマー起動（過去のデータを読み込んでから、毎秒の処理を開始）
            tm = [NSTimer
                  scheduledTimerWithTimeInterval:1.0
                  target:self
                  selector:@selector(drawNowData:)
                  userInfo:nil repeats:YES];
        }
    }else{
        [ud setObject:startDate forKey:@"LastUpdateDate"];
        [ud synchronize];
        
        [SVProgressHUD dismiss];
        
        //現在値用タイマー起動（過去のデータを読み込んでから、毎秒の処理を開始）
        tm = [NSTimer
              scheduledTimerWithTimeInterval:1.0
              target:self
              selector:@selector(drawNowData:)
              userInfo:nil repeats:YES];
    }
}

//CMStepCounterによる当日更新処理
-(void)startCMStepCounter:(NSDate *)today{
    //データ取得
    /***** 日にちフォーマット *****/
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    /***** 日にちフォーマット *****/
    
    NSLog(@"save steps");
    
    NSString *dateString = [formatter stringFromDate:today];
    
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    NSMutableDictionary *steps = [dbHelper selectDayStep:dateString];
    
    saveStepArray = [NSMutableArray array];
    
    if(steps == nil){
        for(int ii = 0; ii < 144; ii++){
            [saveStepArray addObject:@"0"];
        }
        
        //saveStepArrayをDBに保存する処理
        NSString *stepValue = [saveStepArray componentsJoinedByString:@","];
        [dbHelper insertStep:dateString value:stepValue];
    }else{
        NSString *stepValue = [steps objectForKey:@"step_value"];
        saveStepArray = [stepValue componentsSeparatedByString:@","];
    }
    
    //最終起動時間からタイムラインを更新
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSDate *lastBootDate = [ud objectForKey:@"LastBootDate"];
    NSString *lastBootStr = [formatter stringFromDate:lastBootDate];
    NSString *nowStr = [formatter stringFromDate:[NSDate date]];
    
    if(![lastBootStr isEqualToString:nowStr]) {
        //タイムライン保存処理
        [self saveTimeLineData:lastBootDate];
        //最終起動日を更新
        [ud setObject:[NSDate date] forKey:@"LastBootDate"];
    }
    
    
    //今日の0時0分を取得
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger flag = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:flag fromDate:today];
    NSDate *startDate = [calendar dateFromComponents:components];
    
    //日にち取得
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *Components = [calendar components:flags fromDate:today];
    int hour = [Components hour];
    int min = [Components minute];
    int index = (hour * 6 + (min/10));
    
    NSDate *toDate = [startDate initWithTimeInterval:((index + 1) * 10) * 60 sinceDate:startDate];
    
    [stepCounter queryStepCountStartingFrom:startDate
                                         to:toDate
                                    toQueue:[NSOperationQueue mainQueue]
                                withHandler:^(NSInteger numberOfSteps, NSError *error) {
                                    for(int i = index; i < 144; i++){
                                        [saveStepArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d",numberOfSteps]];
                                    }
                                    
                                    NSLog(@"%@",toDate);
                                    
                                    //saveStepArrayをDBに保存する処理(更新)
                                    NSString *stepValue = [saveStepArray componentsJoinedByString:@","];
                                    [dbHelper updateStep:dateString value:stepValue];
                                    NSLog(@"%d",numberOfSteps);
                                    
                                    //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                    //[ud setObject:startDate forKey:@"LastUpdateDate"];
                                    //[ud synchronize];
                                }];
}

//自作StepCounter処理
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
        
        NSDate *today = [NSDate date];
        
        /***** 日にちフォーマット *****/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        todayString = [formatter stringFromDate:today];
        /***** 日にちフォーマット *****/
        
        //日にち取得
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
        int hour = [todayComponents hour];
        int min = [todayComponents minute];
        
        int arrayIndex = hour * 6 + (min/10);
        
        /***** 歩数、睡眠データ格納処理 *****/
        /***** DBよりデータ取得 *****/
        NSMutableDictionary *steps, *sleeps;
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        steps = [dbHelper selectDayStep:todayString];
        /***** DBよりデータ取得ここまで *****/
        
        /***** 歩数配列 *****/
        saveStepArray = [NSMutableArray array];
        NSString *stepValue;
        
        //カウントフラグon後上限を超えた場合歩数カウント
        if(counted && sumAcceleration > HighOldAcceleration){
            counted = FALSE;
            double now = CFAbsoluteTimeGetCurrent();
            
            //誤カウント用バッファ
            if(now - pastTime > 0.1f){
                
                //DBに歩数配列がなかったら初期化して作成
                if(steps == nil){
                    for(int ii = 0; ii < 144; ii++){
                        [saveStepArray addObject:@"0"];
                    }
                    
                    stepCount = 0;
                    
                    stepCount++;
                    NSLog(@"nil_stepCount:%d",stepCount);
                    
                    for (int i = arrayIndex; i < 144; i++) {
                        [saveStepArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d",stepCount]];
                    }
                    
                    //saveStepArrayをDBに保存する処理
                    stepValue = [saveStepArray componentsJoinedByString:@","];
                    [dbHelper insertStep:todayString value:stepValue];
                }else{
                    NSString *stepValue = [steps objectForKey:@"step_value"];
                    saveStepArray = [stepValue componentsSeparatedByString:@","];
                    
                    stepCount = [[saveStepArray objectAtIndex:143] intValue];
                    
                    stepCount++;
                    NSLog(@"else_stepCount:%d",stepCount);
                    
                    for (int i = arrayIndex; i < 144; i++) {
                        [saveStepArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%d",stepCount]];
                    }
                    
                    stepValue = [saveStepArray componentsJoinedByString:@","];
                    [dbHelper updateStep:todayString value:stepValue];
                }
                stepCount = [[saveStepArray objectAtIndex:143] intValue];
                /***** 歩数配列ここまで *****/
                
                //最終起動時間からタイムラインを更新
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                NSDate *lastBootDate = [ud objectForKey:@"LastBootDate"];
                NSString *lastBootStr = [formatter stringFromDate:lastBootDate];
                NSString *nowStr = [formatter stringFromDate:[NSDate date]];
                
                if(![lastBootStr isEqualToString:nowStr]) {
                    //タイムライン保存処理
                    [self saveTimeLineData:lastBootDate];
                    //最終起動日を更新
                    [ud setObject:[NSDate date] forKey:@"LastBootDate"];
                }
                
                pastTime = CFAbsoluteTimeGetCurrent();
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

- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition{
    if(topViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        //アバターと背景の色を変える
        [self.avatarView startAnimating];
    }
    return nil;
}


/***** タイムラインへのデータ保存処理 *****/
-(void)saveTimeLineData:(NSDate *)saveDate{
    //日付から歩数を取得
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *saveDateStr = [formatter stringFromDate:saveDate];
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    NSMutableDictionary *stepData = [dbHelper selectDayStep:saveDateStr];
    
    if(stepData != nil){
        NSString *stepValue = [stepData objectForKey:@"step_value"];
        NSArray *getStepArray = [stepValue componentsSeparatedByString:@","];
        
        int totalStep = [[getStepArray objectAtIndex:143] intValue];//合計歩数を取得
        
        // 数値を3桁ごとカンマ区切りにするように設定
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@","];
        [formatter setGroupingSize:3];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        //step
        // 数値を3桁ごとカンマ区切り形式で文字列に変換する
        NSString *valueForStep = [formatter stringFromNumber:[NSNumber numberWithInt:totalStep]];
        //目標値から達成度を設定
        int goalSteps = [ud integerForKey:@"GoalSteps"];
        int percentForStep = totalStep * 100 / goalSteps;
        
        [dbHelper insertTimeline:saveDateStr value:valueForStep percent:percentForStep type:TIMELINE_TYPE_STEP];
        
        //distance
        // 数値を3桁ごとカンマ区切り形式で文字列に変換する
        float totalDist = [self calcuDist:totalStep];
        NSString *valueForDist = [NSString stringWithFormat:@"%.1fkm", totalDist];
        //目標値から達成度を設定
        float goalDistance = [ud floatForKey:@"GoalDistance"];
        int percentForDist = totalDist * 100 / goalDistance;
        
        [dbHelper insertTimeline:saveDateStr value:valueForDist percent:percentForDist type:TIMELINE_TYPE_DIST];
        
        //calory
        // 数値を3桁ごとカンマ区切り形式で文字列に変換する
        int cal = [self calcuCalory:totalStep];//歩数による消費カロリー
        float bee = [self calcuBee:143];//基礎代謝による消費カロリー
        float totalCal = cal + bee;
        NSString *valueForCal = [formatter stringFromNumber:[NSNumber numberWithInt:totalCal]];
        //目標値から達成度を設定
        float goalCalory = [ud floatForKey:@"GoalCalory"];
        int percentForCal = totalCal * 100 / goalCalory;
        
        [dbHelper insertTimeline:saveDateStr value:valueForCal percent:percentForCal type:TIMELINE_TYPE_CALORY];
        
        //サーバにも保存する
        NSString *userID = [ud objectForKey:@"UserID"];
        
        NSDateFormatter *phpFormatter = [[NSDateFormatter alloc] init];
        [phpFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSURL *url = [NSURL URLWithString:URL_INSERT_TIMELINE];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [request setTimeOutSeconds:60];
        [request setPostValue:userID forKey:@"UserID"];
        [request setPostValue:[NSNumber numberWithInt:3] forKey:@"InsertCount"];
        //step
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineStartDateTime0"];
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineEndDateTime0"];
        [request setPostValue:valueForStep forKey:@"TimeLineValue0"];
        [request setPostValue:[NSNumber numberWithInt:percentForStep] forKey:@"TimeLineAttainment0"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_TYPE_STEP] forKey:@"TimeLineType0"];
        [request setPostValue:[NSNumber numberWithInt:SHARE_CLOSED] forKey:@"TimeLineShareStatus0"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_ACHIEVE_ONCE] forKey:@"TimeLineAchieveKind0"];
        //distance
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineStartDateTime1"];
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineEndDateTime1"];
        [request setPostValue:valueForDist forKey:@"TimeLineValue1"];
        [request setPostValue:[NSNumber numberWithInt:percentForDist] forKey:@"TimeLineAttainment1"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_TYPE_DIST] forKey:@"TimeLineType1"];
        [request setPostValue:[NSNumber numberWithInt:SHARE_CLOSED] forKey:@"TimeLineShareStatus1"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_ACHIEVE_ONCE] forKey:@"TimeLineAchieveKind1"];
        //calory
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineStartDateTime2"];
        [request setPostValue:[phpFormatter stringFromDate:saveDate] forKey:@"TimeLineEndDateTime2"];
        [request setPostValue:valueForCal forKey:@"TimeLineValue2"];
        [request setPostValue:[NSNumber numberWithInt:percentForCal] forKey:@"TimeLineAttainment2"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_TYPE_CALORY] forKey:@"TimeLineType2"];
        [request setPostValue:[NSNumber numberWithInt:SHARE_CLOSED] forKey:@"TimeLineShareStatus2"];
        [request setPostValue:[NSNumber numberWithInt:TIMELINE_ACHIEVE_ONCE] forKey:@"TimeLineAchieveKind2"];
        [request startAsynchronous];
    }
}

@end
