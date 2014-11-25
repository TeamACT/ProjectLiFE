//
//  VCDayViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/30.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "WeekViewController.h"

#import "PhotoCheckViewController.h"

#import "DatabaseHelper.h"

#import "TimeGraphView.h"
#import "ResultGraphView.h"
#import "ActivityMarkView.h"
#import "NowActivityMarkView.h"

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface VCDayViewController : UIViewController <UIGestureRecognizerDelegate,CLLocationManagerDelegate,ECSlidingViewControllerDelegate,UIActionSheetDelegate>
{
    NSDate *prevDate;
    
    NSString *todayString;
    NSString *prevDayString;
    
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
    NSMutableArray *saveStepArray;
    
    NSMutableDictionary *steps;
    NSMutableDictionary *sleeps;
    NSMutableDictionary *runs;
    
    NSMutableArray *stepArray;
    NSMutableArray *sleepArray;
    NSMutableArray *runArray;
    NSMutableArray *photoArray;
    
    CMStepCounter *stepCounter;
    
    NSTimer *tm;
    
    int arrowMaxIndex;
    int arrowIndex;
    
    CGPoint beganPoint;
    
    NSMutableArray *dataStateArray;
}

@property(nonatomic) NSDate *date;
@property(nonatomic) int deviceType;
@property(nonatomic) int dataValueType;
@property(nonatomic) int pageIndex;

@property (weak, nonatomic) IBOutlet UIImageView *timeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@property CMMotionManager *motionManager;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIView *nowActivityView;
@property (weak, nonatomic) IBOutlet UIView *drawView;
@property (weak, nonatomic) IBOutlet UIView *drawResultView;
@property (weak, nonatomic) IBOutlet UIView *drawDataView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBottomView;
@property (weak, nonatomic) IBOutlet UIButton *leftCommonButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)openDrawerMenu:(id)sender;
- (IBAction)openDrawerAdd:(id)sender;

- (IBAction)leftDateButtonAction:(id)sender;
- (IBAction)rightDateButtonAction:(id)sender;

- (IBAction)leftPagingButtonAction:(id)sender;
- (IBAction)rightPagingButtonAction:(id)sender;
- (IBAction)deviceChoiceButtonAction:(id)sender;

@end
