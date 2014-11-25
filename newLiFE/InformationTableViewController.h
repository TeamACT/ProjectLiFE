//
//  InformationTableViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface InformationTableViewController : UITableViewController<MFMailComposeViewControllerDelegate, ECSlidingViewControllerDelegate>

- (IBAction)openDrawerMenu:(id)sender;

@end
