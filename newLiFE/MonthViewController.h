//
//  MonthViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeekViewController.h"
#import "YearViewController.h"

#import "MonthActivityMarkView.h"

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface MonthViewController : UIViewController <UIGestureRecognizerDelegate, ECSlidingViewControllerDelegate>
{
    int stepsCount;
    float sumSteps;
}


@property(nonatomic) NSDate *date;
@property(nonatomic) int deviceType;
@property(nonatomic) int dataValueType;
@property(nonatomic) int pageIndex;

@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBottomView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *drawResultView;

@property (weak, nonatomic) IBOutlet UIButton *leftCommonButton;

- (IBAction)openDrawerMenu:(id)sender;
- (IBAction)leftPagingButtonAction:(id)sender;
- (IBAction)rightPagingButtonAction:(id)sender;
- (IBAction)leftDateButtonAction:(id)sender;
- (IBAction)rightDateButtonAction:(id)sender;

- (IBAction)transferGoalVC:(id)sender;


@end
