//
//  FriendSearchAddressTableViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/23.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FriendSearchAddressTableViewController : UITableViewController<MFMailComposeViewControllerDelegate>{
    int searchFriendType;
    
    NSMutableArray *friendList;
    NSMutableArray *searchResult;
    
    NSMutableArray *invitingIndexList;
}

-(void)setSearchFriendType:(int) type;

@end
