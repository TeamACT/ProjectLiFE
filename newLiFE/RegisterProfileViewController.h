//
//  RegisterProfileViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/11/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface RegisterProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ECSlidingViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *profileTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

- (IBAction)selectUserImage:(id)sender;
- (IBAction)finishRegisterProfile:(id)sender;

@end
