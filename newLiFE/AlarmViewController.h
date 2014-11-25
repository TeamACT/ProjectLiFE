//
//  AlarmViewController.h
//  isSleep
//
//  Created by 八幡 翔一 on 2014/04/23.
//  Copyright (c) 2014年 八幡 翔一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

#import "DatabaseHelper.h"

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface AlarmViewController : UIViewController <UIPickerViewDelegate,UIAccelerometerDelegate,ECSlidingViewControllerDelegate>
{
    NSDate *alarmTime;
    AVAudioPlayer *alarmPlayer;
    
    int hour;
    int min;
    int alarmHour;
    int alarmMin;
    
    BOOL alarmEnabled;
    int alarmFlag;
    
    //UIAccelerometer *accele;
    float beforeX;
    float beforeY;
    int badSleep;
    NSMutableArray *badSleepArray;
    NSMutableArray *currentBadSleepArray;
    NSDate *startTime;
    NSDate *nowTime;
    NSMutableArray *timeArray;
    NSMutableArray *currentTimeArray;
    NSDateFormatter *inputDateFormatter;
    
    NSDate *bedTime;
    NSDate *riseTime;
    
    
    
    NSString *todayString;
    
    NSMutableArray *sleepArray;
    
    NSDate *date;
    
    NSTimer *clock;
    NSTimer *tm;
    
    int beforeArrayIndex;
    
    float startDateTimeMS;
}

@property CMMotionManager *motionManager;

@property (weak, nonatomic) IBOutlet UILabel *nowTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UIButton *alarmButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

- (IBAction)alarmStartButtonAction:(UIButton *)sender;

- (IBAction)timePickerAction:(UIDatePicker *)sender;
- (IBAction)backButtonAction:(id)sender;
- (IBAction)leftButtonAction:(id)sender;
- (IBAction)rightButtonAction:(id)sender;


@end
