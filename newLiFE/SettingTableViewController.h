//
//  SettingTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/08/29.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface SettingTableViewController : UITableViewController<ECSlidingViewControllerDelegate>{
}
- (IBAction)openDrawerMenu:(id)sender;

@end
