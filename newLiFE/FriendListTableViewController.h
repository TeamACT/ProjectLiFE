//
//  FriendListTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface FriendListTableViewController : UITableViewController<ECSlidingViewControllerDelegate>{
    NSMutableArray *friendList;
    NSMutableArray *requestList;
    int requestRowIndex;
}

- (IBAction)openDrawerMenu:(id)sender;

@end
