//
//  FriendSearchNameTableViewController.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/22.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendSearchNameTableViewController : UITableViewController<UISearchBarDelegate> {
    NSMutableArray *searchResult;
    
    NSString *searchedWord;
}
@property (weak, nonatomic) IBOutlet UISearchBar *friendSearchBar;

@end
