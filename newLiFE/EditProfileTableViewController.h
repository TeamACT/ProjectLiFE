//
//  EditProfileTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/08.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

#import "ShowImageViewController.h"

@interface EditProfileTableViewController : UITableViewController<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ShowImageViewDelegate> {
    
}

@end