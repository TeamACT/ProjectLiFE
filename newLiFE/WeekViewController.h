//
//  WeekViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DayViewController.h"
#import "MonthViewController.h"

#import "WeekActivityMarkView.h"

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface WeekViewController : UIViewController <UIGestureRecognizerDelegate, ECSlidingViewControllerDelegate>
{
    float sumStepValue;
}

@property(nonatomic) NSDate *date;
@property(nonatomic) int deviceType;
@property(nonatomic) int dataValueType;
@property(nonatomic) int pageIndex;;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBottomView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *drawResultView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIButton *leftCommonButton;

- (IBAction)leftPagingButtonACtion:(id)sender;
- (IBAction)rightPagingButtonAction:(id)sender;
- (IBAction)leftDateButtonAction:(id)sender;
- (IBAction)rightDateButtonAction:(id)sender;

- (IBAction)openDrawerMenu:(id)sender;
@end
