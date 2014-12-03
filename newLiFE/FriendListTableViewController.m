//
//  FriendListTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendListTableViewController.h"
#import "MenuDrawerViewController.h"
#import "FriendDetailViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "AsyncImageView.h"
#import "YYImageLoader.h"
#import "UITableView+ReloadDataWithCompletion.h"

@interface FriendListTableViewController ()

@end

@implementation FriendListTableViewController

#define ACCESS_LIST 0
#define ACCESS_APPROVE 1
#define ACCESS_DENY 2

#define ALERT_APPROVE 0
#define ALERT_DENY 1
#define ALERT_COMPLETE 2

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
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    self.slidingViewController.delegate = self;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    friendList = [NSMutableArray array];
    requestList = [NSMutableArray array];
    
    //フレンド一覧を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userID = [ud objectForKey:@"UserID"];
    
    NSURL *url = [NSURL URLWithString:URL_GET_FRIEND_LIST];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:userID forKey:@"UserID"];
    [request setTag:ACCESS_LIST];
    [request startAsynchronous];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    switch([request tag]){
        case ACCESS_LIST: {
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
            resultsIDs = PerformXMLXPathQuery(response, @"/tag/request_user_id");
            resultsNames = PerformXMLXPathQuery(response, @"/tag/request_user_name");
            resultsImages = PerformXMLXPathQuery(response, @"/tag/request_user_image");
            resultsMutuals = PerformXMLXPathQuery(response, @"/tag/request_mutual_friends");
            
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
                
                [requestList addObject:dictionary];
            }
            
            //リストを更新
            [self.tableView reloadDataWithCompletion:^{
                [SVProgressHUD dismiss];
            }];
            
            break;
        }
        case ACCESS_APPROVE:{
            
            NSMutableDictionary *dictionary = [requestList objectAtIndex:requestRowIndex];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"完了" message:[NSString stringWithFormat:@"%@さんと友達になりました！", [dictionary objectForKey:FRIEND_NAME]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setTag:ALERT_COMPLETE];
            [alertView show];
            break;
        }
        case ACCESS_DENY:{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:@"友達申請を拒否しました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setTag:ALERT_COMPLETE];
            [alertView show];
            break;
        }
            
    }
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
    int section = 1;
    
    //リクエストがある場合のみセクションを２つにする
    if([requestList count] > 0) {
        section = 2;
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = 0;
    
    //リクエストがある場合で表示を分ける
    if([requestList count] > 0) {
        switch (section) {
            case 0:
                row = [requestList count];
                break;
            case 1:
                row = [friendList count];
                break;
        }
    } else {
        row = [friendList count];
    }
    
    return row;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    
    //リクエストがある場合で表示を分ける
    if([requestList count] > 0) {
        switch (section) {
            case 0:
                title = [NSString stringWithFormat:@"   リクエスト（%d）", [requestList count]];
                break;
            case 1:
                title = [NSString stringWithFormat:@"   友達（%d）", [friendList count]];
                break;
        }
    } else {
        title = [NSString stringWithFormat:@"   友達（%d）", [friendList count]];
    }
    
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    UITableViewCell* cell;
    
    if([requestList count] > 0 && [indexPath section] == 0) {
        //リクエスト一覧の表示
        cellIdentifier = @"CellFriendRequest";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSMutableDictionary *dictionary = [requestList objectAtIndex:[indexPath row]];
        
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
        mutualLabel.text = [NSString stringWithFormat:@"共通の友達%@人", [dictionary objectForKey:FRIEND_MUTUAL]];
        
        UIButton *approveButton = (UIButton *)[cell viewWithTag:4];
        UIButton *denyButton = (UIButton *)[cell viewWithTag:5];
        //ボタンに枠をつける
        approveButton.layer.borderColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0].CGColor;
        approveButton.layer.borderWidth = 1.0f;
        approveButton.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f];
        //アクションを設定
        [approveButton addTarget:self action:@selector(approveFriend:event:) forControlEvents:UIControlEventTouchUpInside];
        
        //ボタンに枠をつける
        denyButton.layer.borderColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0].CGColor;
        denyButton.layer.borderWidth = 1.0f;
        denyButton.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f];
        //アクションを設定
        [denyButton addTarget:self action:@selector(denyFriend:event:) forControlEvents:UIControlEventTouchUpInside];
        
        
    } else {
        //友達一覧の表示
        cellIdentifier = @"CellFriendList";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
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
    NSMutableDictionary *dictionary;
    
    if([requestList count] > 0) {
        switch ([indexPath section]) {
            case 0:
                dictionary = [requestList objectAtIndex:[indexPath row]];
                break;
            case 1:
                dictionary = [friendList objectAtIndex:[indexPath row]];
                break;
        }
    } else {
        dictionary = [friendList objectAtIndex:[indexPath row]];
    }
    
    FriendDetailViewController *friendDetailVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"friendDetail"];
    [friendDetailVC setFriendUserID:[dictionary objectForKey:FRIEND_ID]];
    [self.navigationController pushViewController:friendDetailVC animated:YES];
    
}

- (void)approveFriend:(UIButton *)sender event:(UIEvent *)event {
    //申請を承認
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    
    requestRowIndex = [indexPath row];
    
    NSMutableDictionary *dictionary = [requestList objectAtIndex:requestRowIndex];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:[NSString stringWithFormat:@"%@さんのリクエストを承認します。よろしいですか？", [dictionary objectForKey:FRIEND_NAME]] delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    [alertView setTag:ALERT_APPROVE];
    [alertView show];
}

- (void)denyFriend:(UIButton *)sender event:(UIEvent *)event {
    //申請を拒否
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    
    requestRowIndex = [indexPath row];
    
    NSMutableDictionary *dictionary = [requestList objectAtIndex:requestRowIndex];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:[NSString stringWithFormat:@"%@さんのリクエストを削除します。よろしいですか？", [dictionary objectForKey:FRIEND_NAME]] delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    [alertView setTag:ALERT_DENY];
    [alertView show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch([alertView tag]) {
        case ALERT_APPROVE:{
            switch (buttonIndex) {
                case 0:
                    break;
                case 1:{
                    //申請の処理
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                    
                    NSMutableDictionary *dictionary = [requestList objectAtIndex:requestRowIndex];
                    
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                    NSString *userID = [ud objectForKey:@"UserID"];
                    NSURL *url = [NSURL URLWithString:URL_APPROVE_FRIEND];
                    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setPostValue:userID forKey:@"UserID"];
                    [request setPostValue:[dictionary objectForKey:FRIEND_ID] forKey:@"FriendUserID"];
                    [request setTag:ACCESS_APPROVE];
                    [request startAsynchronous];
                    break;
                }
            }
            break;
        }
        case ALERT_DENY:{
            switch (buttonIndex) {
                case 0:
                    break;
                case 1:{
                    //拒否の処理
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                    
                    NSMutableDictionary *dictionary = [requestList objectAtIndex:requestRowIndex];
                    
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                    NSString *userID = [ud objectForKey:@"UserID"];
                    NSURL *url = [NSURL URLWithString:URL_DENY_FRIEND];
                    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setPostValue:userID forKey:@"UserID"];
                    [request setPostValue:[dictionary objectForKey:FRIEND_ID] forKey:@"FriendUserID"];
                    [request setTag:ACCESS_DENY];
                    [request startAsynchronous];
                    break;
                }
            }
            break;
        }
        case ALERT_COMPLETE:{
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            
            friendList = [NSMutableArray array];
            requestList = [NSMutableArray array];
            
            //フレンド一覧を取得
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
            NSString *userID = [ud objectForKey:@"UserID"];
            
            NSURL *url = [NSURL URLWithString:URL_GET_FRIEND_LIST];
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
            [request setTimeOutSeconds:60];
            [request setDelegate:self];
            [request setPostValue:userID forKey:@"UserID"];
            [request setTag:ACCESS_LIST];
            [request startAsynchronous];
            
            break;
        }
    }
}

//タッチした位置からインデックスパスを取得
-(NSIndexPath *)indexPathForControlEvent:(UIEvent *)event {
    UITouch *touch=[[event allTouches] anyObject];
    CGPoint p=[touch locationInView:self.tableView];
    NSIndexPath *indexPath=[self.tableView indexPathForRowAtPoint:p];
    return indexPath;
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

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}
@end
