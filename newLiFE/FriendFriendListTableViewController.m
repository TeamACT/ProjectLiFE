//
//  FriendFriendListTableViewController.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/12/03.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendFriendListTableViewController.h"
#import "FriendDetailViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "AsyncImageView.h"
#import "YYImageLoader.h"
#import "UITableView+ReloadDataWithCompletion.h"

@interface FriendFriendListTableViewController ()

@end

@implementation FriendFriendListTableViewController

#define FRIEND_ID @"FriendID"
#define FRIEND_NAME @"FriendName"
#define FRIEND_IMAGE @"FriendImage"
#define FRIEND_MUTUAL @"MutualFriends"


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //境界線の隙間をなくす
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    //ナビゲーションバーの境界線を消す
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    self.navigationItem.title = @"友達";
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //テーブルビューのヘッダーにUIViewを置くことで空白部分を消す
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    self.tableView.tableHeaderView = view;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    friendList = [NSMutableArray array];
    
    //フレンド一覧を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userID = [ud objectForKey:@"UserID"];
    
    NSURL *url = [NSURL URLWithString:URL_GET_FRIEND_FRIEND_LIST];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:userID forKey:@"UserID"];
    [request setPostValue:friendUserID forKey:@"FriendUserID"];
    [request startAsynchronous];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *response = [request responseData];
    NSArray *resultsIDs = PerformXMLXPathQuery(response, @"/tag/friend_user_id");
    NSArray *resultsNames = PerformXMLXPathQuery(response, @"/tag/friend_user_name");
    NSArray *resultsImages = PerformXMLXPathQuery(response, @"/tag/friend_user_image");
    NSArray *resultsMutuals = PerformXMLXPathQuery(response, @"/tag/friend_mutual_friends");
    
    for(int i = 0; i < [resultsIDs count]; i++) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        NSString *friendID = [[resultsIDs objectAtIndex:i] objectForKey:@"nodeContent"];
        NSString *friendName = [[resultsNames objectAtIndex:i] objectForKey:@"nodeContent"];
        NSString *friendImage = [[resultsImages objectAtIndex:i] objectForKey:@"nodeContent"];
        NSString *mutualFriends = [[resultsMutuals objectAtIndex:i] objectForKey:@"nodeContent"];
        [dictionary setObject:friendID forKey:FRIEND_ID];
        [dictionary setObject:friendName == nil ? @"" : friendName forKey:FRIEND_NAME];
        [dictionary setObject:friendImage == nil ? @"" : friendImage forKey:FRIEND_IMAGE];
        [dictionary setObject:mutualFriends forKey:FRIEND_MUTUAL];
        
        [friendList addObject:dictionary];
    }
    
    //リストを更新
    [self.tableView reloadDataWithCompletion:^{
        [SVProgressHUD dismiss];
    }];
    
}

//httpリクエスト失敗時の処理
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    // 通信ができなかったときの処理
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ネットワークエラー" message: @"インターネットに接続できませんでした。ネットワーク状況を確認して再度お試しください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [friendList count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [NSString stringWithFormat:@"   友達（%d）", [friendList count]];
    
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //友達一覧の表示
    NSString *cellIdentifier = @"CellFriendList";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableDictionary *dictionary = [friendList objectAtIndex:[indexPath row]];
    
    UIImageView *userImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *mutualLabel = (UILabel *)[cell viewWithTag:3];
    
    NSString *imageName = [dictionary objectForKey:FRIEND_IMAGE];
    if(![imageName isEqual:@""]) {
        //イメージをロードする
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PROFILE_IMAGE_PATH, imageName]];
        [YYImageLoader imageWithURL:imageURL completion:^(UIImage *image, NSError *error) {
            if (error) return;
            userImage.image = image;
        }];
    } else {
        //イメージが設定されていない場合はデフォルト
        [userImage setImage:[UIImage imageNamed:@"LiFE_ProfileImage.png"]];
    }
    
    //名前を表示
    nameLabel.text = [dictionary objectForKey:FRIEND_NAME];
    nameLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Medium" size:16.0f];
    //共通の友達数を表示
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userID = [ud objectForKey:@"UserID"];
    if([userID isEqualToString:[dictionary objectForKey:FRIEND_ID]]) {
        //自分だった場合、共通の友達の数は表示しない
        [mutualLabel setHidden:YES];
        
        //名前の位置を移動
        [nameLabel setFrame:CGRectMake(70, 22, 227, 21)];
    } else {
        [mutualLabel setHidden:NO];
        mutualLabel.text = [NSString stringWithFormat:@"共通の友達%@人", [dictionary objectForKey:FRIEND_MUTUAL]];
    }
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

//セルを選択した際に友達詳細へ遷移
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dictionary = [friendList objectAtIndex:[indexPath row]];

    FriendDetailViewController *friendDetailVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"friendDetail"];
    [friendDetailVC setFriendUserID:[dictionary objectForKey:FRIEND_ID]];
    [self.navigationController pushViewController:friendDetailVC animated:YES];
    
}

-(void)setFriendUserID:(NSString *)userID{
    friendUserID = userID;
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
