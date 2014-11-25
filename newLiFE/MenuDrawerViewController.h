//
//  MenuDrawerViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/01.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSlidingViewController.h"
#import "UIViewController+ECSlidingViewController.h"

@interface MenuDrawerViewController : UIViewController

@property(nonatomic) int deviceType;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestCountLabel;

- (IBAction)transferDayVC:(id)sender;
- (IBAction)transferSettingVC:(id)sender;
- (IBAction)transferGoalVC:(id)sender;
- (IBAction)transferTimelineVC:(id)sender;
- (IBAction)transferChallengeVC:(id)sender;
- (IBAction)transferFriendVC:(id)sender;
- (IBAction)transferInformationVC:(id)sender;
- (IBAction)transferDeviceVC:(id)sender;


@end
