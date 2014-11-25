//
//  WeekViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "WeekViewController.h"
#import "DayViewController.h"

#import "MenuDrawerViewController.h"

@interface WeekViewController ()

@end

@implementation WeekViewController

@synthesize date;
@synthesize deviceType;
@synthesize dataValueType;
@synthesize pageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"*****************************************************");
    NSLog(@"date:%@",date);
    
    if(deviceType == DEVICE_TYPE_IOS){
        NSArray *array = DATA_TYPES_IN_IOS;
        self.pageControl.numberOfPages = array.count;
        self.pageControl.currentPage = pageIndex;
    }
    
    //ピンチ操作準備
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    
    /***** ボタン準備 *****/
    UIButton *sundayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];
    [sundayButton addTarget:self action:@selector(sundayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sundayButton];
    
    UIButton *mondayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];
    [mondayButton addTarget:self action:@selector(mondayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mondayButton];
    
    UIButton *tuesdayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];;
    [tuesdayButton addTarget:self action:@selector(tuesdayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tuesdayButton];
    
    UIButton *wednesdayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];;
    [wednesdayButton addTarget:self action:@selector(wednesdayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wednesdayButton];
    
    UIButton *thursdayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];
    [thursdayButton addTarget:self action:@selector(thursdayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:thursdayButton];
    
    UIButton *fridayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];;
    [fridayButton addTarget:self action:@selector(fridayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fridayButton];
    
    UIButton *saturdayButton = [[UIButton alloc] initWithFrame:CGRectMake([[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT)];;
    [saturdayButton addTarget:self action:@selector(saturdayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saturdayButton];
    /***** ボタン準備 *****/
    
    for(UIView *subview in [self.activityView subviews]){
        [subview removeFromSuperview];
    }
    
    WeekActivityMarkView *weekActivityMarkView = [[WeekActivityMarkView alloc] initWithFrame:self.activityView.bounds];
    weekActivityMarkView.date = date;
    weekActivityMarkView.dataValueType = dataValueType;
    [self.activityView addSubview:weekActivityMarkView];
    
    [self dataBaseAccess];
    
    [self drawResult];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    self.slidingViewController.delegate = self;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewC    ontroller].
 // Pass the selected object to the new view controller.
 }
 */

-(void)dataBaseAccess{
    /***** 日にち曜日フォーマット *****/
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    /***** 日にち曜日フォーマットここまで *****/
    
    /***** 日曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day;
    /***** 日曜日の取得ここまで *****/
    
    sumStepValue = 0;
    
    for(int weekday = 0; weekday < 7; weekday++){
        components.day = day + weekday;
        
        NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
        
        NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:result];
        
        /***** DBよりデータ取得 *****/
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        NSMutableDictionary *steps, *sleeps, *runs;
        steps = [dbHelper selectDayStep:formattedDataBaseString];
        runs = [dbHelper selectDayRun:formattedDataBaseString];
        
        if(steps == nil){
            continue;
        }
        NSString *stepValue = [steps objectForKey:@"step_value"];
        NSArray *stepArray = [stepValue componentsSeparatedByString:@","];
        
        sumStepValue += [[stepArray objectAtIndex:143] floatValue];
        /***** DBよりデータ取得 *****/
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

-(void)drawResult{
    for(UIView *subview in [self.drawResultView subviews]){
        [subview removeFromSuperview];
    }
    
    float value,goal;
    int per;
    
    NSString *resultString;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if(dataValueType == DATA_VALUE_TYPE_STEP){
        value = sumStepValue;
        goal = [ud integerForKey:@"GoalSteps"] * 7;
        per = (value / goal) * 100;
        NSNumber *valueNumber = [[NSNumber alloc] initWithInt:value];
        NSNumber *goalNumber = [[NSNumber alloc] initWithInt:goal];
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setGroupingSeparator:@","];
        [nf setGroupingSize:3];
        NSString *valueString = [nf stringFromNumber:valueNumber];
        NSString *goalString = [nf stringFromNumber:goalNumber];
        resultString = [NSString stringWithFormat:@"%@ / %@ 歩",valueString,goalString];
    }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
        float cal = [self calcuCalory:sumStepValue];
        float bee = [self calcuBee:143] * 7;
        value = cal + bee;
        goal = [ud floatForKey:@"GoalCalory"] * 7;
        per = (value / goal) * 100;
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
    }else if(dataValueType == DATA_VALUE_TYPE_DIST){
        value = [self calcuDist:sumStepValue];
        goal = [ud floatForKey:@"GoalDistance"] * 7;
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
    }else if(dataValueType == DATA_VALUE_TYPE_RUN){
        value = [self calcuDist:sumStepValue];
        goal = [ud floatForKey:@"GoalDistance"] * 7;
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
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, DATA_RESULT_LABEL_Y + 20, 190, 25)];
        timeLabel.font = [UIFont boldSystemFontOfSize:14];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.text = @"81分";
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [self.drawResultView addSubview:timeLabel];
        
        NSDictionary *stringAttributes1 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:9.0f] };
        NSDictionary *stringAttributes2 = @{ NSForegroundColorAttributeName:[UIColor whiteColor],
                                             NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
        NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"4.5" attributes:stringAttributes2];
        NSAttributedString *string2 = [[NSAttributedString alloc] initWithString:@"km/分" attributes:stringAttributes1];
        
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        [mutableAttributedString appendAttributedString:string1];
        [mutableAttributedString appendAttributedString:string2];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(160, DATA_RESULT_LABEL_Y + 20, 190, 25)];
        label.attributedText = mutableAttributedString;
        label.textAlignment = NSTextAlignmentLeft;
        [self.drawResultView addSubview:label];
    }
    
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_LABEL_X, DATA_RESULT_LABEL_Y, 190, 25)];
    resultLabel.font = [UIFont boldSystemFontOfSize:18];
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.text = resultString;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.drawResultView addSubview:resultLabel];
    
    if(per < 100){
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_PER_LABEL_X, DATA_RESULT_PER_LABEL_Y, 36, 60)];
        valueLabel.font = [UIFont boldSystemFontOfSize:30];
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.text = [NSString stringWithFormat:@"%d",per];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [self.drawResultView addSubview:valueLabel];
        
        UILabel *perLabel = [[UILabel alloc] initWithFrame:CGRectMake(DATA_RESULT_PER_MARK_LABEL_X, DATA_RESULT_PER_MARK_LABEL_Y, 20, 25)];
        perLabel.font = [UIFont boldSystemFontOfSize:12];
        perLabel.textColor = [UIColor whiteColor];
        perLabel.text = @"%";
        perLabel.textAlignment = NSTextAlignmentCenter;
        [self.drawResultView addSubview:perLabel];
        
        ResultGraphView *resultGraphView = [[ResultGraphView alloc] initWithFrame:self.drawResultView.bounds];
        resultGraphView.value = per;
        [self.drawResultView addSubview:resultGraphView];
        
        //[self changeImageColor:0];
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
        
        //[self changeImageColor:1];
    }
    [self changeImageColor:1];
}

-(void)changeImageColor:(int)result{
    //アバターと背景の色を変える
    NSArray *lightColors = [NSArray array];
    NSArray *darkColors = [NSArray array];
    NSString *animationPrefix;
    NSInteger animationFrames;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int gender = [ud integerForKey:@"UserGender"];
    
    if(dataValueType == DATA_VALUE_TYPE_RUN){
        self.leftCommonButton.hidden = NO;
        [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Red"] forState:UIControlStateNormal];
        
        lightColors = RGB_RED_LIGHT;
        darkColors = RGB_RED_DARK;
        
        //アニメーションの設定
        animationFrames = 11;
        
        if(gender == GENDER_MALE){
            animationPrefix = @"LiFE_Avatar_ManRunning_small";
        }else{
            animationPrefix = @"LiFE_Avatar_WomanRunning_small";
        }
    }else{
        if(result == 0){
            lightColors = RGB_GREEN_LIGHT;
            darkColors = RGB_GREEN_DARK;
            
            //アニメーションの設定
            animationFrames = 16;
            
            if(gender == GENDER_MALE){
                animationPrefix = @"LiFE_Avatar_ManWalking_small";
            }else{
                animationPrefix = @"LiFE_Avatar_WomanWalking_small";
            }
        }else{
            self.leftCommonButton.hidden = NO;
            [self.leftCommonButton setBackgroundImage:[UIImage imageNamed:@"LiFE_Left_GoalButton_Orange"] forState:UIControlStateNormal];
            
            lightColors = RGB_ORANGE_LIGHT;
            darkColors = RGB_ORANGE_DARK;
            
            //アニメーションの設定
            animationFrames = 16;
            
            if(gender == GENDER_MALE){
                animationPrefix = @"LiFE_Avatar_ManWalking_small";
            }else{
                animationPrefix = @"LiFE_Avatar_WomanWalking_small";
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

-(void)pinchGesture:(UIPinchGestureRecognizer *)sender
{
    //メニューが出てる時は機能しない
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) return;
    
    if(sender.state == UIGestureRecognizerStateEnded){
        if(1 < [sender scale]){
            NSLog(@"ピンチアウト");
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionReveal;
            transition.type = kCATransitionFromRight;
            
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            
            MonthViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"month"];
            newTopViewController.date = date;
            newTopViewController.dataValueType = dataValueType;
            newTopViewController.pageIndex = pageIndex;
            self.slidingViewController.topViewController = newTopViewController;
        }else if(1 > [sender scale]){
            NSLog(@"ピンチイン");
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            transition.type = kCATransitionReveal;
            transition.type = kCATransitionFromRight;
            
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            
            DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
            newTopViewController.date = date;
            newTopViewController.dataValueType = dataValueType;
            newTopViewController.pageIndex = pageIndex;
            self.slidingViewController.topViewController = newTopViewController;
        }
    }
}

- (IBAction)leftPagingButtonACtion:(id)sender {
    if(deviceType == DEVICE_TYPE_IOS){
        NSArray *array = DATA_TYPES_IN_IOS;
        
        pageIndex -= 1;
        
        if(pageIndex < 0){
            pageIndex = array.count - 1;
        }
        
        dataValueType = [[array objectAtIndex:pageIndex] intValue];
        
        /*
         if(dataValueType == [[array objectAtIndex:0] intValue]){
         dataValueType = [[array objectAtIndex:2] intValue];
         selectArrayIndex = 2;
         }else if (dataValueType == [[array objectAtIndex:2] intValue]){
         dataValueType = [[array objectAtIndex:1] intValue];
         selectArrayIndex = 1;
         }else if (typeFlag == [[array objectAtIndex:1] intValue]){
         dataValueType = [[array objectAtIndex:0] intValue];
         selectArrayIndex = 0;
         }
         */
    }
    self.pageControl.currentPage = pageIndex;
    
    for(UIView *subview in [self.activityView subviews]){
        [subview removeFromSuperview];
    }
    
    WeekActivityMarkView *weekActivityMarkView = [[WeekActivityMarkView alloc] initWithFrame:self.activityView.bounds];
    weekActivityMarkView.date = date;
    weekActivityMarkView.dataValueType = dataValueType;
    [self.activityView addSubview:weekActivityMarkView];
    
    [self dataBaseAccess];
    
    [self drawResult];
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
    
    for(UIView *subview in [self.activityView subviews]){
        [subview removeFromSuperview];
    }
    
    WeekActivityMarkView *weekActivityMarkView = [[WeekActivityMarkView alloc] initWithFrame:self.activityView.bounds];
    weekActivityMarkView.date = date;
    weekActivityMarkView.dataValueType = dataValueType;
    [self.activityView addSubview:weekActivityMarkView];
    
    [self dataBaseAccess];
    
    [self drawResult];
}

- (IBAction)leftDateButtonAction:(id)sender {
    [UIView beginAnimations:nil context:nil];
    //[UIView setAnimationDuration:0.5];
    [UIView setAnimationRepeatCount:1];
    
    for(UIView *subview in [self.activityView subviews]){
        [subview removeFromSuperview];
    }
    
    self.activityView.center = CGPointMake(-160, 284);
    
    self.activityView.center = CGPointMake(160, 284);
    [UIView commitAnimations];
    
    date = [date initWithTimeInterval:-7*24*60*60 sinceDate:date];
    
    WeekActivityMarkView *weekActivityMarkView = [[WeekActivityMarkView alloc] initWithFrame:self.activityView.bounds];
    weekActivityMarkView.date = date;
    weekActivityMarkView.dataValueType = dataValueType;
    [self.activityView addSubview:weekActivityMarkView];
    
    [self dataBaseAccess];
    
    [self drawResult];
}

- (IBAction)rightDateButtonAction:(id)sender {
    date = [date initWithTimeInterval:7*24*60*60 sinceDate:date];
    
    /***** 日曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSInteger day = 1 - baseComponents.weekday;
    components.day = day;
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 日曜日の取得ここまで *****/
    
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *nowComponents = [[NSDateComponents alloc] init];
    NSInteger nowDay = 1 - dateComponents.weekday;
    nowComponents.day = nowDay;
    NSDate *nowResult = [calendar dateByAddingComponents:nowComponents toDate:[NSDate date] options:0];
    
    NSComparisonResult comparisonResult = [result compare:nowResult];
    
    if(comparisonResult == NSOrderedDescending){
        date = [NSDate date];
    }else{
        [UIView beginAnimations:nil context:nil];
        //[UIView setAnimationDuration:0.5];
        [UIView setAnimationRepeatCount:1];
        
        for(UIView *subview in [self.activityView subviews]){
            [subview removeFromSuperview];
        }
        
        self.activityView.center = CGPointMake(480, 284);
        
        self.activityView.center = CGPointMake(160, 284);
        [UIView commitAnimations];
        
        WeekActivityMarkView *weekActivityMarkView = [[WeekActivityMarkView alloc] initWithFrame:self.activityView.bounds];
        weekActivityMarkView.date = date;
        weekActivityMarkView.dataValueType = dataValueType;
        [self.activityView addSubview:weekActivityMarkView];
        
        [self dataBaseAccess];
        
        [self drawResult];
    }
}

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

-(void)sundayButtonAction:(UIButton *)button{
    NSLog(@"日曜日！");
    /***** 日曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 日曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)mondayButtonAction:(UIButton *)button{
    NSLog(@"月曜日！");
    /***** 月曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 1;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 月曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)tuesdayButtonAction:(UIButton *)button{
    NSLog(@"火曜日！");
    /***** 火曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 2;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 火曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)wednesdayButtonAction:(UIButton *)button{
    NSLog(@"水曜日！");
    /***** 水曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 3;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 水曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)thursdayButtonAction:(UIButton *)button{
    NSLog(@"木曜日！");
    /***** 木曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 4;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 木曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)fridayButtonAction:(UIButton *)button{
    NSLog(@"金曜日！");
    /***** 金曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 5;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 金曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

-(void)saturdayButtonAction:(UIButton *)button{
    NSLog(@"土曜日！");
    /***** 土曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day + 6;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 土曜日の取得ここまで *****/
    
    NSComparisonResult comparisonResult = [result compare:[NSDate date]];
    
    if(comparisonResult != NSOrderedDescending){
        DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
        newTopViewController.dataValueType = dataValueType;
        newTopViewController.date = result;
        self.slidingViewController.topViewController = newTopViewController;
    }
}

- (id<ECSlidingViewControllerLayout>)slidingViewController:(ECSlidingViewController *)slidingViewController layoutControllerForTopViewPosition:(ECSlidingViewControllerTopViewPosition)topViewPosition{
    if(topViewPosition == ECSlidingViewControllerTopViewPositionCentered) {
        //アバターと背景の色を変える
        [self.avatarView startAnimating];
    }
    return nil;
}
@end
