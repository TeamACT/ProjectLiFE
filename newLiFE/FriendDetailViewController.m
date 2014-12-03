//
//  FriendDetailViewController.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/12/03.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "FriendFriendListTableViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "YYImageLoader.h"

@interface FriendDetailViewController ()

@end

@implementation FriendDetailViewController

#define ACCESS_DATA 0

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //ユーザーIDからフレンドの情報を取得
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    //フレンドの詳細を取得
    NSURL *url = [NSURL URLWithString:URL_GET_FRIEND_DETAIL];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:friendUserID forKey:@"UserID"];
    [request setTag:ACCESS_DATA];
    [request startAsynchronous];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    switch([request tag]){
        case ACCESS_DATA: {
            NSData *response = [request responseData];
            
            //名前
            NSArray *results = PerformXMLXPathQuery(response, @"/tag/user_name");
            NSString *friendName = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
            self.nameLabel.text = friendName;
            self.navigationItem.title = friendName;
            
            //画像
            results = PerformXMLXPathQuery(response, @"/tag/user_image");
            NSString *friendImage = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
            if(friendImage != nil) {
                //イメージをロードする
                NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PROFILE_IMAGE_PATH, friendImage]];
                [YYImageLoader imageWithURL:imageURL completion:^(UIImage *image, NSError *error) {
                    if (error) return;
                    self.profileImageView.image = image;
                }];
            } else {
                //イメージが設定されていない場合はデフォルト
                [self.profileImageView setImage:[UIImage imageNamed:@"LiFE_ProfileImage.png"]];
            }
            
            //友達の人数
            results = PerformXMLXPathQuery(response, @"/tag/friend_count");
            int friendCount = [[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue];
            [self.friendCountLabel setText:[NSString stringWithFormat:@"%d", friendCount]];
            
            //目標達成数
            results = PerformXMLXPathQuery(response, @"/tag/title_count");
            int titleCount = [[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue];
            [self.titleCountLabel setText:[NSString stringWithFormat:@"%d", titleCount]];
            
            //チャレンジ情報数
            results = PerformXMLXPathQuery(response, @"/tag/challenge_count");
            int challengeCount = [[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue];
            [self.challengeCountLabel setText:[NSString stringWithFormat:@"%d", challengeCount]];
            
            [SVProgressHUD dismiss];
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


-(void)setFriendUserID:(NSString *)userID{
    friendUserID = userID;
}

- (IBAction)transferFriendList:(id)sender {
    FriendFriendListTableViewController *friendFriendTableVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"friendFriendList"];
    [friendFriendTableVC setFriendUserID:friendUserID];
    [self.navigationController pushViewController:friendFriendTableVC animated:YES];
}

- (IBAction)transferTitleList:(id)sender {
}

- (IBAction)transferChallengeList:(id)sender {
}
@end
