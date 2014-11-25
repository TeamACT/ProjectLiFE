//
//  MonthActivityMarkView.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/16.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "MonthActivityMarkView.h"

#import "DatabaseHelper.h"

@implementation MonthActivityMarkView

@synthesize date;
@synthesize dataValueType;

#define STEP_MAX_LENGTH 110
#define SLEEP_MAX_LENGTH 25
#define SPACE_TWO_GRAPH 2
#define STEP_LENGTH_RATIO 0.0125
#define MANY_STEP_COLOR 1000
#define LIGHT_SLEEP_COLOR 25
#define DEEP_SLEEP_COLOR 50

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //上に乗ってるViewを全て削除
    for(UIView *subview in [self subviews]){
        [subview removeFromSuperview];
    }
    
    //背景画像をセット
    /*
    UIImageView *scaleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiFE_Month_CircleScale.png"]];
    scaleImage.frame = CGRectMake(0, 0, 320, 354);
    scaleImage.center = CGPointMake(160, 237);
    [self addSubview:scaleImage];
    */
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    
    //現在の月を計算
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
    NSDateComponents *components = [NSDateComponents new];
    
    components.year = baseComponents.year;
    components.month = baseComponents.month;
    components.day = 1;
    
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    NSMutableArray *steps = [dbHelper selectMonthSteps:[NSString stringWithFormat:@"%d", baseComponents.year] :[NSString stringWithFormat:@"%02d", baseComponents.month]];
    NSMutableArray *sleeps = [dbHelper selectMonthSleeps:[NSString stringWithFormat:@"%d", baseComponents.year] :[NSString stringWithFormat:@"%02d", baseComponents.month]];
    NSMutableArray *runs = [dbHelper selectMonthRuns:[NSString stringWithFormat:@"%d", baseComponents.year] :[NSString stringWithFormat:@"%02d", baseComponents.month]];
    
    int stepIndex = 0;
    int sleepIndex = 0;
    int runIndex = 0;
    
    /***** ステータス *****/
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //身長体重（入力に変更予定）
    float tall = [ud floatForKey:@"UserHeight"];
    float weight = [ud floatForKey:@"UserWeight"];
    
    //歩幅
    float stride = tall * 0.45;
    
    //性別
    int gender = [ud integerForKey:@"UserGender"];
    
    //年齢（入力に変更予定）
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
    /***** ステータスここまで　*****/
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //目標値
    int goalSteps = [ud integerForKey:@"GoalSteps"];
    int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
    
    //歩数、睡眠時間の0にあたる位置に円を描く
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, [[RGB_ORANGE_LIGHT objectAtIndex:0] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:1] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:2] floatValue], 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(160 - STEP_MAX_LENGTH, 235 - STEP_MAX_LENGTH, STEP_MAX_LENGTH * 2, STEP_MAX_LENGTH * 2));
    CGContextSetRGBStrokeColor(context, [[RGB_BLUE_LIGHT objectAtIndex:0] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:1] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:2] floatValue], 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(160 - (STEP_MAX_LENGTH + SPACE_TWO_GRAPH), 235 - (STEP_MAX_LENGTH + SPACE_TWO_GRAPH), (STEP_MAX_LENGTH + SPACE_TWO_GRAPH) * 2, (STEP_MAX_LENGTH + SPACE_TWO_GRAPH) * 2));
    
    //放射線状に描画
    CGContextSetLineWidth(context, 1.0);
    CGContextTranslateCTM(context, 160, 235);//中心点を移動
    CGContextRotateCTM(context, M_PI);//開始を頂点からにする
    
    float sumSteps = 0;
    
    //歩数
    for(int i = 0; i < 31; i++) {
        if([steps count] == 0) break;//データが一つも登録されていない場合はループさせない
        
        components.day = 1 + i;
        NSDate *result = [calendar dateFromComponents:components];
        NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:result];
        
        if(stepIndex < [steps count]) {
            NSMutableDictionary *step = [steps objectAtIndex:stepIndex];
            if([formattedDataBaseString isEqualToString:[NSString stringWithFormat:@"%@",[step objectForKey:@"step_date"]]]) {
                //保存した日付が一致した場合
                stepIndex++;
                
                NSString *stepValue = [step objectForKey:@"step_value"];
                NSArray *stepArray = [stepValue componentsSeparatedByString:@","];
                
                sumSteps += [[stepArray objectAtIndex:143] floatValue];
                
                int runFlag = 0;
                for(int k = 0; k < [runs count]; k++){
                    NSMutableDictionary *run = [runs objectAtIndex:k];
                    NSString *runDateString = [run objectForKey:@"run_date"];
                    if([[step objectForKey:@"step_date"] isEqualToString:runDateString]){
                        NSString *runValue = [run objectForKey:@"run_value"];
                        runArray = [runValue componentsSeparatedByString:@","];
                        runFlag = 1;
                    }
                }
                
                int colorFlag = 0;
                
                if(dataValueType == DATA_VALUE_TYPE_RUN){
                    //歩数を描画
                    int stepPerTwoHours = 0;
                    for(int j = 0; j < [stepArray count]; j++) {
                        int stepPerTenMinutes = 0;
                        if(j == 0) {
                            stepPerTenMinutes = [[stepArray objectAtIndex:j] intValue];
                        } else {
                            stepPerTenMinutes = [[stepArray objectAtIndex:j] intValue] - [[stepArray objectAtIndex:(j - 1)] intValue];
                        }
                        stepPerTwoHours += stepPerTenMinutes;
                        
                        if(runFlag == 1){
                            if([[runArray objectAtIndex:j] intValue] > 0){
                                colorFlag = 1;
                            }
                        }
                        
                        if((j + 1) % 12 == 0) {
                            float graphLength = stepPerTwoHours * STEP_LENGTH_RATIO;
                            if(graphLength > STEP_MAX_LENGTH) graphLength = STEP_MAX_LENGTH;//最大の長さ
                            
                            if(colorFlag == 1){
                                CGContextSetRGBStrokeColor(context, [[RGB_RED_LIGHT objectAtIndex:0] floatValue], [[RGB_RED_LIGHT objectAtIndex:1] floatValue], [[RGB_RED_LIGHT objectAtIndex:2] floatValue], 1);
                                colorFlag = 0;
                            }else{
                                CGContextSetRGBStrokeColor(context, [[RGB_GRAY objectAtIndex:0] floatValue], [[RGB_GRAY objectAtIndex:1] floatValue], [[RGB_GRAY objectAtIndex:2] floatValue], 1);
                            }
                            
                            CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH - graphLength);
                            CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH);
                            CGContextStrokePath(context);
                            
                            //表示分回転させる
                            CGContextRotateCTM(context, 1.0 / (12.0 * 31.0) * (M_PI * 2.0));
                            
                            //ステップ数をリセット
                            stepPerTwoHours = 0;
                        }
                    }
                }else{
                    //歩数を描画
                    int stepPerTwoHours = 0;
                    for(int j = 0; j < [stepArray count]; j++) {
                        int stepPerTenMinutes = 0;
                        if(j == 0) {
                            stepPerTenMinutes = [[stepArray objectAtIndex:j] intValue];
                        } else {
                            stepPerTenMinutes = [[stepArray objectAtIndex:j] intValue] - [[stepArray objectAtIndex:(j - 1)] intValue];
                        }
                        stepPerTwoHours += stepPerTenMinutes;
                        
                        if(runFlag == 1){
                            if([[runArray objectAtIndex:j] intValue] > 0){
                                colorFlag = 1;
                            }
                        }
                        
                        if((j + 1) % 12 == 0) {
                            float graphLength = stepPerTwoHours * STEP_LENGTH_RATIO;
                            if(graphLength > STEP_MAX_LENGTH) graphLength = STEP_MAX_LENGTH;//最大の長さ
                            
                            if(colorFlag == 1){
                                CGContextSetRGBStrokeColor(context, [[RGB_RED_LIGHT objectAtIndex:0] floatValue], [[RGB_RED_LIGHT objectAtIndex:1] floatValue], [[RGB_RED_LIGHT objectAtIndex:2] floatValue], 1);
                                colorFlag = 0;
                            }else{
                                if(stepPerTwoHours > MANY_STEP_COLOR){
                                    CGContextSetRGBStrokeColor(context, [[RGB_ORANGE_LIGHT objectAtIndex:0] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:1] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:2] floatValue], 1);
                                }else{
                                    CGContextSetRGBStrokeColor(context, [[RGB_GREEN_LIGHT objectAtIndex:0] floatValue], [[RGB_GREEN_LIGHT objectAtIndex:1] floatValue], [[RGB_GREEN_LIGHT objectAtIndex:2] floatValue], 1);
                                }
                            }
                            
                            CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH - graphLength);
                            CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH);
                            CGContextStrokePath(context);
                            
                            //表示分回転させる
                            CGContextRotateCTM(context, 1.0 / (12.0 * 31.0) * (M_PI * 2.0));
                            
                            //ステップ数をリセット
                            stepPerTwoHours = 0;
                        }
                    }
                    /*
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    if(dataValueType == DATA_VALUE_TYPE_STEP){
                        if(sumSteps > [[ud objectForKey:@"GoalSteps"] intValue]){
                            CGContextStrokeEllipseInRect(context, CGRectMake(160, 65, 25, 25));
                        }
                    }
                    */
                    
                }
                //CGContextStrokeEllipseInRect(context, CGRectMake(160, 0, 25, 25));
            } else {
                //データがない場合、１日分回転させる(まだ先の日にちにデータがある場合)
                CGContextRotateCTM(context, 1.0 / 31.0 * (M_PI * 2.0));
            }
        } else {
            //データがない場合、１日分回転させる(この先にもうデータがない場合)
            CGContextRotateCTM(context, 1.0 / 31.0 * (M_PI * 2.0));
        }
        //CGContextSetRGBStrokeColor(context, [[RGB_RED_LIGHT objectAtIndex:0] floatValue], [[RGB_RED_LIGHT objectAtIndex:1] floatValue], [[RGB_RED_LIGHT objectAtIndex:2] floatValue], 1);
        //CGContextStrokeEllipseInRect(context, CGRectMake(160, 0, 25, 25));
    }

    //睡眠
    components.day = 1;
    for(int i = 0; i < 31; i++) {
        if([sleeps count] == 0) break;//データが一つも登録されていない場合はループさせない
        
        components.day = 1 + i;
        NSDate *result = [calendar dateFromComponents:components];
        NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:result];
        
        if(sleepIndex < [sleeps count]) {
            NSMutableDictionary *sleep = [sleeps objectAtIndex:sleepIndex];
            //NSLog(@"sleep date:%@", [NSString stringWithFormat:@"%@",[sleep objectForKey:@"sleep_date"]]);
            
            if([formattedDataBaseString isEqualToString:[NSString stringWithFormat:@"%@",[sleep objectForKey:@"sleep_date"]]]) {
                sleepIndex++;
                
                NSString *sleepValue = [sleep objectForKey:@"sleep_value"];
                NSArray *sleepArray = [sleepValue componentsSeparatedByString:@","];
                
                int sleepCount = 0;
                int sumSleepValue = 0;
                int aveSleepValue = 0;
                
                for(int j = 0; j < [sleepArray count]; j++) {
                    int sleepValuePerMinutes = [[sleepArray objectAtIndex:j] intValue];
                    if(sleepValuePerMinutes > -1) {
                        //睡眠が保存されている場合、睡眠深度を合計する
                        sleepCount++;
                        sumSleepValue += sleepValuePerMinutes;
                    }
                    
                    if((j + 1) % 12 == 0) {
                        //睡眠の深さを平均値にする
                        aveSleepValue = sumSleepValue / sleepCount;
                        
                        float sleepGraphLength = aveSleepValue * SLEEP_MAX_LENGTH / 100;
                        
                        if(aveSleepValue < LIGHT_SLEEP_COLOR){
                            CGContextSetRGBStrokeColor(context, [[RGB_BLUE_LIGHT objectAtIndex:0] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:1] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:2] floatValue], 1);
                        }else if(LIGHT_SLEEP_COLOR <= aveSleepValue && aveSleepValue < DEEP_SLEEP_COLOR){
                            CGContextSetRGBStrokeColor(context, [[RGB_AQUA_LIGHT objectAtIndex:0] floatValue], [[RGB_AQUA_LIGHT objectAtIndex:1] floatValue], [[RGB_AQUA_LIGHT objectAtIndex:2] floatValue], 1);
                        }else{
                            CGContextSetRGBStrokeColor(context, [[RGB_PURPLE_LIGHT objectAtIndex:0] floatValue], [[RGB_PURPLE_LIGHT objectAtIndex:1] floatValue], [[RGB_PURPLE_LIGHT objectAtIndex:2] floatValue], 1);
                        }
                        CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH + SPACE_TWO_GRAPH);
                        CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH + SPACE_TWO_GRAPH + sleepGraphLength);
                        CGContextStrokePath(context);
                        
                        //表示分回転させる
                        CGContextRotateCTM(context, 1.0 / (12.0 * 31.0) * (M_PI * 2.0));
                        
                        //仮保存の値をリセット
                        sleepCount = 0;
                        sumSleepValue = 0;
                    }
                }
            } else {
                //データがない場合、１日分回転させる(まだ先の日にちにデータがある場合)
                CGContextRotateCTM(context, 1.0 / 31.0 * (M_PI * 2.0));
            }
        } else {
            //データがない場合、１日分回転させる(この先にもうデータがない場合)
            CGContextRotateCTM(context, 1.0 / 31.0 * (M_PI * 2.0));
        }
    }
    
    UIGraphicsEndImageContext();
    
    /***** 日付表示用処理 *****/
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake([[DATE_LABEL objectAtIndex:0] intValue], [[DATE_LABEL objectAtIndex:1] intValue], [[DATE_LABEL objectAtIndex:2] intValue], [[DATE_LABEL objectAtIndex:3] intValue])];
    monthLabel.textAlignment = NSTextAlignmentCenter;
    monthLabel.font = [UIFont systemFontOfSize:17];
    monthLabel.text = [NSString stringWithFormat:@"%d年%d月", baseComponents.year, baseComponents.month];
    [self addSubview:monthLabel];
    /***** 日付表示用処理ここまで *****/
}

@end
