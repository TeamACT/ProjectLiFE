//
//  WeekActivityMarkView.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "WeekActivityMarkView.h"

@implementation WeekActivityMarkView

@synthesize date;
@synthesize dataValueType;

#define DAYLABEL_SPACE_X 25
#define DAYLABEL_SPACE_Y 11
#define DAYLABEL_WIDTH 40
#define DAYLABEL_HEIGHT 33

#define WEEKDAYLABEL_SPACE_X 25
#define WEEKDAYLABEL_SPACE_Y 41
#define WEEKDAYLABEL_WIDTH 40
#define WEEKDAYLABEL_HEIGHT 15

#define VALUELABEL_SPACE_X 20
#define VALUELABEL_SPACE_Y 57
#define VALUELABEL_WIDTH 50
#define VALUELABEL_HEIGHT 15

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
    /***** 日にち曜日フォーマット *****/
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.dateFormat = @"M";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd";
    
    NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
    weekdayFormatter.dateFormat = @"EEEE";
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    /***** 日にち曜日フォーマットここまで *****/
    
    /***** 日曜日の取得 *****/
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *baseComponents = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    NSInteger day = 1 - baseComponents.weekday;
    
    components.day = day;
    
    NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
    /***** 日曜日の取得ここまで *****/

    /***** 第何週目かを取得する *****/
    /*
    NSInteger todayWeekNo = [calendar ordinalityOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:result];
    NSString *formattedMonthString = [monthFormatter stringFromDate:result];
    UILabel *weekNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 20, 150, 25)];
    weekNoLabel.textAlignment = NSTextAlignmentCenter;
    weekNoLabel.font = [UIFont systemFontOfSize:17];
    weekNoLabel.text = [NSString stringWithFormat:@"%@月 %d週",formattedMonthString,todayWeekNo];
    [self addSubview:weekNoLabel];
    */
    /***** 第何週目かを取得するここまで *****/
    
    /***** 日にちフォーマット *****/
    NSDateFormatter *monthFormatterCal = [[NSDateFormatter alloc] init];
    monthFormatterCal.dateFormat = @"MM";
    
    NSDateFormatter *dateFormatterCal = [[NSDateFormatter alloc] init];
    dateFormatterCal.dateFormat = @"dd";
    
    NSDateFormatter *weekdayFormatterCal = [[NSDateFormatter alloc] init];
    weekdayFormatterCal.dateFormat = @"EE";
    
    /***** 日付表示用処理 *****/
    NSString *formattedMonthStringCal = [monthFormatterCal stringFromDate:result];
    NSString *formattedDateStringCal = [dateFormatterCal stringFromDate:result];
    NSString *formattedWeekDayStringCal = [weekdayFormatterCal stringFromDate:result];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake([[DATE_LABEL objectAtIndex:0] intValue], [[DATE_LABEL objectAtIndex:1] intValue], [[DATE_LABEL objectAtIndex:2] intValue], [[DATE_LABEL objectAtIndex:3] intValue])];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:17];
    dateLabel.text = [NSString stringWithFormat:@"%@月%@日 (%@)",formattedMonthStringCal,formattedDateStringCal,formattedWeekDayStringCal];
    [self addSubview:dateLabel];
    
    sumSteps = 0;
    sumCalory = 0;
    sumDistance = 0;
    
    for(int weekday = 0; weekday < 7; weekday++){
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        /***** stress配列 ※仮ver *****/
        /*
        NSMutableArray *stressArray = [NSMutableArray array];
        
        for (int array = 0; array < 144; array++) {
            [stressArray addObject:[NSString stringWithFormat:@"%d",arc4random_uniform(60)]];
        }
        */
        /***** stress配列 ※仮ver *****/
        
        components.day = day + weekday;
        
        NSDate *result = [calendar dateByAddingComponents:components toDate:date options:0];
        
        NSString *formattedDateString = [dateFormatter stringFromDate:result];
        NSString *formattedWeekDayString = [weekdayFormatter stringFromDate:result];
        NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:result];
        
        if(weekday == SUNDAY){ //日曜日
            coorX = 208;
            coorY = 133;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.text = formattedDateString;
            dayLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }else if(weekday == MONDAY){ //月曜日
            coorX = 268;
            coorY = 209;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];;
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];;
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }else if(weekday == TUESDAY){ //火曜日
            coorX = 247;
            coorY = 303;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }else if(weekday == WEDNESDAY){ //水曜日
            coorX = 160;
            coorY = 343;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }else if(weekday == THURSDAY){ //木曜日
            coorX = 75;
            coorY = 303;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.text = formattedWeekDayString;
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:weekdayLabel];
        }else if(weekday == FRIDAY){ //金曜日
            coorX = 54;
            coorY = 209;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }else if(weekday == SATURDAY){ //土曜日
            coorX = 112;
            coorY = 133;
            
            //日にち
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:0] intValue] + DAYLABEL_SPACE_X, [[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:1] intValue] + DAYLABEL_SPACE_Y, DAYLABEL_WIDTH, DAYLABEL_HEIGHT)];
            dayLabel.font = [UIFont systemFontOfSize:29];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.text = formattedDateString;
            [self addSubview:dayLabel];
            
            //曜日
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:0] intValue] + WEEKDAYLABEL_SPACE_X, [[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:1] intValue] + WEEKDAYLABEL_SPACE_Y, WEEKDAYLABEL_WIDTH, WEEKDAYLABEL_HEIGHT)];
            weekdayLabel.font = [UIFont systemFontOfSize:12];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = formattedWeekDayString;
            [self addSubview:weekdayLabel];
        }
        
        /***** DBよりデータ取得 *****/
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        NSMutableDictionary *steps, *sleeps, *runs;
        steps = [dbHelper selectDayStep:formattedDataBaseString];
        sleeps = [dbHelper selectDaySleep:formattedDataBaseString];
        runs = [dbHelper selectDayRun:formattedDataBaseString];
        
        if(steps == nil){
            continue;
        }
        NSString *stepValue = [steps objectForKey:@"step_value"];
        NSArray *stepArray = [stepValue componentsSeparatedByString:@","];
        
        NSMutableArray *sleepArray = [NSMutableArray array];
        if(sleeps == nil){
            for(int array = 0; array < 144; array++){
                [sleepArray addObject:[NSString stringWithFormat:@"-1"]];
            }
        }else{
            NSString *sleepValue = [sleeps objectForKey:@"sleep_value"];
            sleepArray = [sleepValue componentsSeparatedByString:@","];
        }
        
        NSMutableArray *runArray = [NSMutableArray array];
        if(runs == nil){
            for(int array = 0; array < 144; array++){
                [runArray addObject:[NSString stringWithFormat:@"0"]];
            }
        }else{
            NSString *runValue = [runs objectForKey:@"run_value"];
            runArray = [runValue componentsSeparatedByString:@","];
        }
        /***** DBよりデータ取得 *****/
        
        /***** ステータス　*****/
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
        
        bee = bee * ageCoef;
        /***** ステータスここまで　*****/

        //週計表示用歩数
        sumSteps = sumSteps + [[stepArray objectAtIndex:143] intValue];
        sumCalory = sumCalory + tCal;
        sumDistance = sumDistance + tDistance;
        
        float eachValue, goalValue;
        
        CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
        
        /***** 日計歩数描画処理 *****/
        NSString *valueString;
        
        if(weekday == SUNDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_SUNDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == MONDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_MONDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == TUESDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_TUESDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == WEDNESDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_WEDNESDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == THURSDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_THURSDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == FRIDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_FRIDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }else if (weekday == SATURDAY){
            if(dataValueType == DATA_VALUE_TYPE_STEP){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_CALORY){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] intValue] * stride) / 100000;
                tCal = tDistance * weight;
                tCal = tCal + bee;
                
                eachValue = tCal;
                goalValue = [ud floatForKey:@"GoalCalory"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 0;
                nf.maximumFractionDigits = 0;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_DIST){
                //総運動消費カロリー/総距離
                tDistance = ([[stepArray objectAtIndex:143] floatValue] * stride) / 100000;
                
                eachValue = tDistance;
                goalValue = [ud floatForKey:@"GoalDistance"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithFloat:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                nf.minimumFractionDigits = 2;
                nf.maximumFractionDigits = 2;
                valueString = [nf stringFromNumber:valueNumber];
            }else if(dataValueType == DATA_VALUE_TYPE_RUN){
                eachValue = [[stepArray objectAtIndex:143] intValue];
                goalValue = [ud integerForKey:@"GoalSteps"];
                
                NSNumber *valueNumber = [[NSNumber alloc] initWithInt:eachValue];
                NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                [nf setGroupingSeparator:@","];
                [nf setGroupingSize:3];
                valueString = [nf stringFromNumber:valueNumber];
                
                CGContextSetRGBFillColor(context, [[RGB_RED_WEAK objectAtIndex:0] floatValue], [[RGB_RED_WEAK objectAtIndex:1] floatValue], [[RGB_RED_WEAK objectAtIndex:2] floatValue], 0.7);
            }
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake([[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:0] intValue] + VALUELABEL_SPACE_X, [[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:1] intValue] + VALUELABEL_SPACE_Y, VALUELABEL_WIDTH, VALUELABEL_HEIGHT)];
            valueLabel.font = [UIFont systemFontOfSize:11];
            valueLabel.text = valueString;
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:valueLabel];
            
            /***** 各日背景表示 *****/
            /*
             if(eachValue < goalValue){
             CGContextSetRGBFillColor(context, [[RGB_GREEN_WEAK objectAtIndex:0] floatValue], [[RGB_GREEN_WEAK objectAtIndex:1] floatValue], [[RGB_GREEN_WEAK objectAtIndex:2] floatValue], 0.7);
             }else{
             CGContextSetRGBFillColor(context, [[RGB_ORANGE_WEAK objectAtIndex:0] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:1] floatValue], [[RGB_ORANGE_WEAK objectAtIndex:2] floatValue], 0.7);
             }
             */
            CGContextFillEllipseInRect(context, CGRectMake([[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:0] intValue], [[WEEKDAY_SATURDAY_BACKGROUND objectAtIndex:1] intValue], WEEKDAY_BACKGROUND_WIDTH, WEEKDAY_BACKGROUND_HEIGHT));
            /***** 各日背景表示ここまで *****/
        }
        
        //描画処理
        for (int i = 0; i < stepArray.count; i++) {
            int flg = 0;
            
            float angle = 270 + 2.5 * i;
            
            if(angle>360){
                angle = 2.5 * i - 90;
            }
            
            float radian = angle * M_PI / 180;
            
            double cosX = cos(radian);
            double x = 35 * cosX;
            double sinY = sin(radian);
            double y = 35 * sinY;
            
            CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1);
            
            /***** stress描画 *****/
            /*
            float stressAngle = 270 + 2.5 * (i + 1);
            
            if(stressAngle > 360){
                stressAngle = 2.5 * (i + 1) - 90;
            }
            
            float stressRadian = stressAngle * M_PI / 180;
            
            double endCosX = cos(stressRadian);
            double stressEndX = coorX + 46 * endCosX;
            double endSinY = sin(stressRadian);
            double stressEndY = coorY + 46 * endSinY;
            
            double stressStartX = coorX + (46 * cosX);
            double stressStartY = coorY + (46 * sinY);
            
            int scale = [[stressArray objectAtIndex:i] intValue];
            
            //色
            if(scale < 40){
                CGContextSetRGBStrokeColor(context, 0.0, 0.435, 0.867, 1);
            }else if(scale > 39 && scale < 46){
                CGContextSetRGBStrokeColor(context, 1.0, 0.392, 1.0, 1);
            }else if(scale > 45){
                CGContextSetRGBStrokeColor(context, 0.957, 0.157, 0.157, 1);
            }
            
            CGContextMoveToPoint(context, stressStartX, stressStartY);
            CGContextAddLineToPoint(context, stressEndX, stressEndY);
            CGContextStrokePath(context);
            */
            /***** stress描画ここまで *****/
            
            if(dataValueType == DATA_VALUE_TYPE_RUN){ //歩数表示画面
                /***** sleep描画 *****/
                if([[sleepArray objectAtIndex:i] intValue] > -1){
                    int sleepValue = [[sleepArray objectAtIndex:i] intValue];
                    int scale;
                    
                    if(sleepValue < 46 && sleepValue > 0){
                        scale = 36;
                    }else if(sleepValue > 45){
                        scale = 45;
                    }else if(sleepValue == 0){
                        scale = 35;
                    }
                    
                    CGContextSetRGBStrokeColor(context, [[RGB_GRAY objectAtIndex:0] floatValue], [[RGB_GRAY objectAtIndex:1] floatValue], [[RGB_GRAY objectAtIndex:2] floatValue], 1);
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    flg = 1;
                }
                /***** sleep描画ここまで *****/
                
                /***** run描画 *****/
                if([[runArray objectAtIndex:i] intValue] > 0){
                    int beforei = i - 1;
                    
                    int before;
                    
                    if(beforei < 0){
                        before = 0;
                    }else{
                        before = [[stepArray objectAtIndex:beforei] intValue];
                    }
                    
                    int now = [[stepArray objectAtIndex:i] intValue];
                    int scale = (now-before) / 2;
                    
                    CGContextSetRGBStrokeColor(context, [[RGB_RED_LIGHT objectAtIndex:0] floatValue], [[RGB_RED_LIGHT objectAtIndex:1] floatValue], [[RGB_RED_LIGHT objectAtIndex:2] floatValue], 1);
                    
                    for(int i = 10; i > 0; i--){
                        if(scale > (i * 2) * (i * 2)) {
                            scale = i + 35;
                            break;
                        }else if(scale == 0){
                            scale = 35;
                            break;
                        }else if(scale < 5 && scale > 0){
                            scale = 36;
                            break;
                        }else{
                            scale = 35;
                        }
                    }
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
                    
                    flg = 1;
                }
                /***** run描画ここまで *****/
                
                /***** step描画 *****/
                if(flg == 0){
                    int beforei = i - 1;
                    
                    int before;
                    
                    if(beforei < 0){
                        before = 0;
                    }else{
                        before = [[stepArray objectAtIndex:beforei] intValue];
                    }
                    
                    int now = [[stepArray objectAtIndex:i] intValue];
                    int scale = (now-before) / 2;
                    
                    CGContextSetRGBStrokeColor(context, [[RGB_GRAY objectAtIndex:0] floatValue], [[RGB_GRAY objectAtIndex:1] floatValue], [[RGB_GRAY objectAtIndex:2] floatValue], 1);
                    
                    for(int i = 10; i > 0; i--){
                        if(scale > (i * 2) * (i * 2)) {
                            scale = i + 35;
                            break;
                        }else if(scale == 0){
                            scale = 35;
                            break;
                        }else if(scale < 5 && scale > 0){
                            scale = 36;
                            break;
                        }else{
                            scale = 35;
                        }
                    }
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
                }
                /***** step描画 *****/
            }else{
                /***** sleep描画 *****/
                if([[sleepArray objectAtIndex:i] intValue] > -1){
                    int sleepValue = [[sleepArray objectAtIndex:i] intValue];
                    int scale;
                    
                    if(sleepValue < 46 && sleepValue > 0){
                        scale = 36;
                    }else if(sleepValue > 45){
                        scale = 45;
                    }else if(sleepValue == 0){
                        scale = 35;
                    }
                    
                    if(sleepValue < 37){
                        CGContextSetRGBStrokeColor(context, [[RGB_PURPLE_LIGHT objectAtIndex:0] floatValue], [[RGB_PURPLE_LIGHT objectAtIndex:1] floatValue], [[RGB_PURPLE_LIGHT objectAtIndex:2] floatValue], 1);
                    }else if(sleepValue > 36 && sleepValue < 45){
                        CGContextSetRGBStrokeColor(context, [[RGB_AQUA_LIGHT objectAtIndex:0] floatValue], [[RGB_AQUA_LIGHT objectAtIndex:1] floatValue], [[RGB_AQUA_LIGHT objectAtIndex:2] floatValue], 1);
                    }else if(sleepValue > 44){
                        CGContextSetRGBStrokeColor(context, [[RGB_BLUE_LIGHT objectAtIndex:0] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:1] floatValue], [[RGB_BLUE_LIGHT objectAtIndex:2] floatValue], 1);
                    }
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    flg = 1;
                }
                /***** sleep描画ここまで *****/
                
                /***** run描画 *****/
                if([[runArray objectAtIndex:i] intValue] > 0){
                    int beforei = i - 1;
                    
                    int before;
                    
                    if(beforei < 0){
                        before = 0;
                    }else{
                        before = [[stepArray objectAtIndex:beforei] intValue];
                    }
                    
                    int now = [[stepArray objectAtIndex:i] intValue];
                    int scale = (now-before) / 2;
                    
                    CGContextSetRGBStrokeColor(context, [[RGB_RED_LIGHT objectAtIndex:0] floatValue], [[RGB_RED_LIGHT objectAtIndex:1] floatValue], [[RGB_RED_LIGHT objectAtIndex:2] floatValue], 1);
                    
                    for(int i = 10; i > 0; i--){
                        if(scale > (i * 2) * (i * 2)) {
                            scale = i + 35;
                            break;
                        }else if(scale == 0){
                            scale = 35;
                            break;
                        }else if(scale < 5 && scale > 0){
                            scale = 36;
                            break;
                        }else{
                            scale = 35;
                        }
                    }
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
                    
                    flg = 1;
                }
                /***** run描画ここまで *****/
                
                /***** step描画 *****/
                if(flg == 0){
                    int beforei = i - 1;
                    
                    int before;
                    
                    if(beforei < 0){
                        before = 0;
                    }else{
                        before = [[stepArray objectAtIndex:beforei] intValue];
                    }
                    
                    int now = [[stepArray objectAtIndex:i] intValue];
                    int scale = (now-before) / 2;
                    
                    if(scale > 300){
                        CGContextSetRGBStrokeColor(context, [[RGB_ORANGE_LIGHT objectAtIndex:0] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:1] floatValue], [[RGB_ORANGE_LIGHT objectAtIndex:2] floatValue], 1);
                    }else{
                        CGContextSetRGBStrokeColor(context, [[RGB_GREEN_LIGHT objectAtIndex:0] floatValue], [[RGB_GREEN_LIGHT objectAtIndex:1] floatValue], [[RGB_GREEN_LIGHT objectAtIndex:2] floatValue], 1);
                    }
                    
                    for(int i = 10; i > 0; i--){
                        if(scale > (i * 2) * (i * 2)) {
                            scale = i + 35;
                            break;
                        }else if(scale == 0){
                            scale = 35;
                            break;
                        }else if(scale < 5 && scale > 0){
                            scale = 36;
                            break;
                        }else{
                            scale = 35;
                        }
                    }
                    
                    double startX = coorX + x;
                    double startY = coorY + y;
                    
                    double endX = coorX + (scale * cosX);
                    double endY = coorY + (scale * sinY);
                    
                    CGContextMoveToPoint(context, startX, startY);
                    CGContextAddLineToPoint(context, endX, endY);
                    CGContextStrokePath(context);
                    
                    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
                }
                /***** step描画 *****/
            }
        }
    }
    UIGraphicsEndImageContext();
}

@end
