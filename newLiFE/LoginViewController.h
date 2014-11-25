//
//  LoginViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/12.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface LoginViewController : UIViewController <UIAlertViewDelegate,UITextFieldDelegate,ECSlidingViewControllerDelegate>
{
    NSString *name;
    NSString *mail;
    NSString *pass;
}

@property (nonatomic) int flag;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIamge;


@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;


- (IBAction)loginButtonAction:(UIButton *)sender;
- (IBAction)helpButtonAction:(id)sender;
- (IBAction)facebookButtonAction:(id)sender;
@end
