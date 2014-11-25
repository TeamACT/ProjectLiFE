//
//  GoalTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/11.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface GoalTableViewController : UITableViewController<ECSlidingViewControllerDelegate>
- (IBAction)openDrawerMenu:(id)sender;

@end
