//
//  EditPasswordTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "EditPasswordTableViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"

@interface EditPasswordTableViewController ()

@end

@implementation EditPasswordTableViewController

#define TEXT_FIELD_RECENT 0
#define TEXT_FIELD_NEW 1
#define TEXT_FIELD_CONFIRM 2

#define ALERT_UPDATE_CONFIRM 0
#define ALERT_UPDATE_COMPLETE 1
#define ALERT_CANNOT_UPDATE 2

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    int loginKind = [ud integerForKey:@"LoginKind"];
    
    if(loginKind != LOG_IN_NORMAL) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"確認" message:@"メールアドレスから登録した場合以外、パスワードの変更は出来ません。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = ALERT_CANNOT_UPDATE;
        [alertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellEditPassword"];
    
    UITextField *passwordTF = (UITextField *)[cell viewWithTag:1];
    passwordTF.delegate = self;
    
    switch ([indexPath section]) {
        case 0:
            [passwordTF setPlaceholder:@"現在のパスワード"];
            passwordTF.tag = TEXT_FIELD_RECENT;
            break;
        case 1:
            [passwordTF setPlaceholder:@"新しいパスワード"];
            passwordTF.tag = TEXT_FIELD_NEW;
            break;
        case 2:
            [passwordTF setPlaceholder:@"新しいパスワードを再入力"];
            passwordTF.tag = TEXT_FIELD_CONFIRM;
            break;
        default:
            break;
    }
    
    //セルはハイライトしない
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellEditPassword"];
    }
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch(section) {
        case 0:
            title = @"現在のパスワード";
            break;
        case 1:
            title = @"新しいパスワード";
            break;
        case 2:
            title = @"新しいパスワードを再入力";
            break;
    }
    return title;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
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
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    //グローバルな値に入力値を保存
    switch([textField tag]) {
        case TEXT_FIELD_RECENT:
            recentPass = [textField text];
            break;
        case TEXT_FIELD_NEW:
            newPass = [textField text];
            break;
        case TEXT_FIELD_CONFIRM:
            confirmPass = [textField text];
            break;
    }
    
    NSLog(@"recent:%@", recentPass);
    NSLog(@"new:%@", newPass);
    NSLog(@"confirm:%@", confirmPass);
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)updatePassword:(id)sender {
    //キーボードが開いていたら閉じる
    [self.view endEditing:YES];
    
    //パスワード更新する確認アラートを表示
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"確認" message:@"パスワードを変更します。よろしいですか？" delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
    alertView.tag = ALERT_UPDATE_CONFIRM;
    [alertView show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch([alertView tag]) {
        case ALERT_UPDATE_CONFIRM:
            switch (buttonIndex) {
                case 1:{
                    // YESの処理
                    //本来ならサーバーで整合性チェック（今回は新しいパスワードをそのまま保存）
                    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                    //パスワードを更新
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                    NSString *userID = [ud objectForKey:@"UserID"];
                    
                    NSURL *url = [NSURL URLWithString:URL_UPDATE_PASSWORD];
                    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                    [request setTimeOutSeconds:60];
                    [request setDelegate:self];
                    [request setPostValue:userID forKey:@"UserID"];
                    [request setPostValue:recentPass forKey:@"OldPassword"];
                    [request setPostValue:newPass forKey:@"NewPassword"];
                    [request setPostValue:confirmPass forKey:@"ConfirmPassword"];
                    [request startAsynchronous];
                    
                    break;
                }
            }
            break;
        case ALERT_UPDATE_COMPLETE:
            //完了のアラートを閉じたら設定に戻る
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case ALERT_CANNOT_UPDATE:
            //アラートを閉じたら設定に戻る
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    //返ってきた内容をNSDefaultに保持
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSData *response = [request responseData];
    NSArray *results = PerformXMLXPathQuery(response, @"/tag/update_result");
    if ([results count] != 0) {
        if([[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] == 1) {
            //登録成功
            results = PerformXMLXPathQuery(response, @"/tag/user_password");
            [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserPassword"];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"完了" message:@"パスワードが変更されました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alertView.tag = ALERT_UPDATE_COMPLETE;
            [alertView show];
        } else {
            //登録失敗
            NSString *faultReason = @"不明なエラーです。";
            NSArray *faultResult = PerformXMLXPathQuery(response, @"/tag/fault_reason");
            if ([faultResult count] != 0) {
                faultReason = [[faultResult objectAtIndex:0] objectForKey:@"nodeContent"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"失敗" message:faultReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
    [ud synchronize];
    
}

//httpリクエスト失敗時の処理
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    // 通信ができなかったときの処理
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ネットワークエラー" message: @"インターネットに接続できませんでした。ネットワーク状況を確認して再度お試しください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

@end