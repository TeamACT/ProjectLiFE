//
//  ActivityMarkView.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "YearActivityMarkView.h"

@implementation YearActivityMarkView

@synthesize date;
@synthesize dataValueType;

#define STEP_MAX_LENGTH 110
#define SLEEP_MAX_LENGTH 50
#define SPACE_TWO_GRAPH 2
#define STEP_LENGTH_RATIO 0.0036
#define CALORY_LENGTH_RATIO 0.022
#define DISTANCE_LENGTH_RATIO 2.2

- (id)initWithFrame:(CGRect)frame
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
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    
    //現在の年を計算
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSYearCalendarUnit fromDate:date];
    NSDateComponents *components = [NSDateComponents new];
    
    components.year = baseComponents.year;
    components.month = 1;
    components.day = 1;
    
    //表示年は何日あるか取得（365or366）
    NSDateComponents *calcComponents = [NSDateComponents new];
    calcComponents.year = baseComponents.year + 1;
    calcComponents.month = 1;
    calcComponents.day = 1;
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateFromComponents:calcComponents];
    
    calcComponents = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    int daysOfYear = [calcComponents day];
    
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    NSMutableArray *steps = [dbHelper selectYearSteps:[NSString stringWithFormat:@"%d", baseComponents.year]];
    NSMutableArray *sleeps = [dbHelper selectYearSleeps:[NSString stringWithFormat:@"%d", baseComponents.year]];
    
    int stepIndex = 0;
    int sleepIndex = 0;
    
    /***** ステータス 後ほどuserdefaultかDBになる　*****/
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
    
    //目標値を円で描画
    
    //目標値をストロークで描画（内部分が歩数、外部分が睡眠時間）
    if(dataValueType == DATA_VALUE_TYPE_STEP){
        int goalSteps = [ud integerForKey:@"GoalSteps"];
        
        float lineWidth = goalSteps * STEP_LENGTH_RATIO;
        float ellipseSize = STEP_MAX_LENGTH - lineWidth / 2;
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetRGBStrokeColor(context, 0.84, 0.84, 0.84, 0.5);
        CGContextStrokeEllipseInRect(context, CGRectMake(160 - ellipseSize, 235 - ellipseSize, ellipseSize * 2, ellipseSize * 2));
    }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
        int goalCalory = [ud integerForKey:@"GoalCalory"];
        
        float lineWidth = goalCalory * CALORY_LENGTH_RATIO;
        float ellipseSize = STEP_MAX_LENGTH - lineWidth / 2;
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetRGBStrokeColor(context, 0.84, 0.84, 0.84, 0.5);
        CGContextStrokeEllipseInRect(context, CGRectMake(160 - ellipseSize, 235 - ellipseSize, ellipseSize * 2, ellipseSize * 2));
    }else if(dataValueType == DATA_VALUE_TYPE_DIST){
        int goalDistance = [ud integerForKey:@"GoalDistance"];
        
        float lineWidth = goalDistance * DISTANCE_LENGTH_RATIO;
        float ellipseSize = STEP_MAX_LENGTH - lineWidth / 2;
        
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetRGBStrokeColor(context, 0.84, 0.84, 0.84, 0.5);
        CGContextStrokeEllipseInRect(context, CGRectMake(160 - ellipseSize, 235 - ellipseSize, ellipseSize * 2, ellipseSize * 2));
    }
    
    //歩数、睡眠時間の0にあたる位置に円を描く
    CGContextSetLineWidth(context, 1.0);
    CGContextSetRGBStrokeColor(context, 0.907, 0.565, 0.004, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(160 - STEP_MAX_LENGTH, 235 - STEP_MAX_LENGTH, STEP_MAX_LENGTH * 2, STEP_MAX_LENGTH * 2));
    CGContextSetRGBStrokeColor(context, 0.0, 0.435, 0.867, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(160 - (STEP_MAX_LENGTH + SPACE_TWO_GRAPH), 235 - (STEP_MAX_LENGTH + SPACE_TWO_GRAPH), (STEP_MAX_LENGTH + SPACE_TWO_GRAPH) * 2, (STEP_MAX_LENGTH + SPACE_TWO_GRAPH) * 2));
    
    //放射線状に描画
    CGContextSetLineWidth(context, 1.0);
    CGContextTranslateCTM(context, 160, 235);//中心点を移動
    CGContextRotateCTM(context, M_PI);//開始を頂点からにする
    
    float sumSteps = 0;
    
    for(int i = 0; i < daysOfYear; i++) {
        components.day = 1 + i;
        NSDate *result = [calendar dateFromComponents:components];
        NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:result];
        
        if([steps count] > 0 && stepIndex < [steps count]) {
            NSMutableDictionary *step = [steps objectAtIndex:stepIndex];
            if([formattedDataBaseString isEqualToString:[NSString stringWithFormat:@"%@",[step objectForKey:@"step_date"]]]) {
                //保存した日付が一致した場合
                stepIndex++;
                
                NSString *stepValue = [step objectForKey:@"step_value"];
                NSArray *stepArray = [stepValue componentsSeparatedByString:@","];
                
                sumSteps += [[stepArray objectAtIndex:143] intValue];
                
                if(dataValueType == DATA_VALUE_TYPE_STEP){
                    //歩数を描画
                    int stepPerDay = [[stepArray objectAtIndex:143] intValue];
                    float graphLength = stepPerDay * STEP_LENGTH_RATIO;//10000歩で40pxの長さにする
                    if(graphLength > STEP_MAX_LENGTH) graphLength = STEP_MAX_LENGTH;//最大の長さ
                    
                    CGContextSetRGBStrokeColor(context, 0.907, 0.565, 0.004, 1);
                    CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH - graphLength);
                    CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH);
                    CGContextStrokePath(context);
                }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                    //カロリーを描画
                    int stepPerDay = [[stepArray objectAtIndex:143] intValue];
                    float distance = (stride * stepPerDay) / 100000;
                    float cCal = distance * weight;
                    
                    float graphLength = cCal * CALORY_LENGTH_RATIO;//10000歩で40pxの長さにする
                    if(graphLength > STEP_MAX_LENGTH) graphLength = STEP_MAX_LENGTH;//最大の長さ
                    
                    CGContextSetRGBStrokeColor(context, 0.907, 0.565, 0.004, 1);
                    CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH - graphLength);
                    CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH);
                    CGContextStrokePath(context);
                }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                    //距離を描画
                    int stepPerDay = [[stepArray objectAtIndex:143] intValue];
                    float distance = (stride * stepPerDay) / 100000;
                    
                    float graphLength = distance * DISTANCE_LENGTH_RATIO;//10000歩で40pxの長さにする
                    if(graphLength > STEP_MAX_LENGTH) graphLength = STEP_MAX_LENGTH;//最大の長さ
                    
                    CGContextSetRGBStrokeColor(context, 0.907, 0.565, 0.004, 1);
                    CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH - graphLength);
                    CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH);
                    CGContextStrokePath(context);
                }
            }
        }
        
        if([sleeps count] > 0 && sleepIndex < [sleeps count]) {
            NSMutableDictionary *sleep = [sleeps objectAtIndex:sleepIndex];
            if([formattedDataBaseString isEqualToString:[NSString stringWithFormat:@"%@",[sleep objectForKey:@"sleep_date"]]]) {
                sleepIndex++;
                
                NSString *sleepValue = [sleep objectForKey:@"sleep_value"];
                NSArray *sleepArray = [sleepValue componentsSeparatedByString:@","];
                
                int sleepCount = 0;
                for(int i = 0; i < [sleepArray count]; i++) {
                    int sleepValuePerMinutes = [[sleepArray objectAtIndex:i] intValue];
                    if(sleepValuePerMinutes > -1) {
                        sleepCount++;
                    }
                }
                
                float sleepGraphLength = sleepCount * SLEEP_MAX_LENGTH / 144;//10000歩で40pxの長さにする
                //睡眠を描画
                CGContextSetRGBStrokeColor(context, 0.0, 0.435, 0.867, 1);
                CGContextMoveToPoint(context, 0, STEP_MAX_LENGTH + SPACE_TWO_GRAPH);
                CGContextAddLineToPoint(context, 0, STEP_MAX_LENGTH + SPACE_TWO_GRAPH + sleepGraphLength);
                CGContextStrokePath(context);
            }
        }
        
        CGContextRotateCTM(context, 1.0 / 365.0 * (M_PI * 2.0));
    }
    
    UIGraphicsEndImageContext();
    
    /***** 日付表示用処理 *****/
    UILabel *yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 28, 100, 25)];
    yearLabel.textAlignment = NSTextAlignmentCenter;
    yearLabel.font = [UIFont systemFontOfSize:17];
    yearLabel.text = [NSString stringWithFormat:@"%d年", baseComponents.year];
    [self addSubview:yearLabel];
    /***** 日付表示用処理ここまで *****/
}

@end
