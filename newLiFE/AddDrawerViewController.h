//
//  AddDrawerViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/16.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface AddDrawerViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic) int deviceType;

- (IBAction)transferSleepVC:(id)sender;
- (IBAction)transferRunningVC:(id)sender;
- (IBAction)photoButtonAction:(id)sender;

@end
