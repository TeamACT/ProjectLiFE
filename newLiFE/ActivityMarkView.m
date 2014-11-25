//
//  ActivityMarkView.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "ActivityMarkView.h"

@implementation ActivityMarkView

@synthesize date;
@synthesize deviceType;
@synthesize dataValueType;
@synthesize steps;
@synthesize sleeps;
@synthesize runs;

#define MAX_TIME 80

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
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *Components = [calendar components:flags fromDate:date];
    int hour = [Components hour];
    int min = [Components minute];
    
    int pastIndex = (hour * 6 + (min/10));
    
    NSMutableArray *stepArray,*sleepArray,*runArray;
    
    //データが存在していたら各種描画処理
    if(steps != nil){
        NSString *stepValue = [steps objectForKey:@"step_value"];
        stepArray = [stepValue componentsSeparatedByString:@","];
        
        sleepArray = [NSMutableArray array];
        
        if(sleeps == nil){
            for(int array = 0; array < 144; array++){
                [sleepArray addObject:@"-1"];
            }
        }else{
            NSString *sleepValue = [sleeps objectForKey:@"sleep_value"];
            sleepArray = [sleepValue componentsSeparatedByString:@","];
        }
        
        runArray = [NSMutableArray array];
        
        if(runs == nil){
            for(int array = 0; array < 144; array++){
                [runArray addObject:@"0"];
            }
        }else{
            NSString *runValue = [runs objectForKey:@"run_value"];
            runArray = [runValue componentsSeparatedByString:@","];
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        /***** 日にちフォーマット *****/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *todayString = [formatter stringFromDate:[NSDate date]];
        NSString *dateString = [formatter stringFromDate:date];
        /***** 日にちフォーマット *****/
        
        int index;
        
        if([dateString isEqualToString:todayString]){
            index = pastIndex;
        }else{
            index = 143;
        }
        
        for (int i = 0; i < index; i++) {
            int flg = DRAW_STEP;
            
            float angle = 270 + 2.5 * i;
            
            if(angle > 360){
                angle = 2.5 * i - 90;
            }
            
            float radian = angle * M_PI / 180;
            
            double cosX = cos(radian);
            
            double x = 120 * cosX;
            
            double sinY = sin(radian);
            
            double y = 120 * sinY;
            
            /***** sleepの描画 *****/
            if([[sleepArray objectAtIndex:i] intValue] > -1){
                int sleepValue = [[sleepArray objectAtIndex:i] intValue];
                float scale;
                
                //値が大きいほど睡眠の深さは浅い
                sleepValue = 100 - sleepValue;
                //色
                
                if(dataValueType == DATA_VALUE_TYPE_RUN){
                    CGContextSetRGBFillColor(context, [[RGB_GRAY objectAtIndex:0] floatValue], [[RGB_GRAY objectAtIndex:1] floatValue], [[RGB_GRAY objectAtIndex:2] floatValue], 1);
                }else{
                    if(sleepValue > 39 && sleepValue < 80){
                        CGContextSetRGBFillColor(context, 0.173, 0.882, 1.0, 1);
                    }else if(sleepValue > 79){
                        CGContextSetRGBFillColor(context, 0.0, 0.435, 0.867, 1);
                    }else{
                        CGContextSetRGBFillColor(context, 1.0, 0.392, 1.0, 1);
                    }
                }
                
                //サイズ
                for(int i = 10; i > 0; i--){
                    if(sleepValue >= i * 10) {
                        scale = i * 1.5;
                        break;
                    }else if(sleepValue < 1){
                        scale = 1.5;
                        break;
                    }
                }
                
                //描画
                CGContextFillEllipseInRect(context, CGRectMake(160 + x - (scale / 2), 234 + y - (scale / 2), scale, scale));
                
                flg = DRAW_OTHER;
            }
            /***** sleep描画ここまで *****/
            
            /***** runの描画 *****/
            if([[runArray objectAtIndex:i] intValue] > 0){
                int beforei = i - 1;
                
                int before;
                
                if(beforei < 0){
                    before = 0;
                }else{
                    before = [[stepArray objectAtIndex:beforei] intValue];
                }
                
                int now = [[stepArray objectAtIndex:i] intValue];
                int stepValue = now-before;
                float scale;
                
                //色
                CGContextSetRGBFillColor(context, 1, 0.16, 0.16, 1);
                
                //サイズ
                for(int i = 10; i > 0; i--){
                    if(stepValue > (i * 2) * (i * 2)) {
                        scale = i * 1.5;
                        break;
                    }else if(stepValue < 5 && stepValue > 0){
                        scale = 1.5;
                        break;
                    }else if(stepValue == 0){
                        scale = 0;
                        break;
                    }
                }
                
                //描画
                CGContextFillEllipseInRect(context, CGRectMake(160 + x - (scale / 2), 234 + y - (scale / 2), scale, scale));
                
                flg = DRAW_OTHER;
            }
            /***** run描画ここまで *****/
            
            /***** step描画 *****/
            if(flg == DRAW_STEP){
                int beforei = i - 1;
                
                int before;
                
                if(beforei < 0){
                    before = 0;
                }else{
                    before = [[stepArray objectAtIndex:beforei] intValue];
                }
                
                int now = [[stepArray objectAtIndex:i] intValue];
                int stepValue = now-before;
                float scale;
                
                //色
                if(dataValueType == DATA_VALUE_TYPE_RUN){
                    CGContextSetRGBFillColor(context, 0.607, 0.607, 0.607, 1);
                }else{
                    if(stepValue > 300){
                        CGContextSetRGBFillColor(context, 0.949, 0.588, 0, 1);
                    }else{
                        CGContextSetRGBFillColor(context, 0.164, 0.674, 0.435, 1);
                    }
                }
                
                //サイズ
                for(int i = 10; i > 0; i--){
                    if(stepValue > (i * 2) * (i * 2)) {
                        scale = i * 1.5;
                        break;
                    }else if(stepValue < 5 && stepValue > 0){
                        scale = 1.5;
                        break;
                    }else if(stepValue == 0){
                        scale = 0;
                        break;
                    }
                }
                
                //描画
                CGContextFillEllipseInRect(context, CGRectMake(160 + x - (scale / 2), 234 + y - (scale / 2), scale, scale));
            }
            /***** stepの描画ここまで *****/
        }
        UIGraphicsEndImageContext();
    }
}

@end
