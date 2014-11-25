//
//  InformationTableViewController.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "InformationTableViewController.h"

#import "MenuDrawerViewController.h"

@interface InformationTableViewController ()

@end

@implementation InformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    self.slidingViewController.delegate = self;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = 0;
    
    switch(section) {
        case 0:
            row = 3;
            break;
        case 1:
            row = 3;
            break;
        case 2:
            row = 1;
            break;
    }
    
    return row;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    
    if([indexPath section] == 0 && [indexPath row] == 0) {
        cellIdentifier = @"CellInfoBadge";//バッジ付きのセル
    } else if([indexPath section] == 2 && [indexPath row] == 0) {
        cellIdentifier = @"CellInfoLabel";//ラベル付きのセル
    } else {
        cellIdentifier = @"CellInfoNormal";//矢印アクセのみのセル
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:2];
    
    switch([indexPath section]) {
        case 0:
            switch([indexPath row]) {
                case 0: {
                    //お知らせ
                    [titleLabel setText:@"お知らせ"];
                    
                    //バッジの設定
                    [[contentLabel layer] setCornerRadius:10.0];
                    [[contentLabel layer] setMasksToBounds:YES];
                    [contentLabel setBackgroundColor:[UIColor colorWithRed:0.165 green:0.675 blue:0.435 alpha:1.0]];
                    [contentLabel setTextColor:[UIColor whiteColor]];
                    
                    NSString *count = @"1";//本来ならここで未読数を取得
                    [contentLabel setText:count];
                    CGSize size = [count sizeWithAttributes:@{NSFontAttributeName:contentLabel.font}];
                    [contentLabel setFrame:CGRectMake(0, 0, (size.width + 6.0 < 20.0 ? 20.0 : size.width+ 6.0), 20.0)];
                    contentLabel.center = CGPointMake(268, 22);
                    break;
                }
                case 1:
                    //ご意見・ご要望
                    [titleLabel setText:@"ご意見・ご要望"];
                    break;
                case 2:
                    //アプリのレビューを書く
                    [titleLabel setText:@"アプリのレビューを書く"];
                    break;
            }
            break;
        case 1:
            switch([indexPath row]) {
                case 0:
                    //ヘルプ
                    [titleLabel setText:@"ヘルプ"];
                    break;
                case 1:
                    //プライバシーポリシー
                    [titleLabel setText:@"プライバシーポリシー"];
                    break;
                case 2:
                    //利用規約
                    [titleLabel setText:@"利用規約"];
                    break;
                    /*
                     case 3:
                     //Webサイト
                     [titleLabel setText:@"Webサイト"];
                     break;*/
            }
            break;
        case 2:
            switch([indexPath row]) {
                case 0:
                    //バージョン情報
                    [titleLabel setText:@"バージョン情報"];
                    NSString *versionNo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                    [contentLabel setText:versionNo];
                    //セルはハイライトしない
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
            }
            break;
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //セルを押したときの処理
    switch([indexPath section]) {
        case 0:
            switch([indexPath row]) {
                case 0: {
                    //お知らせ画面へ遷移（navigation）
                    break;
                }
                case 1: {
                    //ご意見・ご要望
                    //メールアカウントが登録されているかチェック
                    if([MFMailComposeViewController canSendMail] == NO) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message: @"メールアドレスが登録されていません。設定より登録してください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        
                        //セルの選択を解除する
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
                        
                        return;
                    }
                    
                    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
                    mcvc.mailComposeDelegate = self;
                    
                    
                    [mcvc setSubject:@"LiFEに関するご意見・ご要望"];
                    [mcvc setToRecipients:[NSArray arrayWithObject:@"yawata@a-c-t.co.jp"]];
                    
                    // メールビュー表示
                    [self presentViewController:mcvc animated:YES completion:nil];
                    
                    break;
                }
                case 2:{
                    //アプリのレビューを書く
                    NSURL *url = [NSURL URLWithString:@"itms://itunes.com/apps/｛アプリ名｝"];
                    [[UIApplication sharedApplication] openURL:url];
                    
                    break;
                }
            }
            break;
        case 1:
            switch([indexPath row]) {
                case 0:
                    //ヘルプ
                    break;
                case 1:
                    //プライバシーポリシー
                    break;
                case 2:
                    //利用規約
                    break;
                    /*
                     case 3:
                     //Webサイト
                     break;*/
            }
            break;
        case 2:
            switch([indexPath row]) {
                case 0:
                    //バージョン情報（処理なし）
                    break;
            }
            break;
    }
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
