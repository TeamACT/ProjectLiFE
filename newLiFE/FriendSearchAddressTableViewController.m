//
//  FriendSearchAddressTableViewController.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/23.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "FriendSearchAddressTableViewController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "YYImageLoader.h"
#import "UITableView+ReloadDataWithCompletion.h"

@interface FriendSearchAddressTableViewController ()

@end

@implementation FriendSearchAddressTableViewController

#define ACCESS_SEARCH_ADDRESS_BOOK 0
#define ACCESS_SEARCH_FACEBOOK 1
#define ACCESS_APPLY 2

#define ALERT_RESULT -1//index引き継ぎにtagを利用しているので負の値を使用

#define FRIEND_ID @"FriendID"
#define FRIEND_NAME @"FriendName"
#define FRIEND_IMAGE @"FriendImage"
#define FRIEND_ADDRESS @"FriendAddress"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //境界線の隙間をなくす
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    switch (searchFriendType) {
        case SEARCH_FRIEND_ADDRESS_BOOK:
            self.navigationItem.title = @"連絡先";
            break;
        case SEARCH_FRIEND_FACEBOOK:
            self.navigationItem.title = @"Facebook";
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //テーブルビューのヘッダーにUIViewを置くことで空白部分を消す
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1)];
    self.tableView.tableHeaderView = view;
    
    [self searchFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchFriends{
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    friendList = [NSMutableArray array];
    searchResult = [NSMutableArray array];
    invitingIndexList = [NSMutableArray array];
    
    //連絡先のアドレスとfacebookの友達のアドレスを全て取得して送信
    switch (searchFriendType) {
        case SEARCH_FRIEND_ADDRESS_BOOK:{
            ABAddressBookRequestAccessWithCompletion(NULL, ^(bool granted, CFErrorRef error) {
                if(granted) {
                    //連絡先の使用を許可した場合
                    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                    CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(addressBook);
                    
                    // 配列の要素の数だけ繰り返す
                    for (int i = 0 ; i < CFArrayGetCount(records) ; i++) {
                        NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
                        
                        // 1レコード取得
                        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
                        
                        // メールアドレスを取得
                        NSString *address;
                        ABMutableMultiValueRef multi = ABRecordCopyValue(record, kABPersonEmailProperty);
                        if (ABMultiValueGetCount(multi) > 0) {
                            
                            //登録されている一番最初のアドレスだけ使用する
                            CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multi, 0);
                            address = (__bridge NSString *)emailRef;
                        } else {
                            //アドレスが登録されていない場合
                            continue;
                        }
                        NSLog(@"%@", address);
                        
                        // 名を取得
                        NSString *firstName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
                        if (firstName == nil) {
                            firstName = @""; // 無ければ空文字に
                        }
                        // 氏を取得
                        NSString *lastName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
                        if (lastName == nil) {
                            lastName = @""; // 無ければ空文字に
                        }
                        // 氏名を生成
                        NSString *name = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
                        
                        NSData *thumData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail);
                        
                        [dictionary setObject:name forKey:FRIEND_NAME];
                        [dictionary setObject:address forKey:FRIEND_ADDRESS];
                        [dictionary setObject:thumData != nil ? thumData : [NSNull null] forKey:FRIEND_IMAGE];
                        
                        [friendList addObject:dictionary];
                    }
                    
                    
                    //フレンド一覧を取得
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                    NSString *userID = [ud objectForKey:@"UserID"];
                    
                    NSURL *url = [NSURL URLWithString:URL_SEARCH_FRIEND_FROM_ADDRESS_BOOK];
                    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setPostValue:userID forKey:@"UserID"];
                    [request setPostValue:[NSNumber numberWithInt:[friendList count]] forKey:@"AddressCount"];
                    for(int i = 0; i < [friendList count]; i++) {
                        NSMutableDictionary *dictionary = [friendList objectAtIndex:i];
                        [request setPostValue:[dictionary objectForKey:FRIEND_ADDRESS] forKey:[NSString stringWithFormat:@"FriendAddress%d", i]];
                    }
                    [request setTag:ACCESS_SEARCH_ADDRESS_BOOK];
                    [request startAsynchronous];
                    
                } else {
                    [SVProgressHUD dismiss];
                    //許可しなかった場合
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:@"連絡先へのアクセスが有効になっていません。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            });
            break;
        }
        case SEARCH_FRIEND_FACEBOOK:{
            ACAccountStore *accountStore = [ACAccountStore new];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            NSDictionary *options = @{ACFacebookAppIdKey : @"708240455935864", ACFacebookPermissionsKey : @[@"basic_info"]};
            [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    // ユーザーがFacebookアカウントへのアクセスを許可した
                    NSArray *facebookAccounts = [accountStore accountsWithAccountType:accountType];
                    if (facebookAccounts.count > 0) {
                        ACAccount *facebookAccount = [facebookAccounts lastObject];
                        SLRequest *facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me"] parameters:nil];
                        [facebookRequest setAccount:facebookAccount];
                        [facebookRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                            
                            NSError *deserializationError;
                            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&deserializationError];
                            
                            if (userData != nil && deserializationError == nil) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    SLRequest *facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me/friends"] parameters:@{@"locale" : @"ja_JP", @"fields" : @"id"}];
                                    [facebookRequest setAccount:facebookAccount];
                                    [facebookRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                                        
                                        NSError* err = nil;
                                        NSMutableDictionary *rootDocument = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&err];
                                        
                                        NSMutableArray *friendData = [rootDocument objectForKey:@"data"];
                                        
                                        for(NSMutableDictionary *dict in friendData) {
                                            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
                                            [dictionary setObject:[dict objectForKey:@"id"] forKey:FRIEND_ID];
                                            
                                            [friendList addObject:dictionary];
                                        }
                                        
                                        //フレンド一覧を取得
                                        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                                        NSString *userID = [ud objectForKey:@"UserID"];
                                        
                                        NSURL *url = [NSURL URLWithString:URL_SEARCH_FRIEND_FROM_FACEBOOK];
                                        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                                        [request setTimeOutSeconds:60];
                                        [request setDelegate:self];
                                        [request setPostValue:userID forKey:@"UserID"];
                                        [request setPostValue:[NSNumber numberWithInt:[friendList count]] forKey:@"IDCount"];
                                        for(int i = 0; i < [friendList count]; i++) {
                                            NSMutableDictionary *dictionary = [friendList objectAtIndex:i];
                                            [request setPostValue:[dictionary objectForKey:FRIEND_ID] forKey:[NSString stringWithFormat:@"FriendFacebookID%d", i]];
                                        }
                                        [request setTag:ACCESS_SEARCH_FACEBOOK];
                                        [request startAsynchronous];
                                        
                                    }];
                                });
                            }
                        }];
                    }
                    
                } else {
                    [SVProgressHUD dismiss];
                    if([error code]== ACErrorAccountNotFound){
                        //  iOSに登録されているFacebookアカウントがありません。
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:@"Facebookアカウントが登録されていません。設定→FacebookからFacebookアカウントを追加してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    } else {
                        // ユーザーが許可しない
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:@"Facebookが有効になっていません。設定→Facebook→アカウントの使用許可よりLiFEを有効にしてください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    }
                    
                    NSLog(@"%@", error);
                }
            }];
            break;
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    int section = 1;
    
    //リクエストがある場合のみセクションを２つにする
    if([searchResult count] > 0) {
        section = 2;
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = 0;
    
    //リクエストがある場合で表示を分ける
    if([searchResult count] > 0) {
        switch (section) {
            case 0:
                row = [searchResult count];
                break;
            case 1:
                switch (searchFriendType) {
                    case SEARCH_FRIEND_ADDRESS_BOOK:
                        row = [friendList count] > 3 ? 3 : [friendList count];
                        break;
                    case SEARCH_FRIEND_FACEBOOK:
                        row = 1;
                        break;
                }
                break;
        }
    } else {
        switch (searchFriendType) {
            case SEARCH_FRIEND_ADDRESS_BOOK:
                row = [friendList count] > 3 ? 3 : [friendList count];
                break;
            case SEARCH_FRIEND_FACEBOOK:
                row = 1;
                break;
        }
    }
    
    return row;
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    switch ([request tag]) {
        case ACCESS_SEARCH_ADDRESS_BOOK:{
            NSData *response = [request responseData];
            NSArray *resultsIDs = PerformXMLXPathQuery(response, @"/tag/friend_user_id");
            NSArray *resultsNames = PerformXMLXPathQuery(response, @"/tag/friend_user_name");
            NSArray *resultsImages = PerformXMLXPathQuery(response, @"/tag/friend_user_image");
            
            for(int i = 0; i < [resultsIDs count]; i++) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                NSString *friendID = [[resultsIDs objectAtIndex:i] objectForKey:@"nodeContent"];
                NSString *friendName = [[resultsNames objectAtIndex:i] objectForKey:@"nodeContent"];
                NSString *friendImage = [[resultsImages objectAtIndex:i] objectForKey:@"nodeContent"];
                [dictionary setObject:friendID forKey:FRIEND_ID];
                [dictionary setObject:friendName == nil ? @"" : friendName forKey:FRIEND_NAME];
                [dictionary setObject:friendImage == nil ? @"" : friendImage forKey:FRIEND_IMAGE];
                
                [searchResult addObject:dictionary];
            }
            
            NSArray *resultsAddresses = PerformXMLXPathQuery(response, @"/tag/friend_user_address");
            NSMutableIndexSet* targetIndexes = [NSMutableIndexSet indexSet];
            for(int i = 0; i < [resultsAddresses count]; i++) {
                //LiFEに登録済みのユーザーは取得してきたリストから除外する
                NSString *friendAddress = [[resultsAddresses objectAtIndex:i] objectForKey:@"nodeContent"];
                NSUInteger index = 0;
                for(NSMutableDictionary *dictionary in friendList) {
                    if([[dictionary objectForKey:FRIEND_ADDRESS] isEqualToString:friendAddress]) {
                        [targetIndexes addIndex:index];
                        break;//もし同じメールアドレスが登録されていたとしてもここでは対応しない
                    }
                    index++;
                }
            }
            //取得してきたユーザーは利用前の知り合いリストから外す
            [friendList removeObjectsAtIndexes:targetIndexes];
            
            //リストを更新
            [self.tableView reloadDataWithCompletion:^{
                [SVProgressHUD dismiss];
            }];
            break;
        }
        case ACCESS_SEARCH_FACEBOOK:{
            NSData *response = [request responseData];
            NSArray *resultsIDs = PerformXMLXPathQuery(response, @"/tag/friend_user_id");
            NSArray *resultsNames = PerformXMLXPathQuery(response, @"/tag/friend_user_name");
            NSArray *resultsImages = PerformXMLXPathQuery(response, @"/tag/friend_user_image");
            
            for(int i = 0; i < [resultsIDs count]; i++) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                NSString *friendID = [[resultsIDs objectAtIndex:i] objectForKey:@"nodeContent"];
                NSString *friendName = [[resultsNames objectAtIndex:i] objectForKey:@"nodeContent"];
                NSString *friendImage = [[resultsImages objectAtIndex:i] objectForKey:@"nodeContent"];
                [dictionary setObject:friendID forKey:FRIEND_ID];
                [dictionary setObject:friendName == nil ? @"" : friendName forKey:FRIEND_NAME];
                [dictionary setObject:friendImage == nil ? @"" : friendImage forKey:FRIEND_IMAGE];
                
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    
    //リクエストがある場合で表示を分ける
    if([searchResult count] > 0) {
        switch (section) {
            case 0:
                title = [NSString stringWithFormat:@"   %d人の友達がLiFEを利用しています", [searchResult count]];
                break;
            case 1:
                switch (searchFriendType) {
                    case SEARCH_FRIEND_ADDRESS_BOOK:
                        title = @"   まだLiFEを利用していない友達";
                        break;
                    case SEARCH_FRIEND_FACEBOOK:
                        title = @"";
                        break;
                }
                break;
        }
    } else {
        switch (searchFriendType) {
            case SEARCH_FRIEND_ADDRESS_BOOK:
                title = @"   まだLiFEを利用していない友達";
                break;
            case SEARCH_FRIEND_FACEBOOK:
                title = @"";
                break;
        }
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    UITableViewCell* cell;
    
    if([searchResult count] > 0 && [indexPath section] == 0) {
        //取得してきたLiFEを利用している知り合いの一覧
        cellIdentifier = @"CellFriendAlready";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSMutableDictionary *dictionary = [searchResult objectAtIndex:[indexPath row]];
        
        UIImageView *userImage = (UIImageView *)[cell viewWithTag:1];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        UIButton *applyButton = (UIButton *)[cell viewWithTag:3];
        
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
        
        //ボタンに枠をつける
        applyButton.layer.borderColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0].CGColor;
        applyButton.layer.borderWidth = 1.0f;
        applyButton.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f];
        //アクションを設定
        applyButton.tag = indexPath.row;
        [applyButton addTarget:self action:@selector(applyFriend:event:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        //LiFEを利用していない知り合いの一覧
        switch (searchFriendType) {
            case SEARCH_FRIEND_ADDRESS_BOOK:{
                cellIdentifier = @"CellFriendInvite";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                int index = arc4random() % [friendList count];
                Boolean isSame = NO;
                do{
                    for(NSNumber *indexNum in invitingIndexList) {
                        if([indexNum intValue] == index) {
                            isSame = YES;
                            break;
                        }
                    }
                }while(isSame);
                [invitingIndexList addObject:[NSNumber numberWithInt:index]];
                
                NSMutableDictionary *dictionary = [friendList objectAtIndex:index];
                
                UIImageView *userImage = (UIImageView *)[cell viewWithTag:1];
                UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
                UIButton *inviteButton = (UIButton *)[cell viewWithTag:3];
                
                NSData *imageData = [dictionary objectForKey:FRIEND_IMAGE];
                if(![imageData isKindOfClass:[NSNull class]]) {
                    //イメージをロードする
                    [userImage setImage:[UIImage imageWithData:imageData]];
                } else {
                    //イメージが設定されていない場合はデフォルト
                    [userImage setImage:[UIImage imageNamed:@"LiFE_ProfileImage.png"]];
                }
                
                //名前を表示
                nameLabel.text = [dictionary objectForKey:FRIEND_NAME];
                nameLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Medium" size:16.0f];
                
                //ボタンに枠をつける
                inviteButton.layer.borderColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0].CGColor;
                inviteButton.layer.borderWidth = 1.0f;
                inviteButton.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f];
                //アクションを設定
                [inviteButton addTarget:self action:@selector(inviteFriendByMail:event:) forControlEvents:UIControlEventTouchUpInside];

                
                //セルはハイライトしない
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            }
            case SEARCH_FRIEND_FACEBOOK:{
                cellIdentifier = @"CellFriendMessenger";
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                
                UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
                nameLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Medium" size:16.0f];
                break;
            }
        }

    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)applyFriend:(UIButton *)sender event:(UIEvent *)event {
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    
    NSMutableDictionary *dictionary = [searchResult objectAtIndex:[indexPath row]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message:[NSString stringWithFormat:@"%@さんに友達申請をします。よろしいですか？", [dictionary objectForKey:FRIEND_NAME]] delegate:self  cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    [alertView setTag:[indexPath row]];
    [alertView show];
}

- (void)inviteFriendByMail:(UIButton *)sender event:(UIEvent *)event {
    //メールアカウントが登録されているかチェック
    if([MFMailComposeViewController canSendMail] == NO) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message: @"メールアドレスが登録されていません。設定より登録してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        //セルの選択を解除する
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForControlEvent:event];
    
    int index = [[invitingIndexList objectAtIndex:[indexPath row]] intValue];
    NSMutableDictionary *dictionary = [friendList objectAtIndex:index];
    
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    
    [mcvc setSubject:@"LiFEへのご招待"];
    [mcvc setToRecipients:[NSArray arrayWithObject:[dictionary objectForKey:FRIEND_ADDRESS]]];
    [mcvc setMessageBody:@"あなたもLiFEをはじめませんか？" isHTML:NO];
    
    // メールビュー表示
    [self presentViewController:mcvc animated:YES completion:nil];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ALERT_RESULT) {
        //再検索
        [self searchFriends];
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


// アプリ内メーラーのデリゲートメソッド
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            // キャンセル
            
            break;
        case MFMailComposeResultSaved:{
            // 保存
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"保存" message: @"下書きを保存しました。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            break;
        }
        case MFMailComposeResultSent:{
            // 送信成功
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"送信成功" message: @"メールを送信しました。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            break;
        }
        case MFMailComposeResultFailed:{
            // 送信失敗
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"送信失敗" message: @"メールの送信に失敗しました。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(searchFriendType == SEARCH_FRIEND_FACEBOOK) {
        if(([searchResult count] > 0 && [indexPath section] == 1) || ([searchResult count] == 0 && [indexPath section] == 0)) {
            //メッセンジャーを開く
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb-messenger://"]];
            } else {
                //メッセンジャーをappstoreで開く
                NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/jp/app/id454638411?mt=8"];
                [[UIApplication sharedApplication] openURL:url];
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
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


-(void)setSearchFriendType:(int) type{
    searchFriendType = type;
}

@end
