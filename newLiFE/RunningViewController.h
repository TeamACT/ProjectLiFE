//
//  RunningViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/22.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#import "DatabaseHelper.h"

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface RunningViewController : UIViewController <CLLocationManagerDelegate,ECSlidingViewControllerDelegate>
{
    IBOutlet CLLocationManager *locationManager;//位置情報用
    
    /***** 自作StepCounter用 *****/
    double xx;
    double yy;
    double zz;
    int stepCount;
    BOOL counted;
    float LowOldSumAcceleration;
    float HighOldAcceleration;
    
    double pastTime;
    /***** 自作StepCounter用ここまで *****/
    
    int alarmFlag;
    
    NSString *todayString;
    
    NSMutableArray *runArray;
    
    NSDate *date;
    
    NSTimer *clock;
    NSTimer *tm;
    
    int startStep;
    NSDate *startTime;
    NSDate *endTime;
    
    int steps;
}

@property CMMotionManager *motionManager;

@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

@property (weak, nonatomic) IBOutlet UILabel *goalCaptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *alarmButton;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;


- (IBAction)alarmStartButtonAction:(UIButton *)sender;

- (IBAction)backButtonAction:(id)sender;
- (IBAction)leftButtonAction:(id)sender;
- (IBAction)rightButtonAction:(id)sender;

@end
