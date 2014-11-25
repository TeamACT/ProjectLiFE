//
//  TimeLineViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/24.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface TimeLineViewController : UIViewController<UIScrollViewDelegate, ECSlidingViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *timeLineListMe;
    NSMutableArray *timeLineListFriend;
}

@property (weak, nonatomic) IBOutlet UIScrollView *pagingView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *changeSegmented;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *myTimeLineTableView;
@property (weak, nonatomic) IBOutlet UITableView *friendTimeLineTableView;

- (IBAction)openDrawerMenu:(id)sender;

@end
