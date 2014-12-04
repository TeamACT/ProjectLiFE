//
//  CommonNavigationController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/12/04.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface CommonNavigationController : UINavigationController<ECSlidingViewControllerDelegate>

@end
