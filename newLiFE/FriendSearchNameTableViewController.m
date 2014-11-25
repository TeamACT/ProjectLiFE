//
//  FriendSearchTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/15.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendSearchNameTableViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "YYImageLoader.h"
#import "UITableView+ReloadDataWithCompletion.h"

@interface FriendSearchNameTableViewController ()

@end

@implementation FriendSearchNameTableViewController

#define ACCESS_SEARCH 0
#define ACCESS_APPLY 1

#define ALERT_RESULT -1//index引き継ぎにtagを利用しているので負の値を使用

#define FRIEND_ID @"FriendID"
#define FRIEND_NAME @"FriendName"
#define FRIEND_IMAGE @"FriendImage"
#define FRIEND_MUTUAL @"MutualFriends"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //境界線の隙間をなくす
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    self.navigationItem.title = @"名前";
    
    self.friendSearchBar.delegate = self;
    [self.friendSearchBar sizeToFit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    return [searchResult count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellFriendSearchName"];
    
    NSMutableDictionary *dictionary = [searchResult objectAtIndex:[indexPath row]];
    
    UIImageView *userImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *mutualLabel = (UILabel *)[cell viewWithTag:3];
    UIButton *applyButton = (UIButton *)[cell viewWithTag:4];
    
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
    
    //ボタンに枠をつける
    applyButton.layer.borderColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0].CGColor;
    applyButton.layer.borderWidth = 1.0f;
    applyButton.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f];
    //アクションを設定
    applyButton.tag = indexPath.row;
    [applyButton addTarget:self action:@selector(applyFriend:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //セルはハイライトしない
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellFriendSearchName"];
    }
    
    return cell;
}

-(void)searchBarSearchButtonClicked: (UISearchBar*)searchBar{
    //ソフトキーボードをしまう
    [self.view endEditing:YES];
    
    //検索ワードを保存
    searchedWord = [searchBar text];
    
    //検索結果をリセット
    searchResult = [NSMutableArray array];
    
    //入力キーワードで検索
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    //フレンド一覧を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userID = [ud objectForKey:@"UserID"];
    
    NSURL *url = [NSURL URLWithString:URL_SEARCH_FRIEND];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:userID forKey:@"UserID"];
    [request setPostValue:searchedWord forKey:@"SearchingWord"];
    [request setTag:ACCESS_SEARCH];
    [request startAsynchronous];
    
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    switch ([request tag]) {
        case ACCESS_SEARCH:{
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
                
                [searchResult addObject:dictionary];
            }
            
            //リストを更新
            [self.tableView reloadDataWithCompletion:^{
                [SVProgressHUD dismiss];
            }];
            break;
        }
        case ACCESS_APPLY:{
            //申請完了
            NSData *response = [request responseData];
            NSArray *results = PerformXMLXPathQuery(response, @"/tag/apply_result");
            
            [SVProgressHUD dismiss];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"結果" message:[[results objectAtIndex:0] objectForKey:@"nodeContent"] delegate:self  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView setTag:ALERT_RESULT];
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

- (void)applyFriend:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    
    NSMutableDictionary *dictionary = [searchResult objectAtIndex:[indexPath row]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:[NSString stringWithFormat:@"%@さんに友達申請をします。よろしいですか？", [dictionary objectForKey:FRIEND_NAME]] delegate:self  cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    [alertView setTag:[indexPath row]];
    [alertView show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ALERT_RESULT) {
        //再検索
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        //検索結果をリセット
        searchResult = [NSMutableArray array];
        //フレンド一覧を取得
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
        NSString *userID = [ud objectForKey:@"UserID"];
        
        NSURL *url = [NSURL URLWithString:URL_SEARCH_FRIEND];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        [request setTimeOutSeconds:60];
        [request setDelegate:self];
        [request setPostValue:userID forKey:@"UserID"];
        [request setPostValue:searchedWord forKey:@"SearchingWord"];
        [request setTag:ACCESS_SEARCH];
        [request startAsynchronous];
    } else {
        switch (buttonIndex) {
            case 0:
                break;
            case 1: {
                //申請の処理
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                
                NSMutableDictionary *dictionary = [searchResult objectAtIndex:alertView.tag];
                
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                NSString *userID = [ud objectForKey:@"UserID"];
                
                NSURL *url = [NSURL URLWithString:URL_APPLY_FRIEND];
                ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                [request setTimeOutSeconds:60];
                [request setDelegate:self];
                [request setPostValue:userID forKey:@"UserID"];
                [request setPostValue:[dictionary objectForKey:FRIEND_ID] forKey:@"FriendUserID"];
                [request setTag:ACCESS_APPLY];
                [request startAsynchronous];
                
                break;
            }
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

@end
