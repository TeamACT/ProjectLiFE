//
//  TopViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface TopViewController : UIViewController<UIScrollViewDelegate, ECSlidingViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *pagingView;
@property (weak, nonatomic) IBOutlet UIPageControl *pagingControl;

@end
