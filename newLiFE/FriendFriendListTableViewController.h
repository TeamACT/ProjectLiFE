//
//  FriendFriendListTableViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/12/03.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendFriendListTableViewController : UITableViewController{
    NSString *friendUserID;
    NSMutableArray *friendList;
}
-(void)setFriendUserID:(NSString *)userID;

@end
