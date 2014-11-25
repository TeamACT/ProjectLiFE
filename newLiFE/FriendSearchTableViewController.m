//
//  FriendSearchTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/15.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendSearchTableViewController.h"
#import "FriendSearchAddressTableViewController.h"


@interface FriendSearchTableViewController ()

@end

@implementation FriendSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //境界線の隙間をなくす
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    //facebookによる登録をしている場合、表示が変わる
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    int loginKind = [ud integerForKey:@"LoginKind"];
    if(loginKind == LOG_IN_FACEBOOK) {
        hasFacebook = 1;
    } else {
        hasFacebook = 0;
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //テーブルビューのヘッダーにUIViewを置くことで空白部分を消す
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    self.tableView.tableHeaderView = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2 + hasFacebook;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellFriendSearch"];
    
    UIImageView *searchImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    nameLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Medium" size:16.0f];
    
    if(hasFacebook == 1 && [indexPath row] == 0) {
        searchImage.image = [UIImage imageNamed:@"LiFE_Friend_SearchFromFacebookIcon.png"];
        nameLabel.text = @"Facebookの友達を探す";
    }
    
    if([indexPath row] == 0 + hasFacebook) {
        searchImage.image = [UIImage imageNamed:@"LiFE_Friend_SearchFromAddressBookIcon.png"];
        nameLabel.text = @"連絡先の友達を探す";
    } else if([indexPath row] == 1 + hasFacebook) {
        searchImage.image = [UIImage imageNamed:@"LiFE_Friend_SearchByNameIcon.png"];
        nameLabel.text = @"名前で友達を探す";
    }
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellFriendSearch"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルを押したときの処理
    if(hasFacebook == 1 && [indexPath row] == 0) {
        //facebookで探す
        FriendSearchAddressTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendSearchAddress"];
        [controller setSearchFriendType:SEARCH_FRIEND_FACEBOOK];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    if([indexPath row] == 0 + hasFacebook) {
        //連絡先で探す
        FriendSearchAddressTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendSearchAddress"];
        [controller setSearchFriendType:SEARCH_FRIEND_ADDRESS_BOOK];
        [self.navigationController pushViewController:controller animated:YES];
        
    } else if([indexPath row] == 1 + hasFacebook) {
        //名前で探す
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"friendSearchName"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
