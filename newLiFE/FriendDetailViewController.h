//
//  FriendDetailViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/12/03.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendDetailViewController : UIViewController{
    NSString *friendUserID;
}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *challengeCountLabel;

-(void)setFriendUserID:(NSString *)userID;

- (IBAction)transferFriendList:(id)sender;
- (IBAction)transferTitleList:(id)sender;
- (IBAction)transferChallengeList:(id)sender;

@end
