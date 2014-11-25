//
//  EditPasswordTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPasswordTableViewController : UITableViewController<UITextFieldDelegate> {
    NSString *recentPass;
    NSString *newPass;
    NSString *confirmPass;
}
- (IBAction)updatePassword:(id)sender;

@end
