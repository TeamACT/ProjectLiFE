//
//  SettingTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/08/29.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "SettingTableViewController.h"
#import "MenuDrawerViewController.h"
#import "EditNoticeTableViewController.h"

#import "UploadHelper.h"
#import "DatabaseHelper.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

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
    
    //データを更新する
    UploadHelper *uploadHelper = [[UploadHelper alloc] init];
    [uploadHelper dataUpload:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"logOutSegue"]) {
        //ログアウト処理
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"確認" message: @"ログアウトします。よろしいですか？" delegate:self cancelButtonTitle:@"いいえ" otherButtonTitles:@"はい", nil];
        [alertView show];
        
        return NO;
    } else if([identifier isEqualToString:@"saveOnServerSegue"]) {
        [SVProgressHUD showWithStatus:@"ログをサーバーに保存しています..." maskType:SVProgressHUDMaskTypeBlack];
        UploadHelper *uploadHelper = [[UploadHelper alloc] init];
        [uploadHelper logUpload:^{
            [SVProgressHUD dismiss];
            //ログアウトのセルの選択状態を解除する
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
        
        return NO;
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditNoticeTableViewController *editNoticeViewController = [segue destinationViewController];
    
    if ( [[segue identifier] isEqualToString:@"EditNoticePushSegue"] ) {
        editNoticeViewController.editingNotice = EDIT_NOTICE_PUSH;
        editNoticeViewController.navigationItem.title = @"プッシュ通知";
    } else if ( [[segue identifier] isEqualToString:@"EditNoticeMailSegue"] ) {
        editNoticeViewController.editingNotice = EDIT_NOTICE_MAIL;
        editNoticeViewController.navigationItem.title = @"お知らせメール";
    }
}

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    switch(buttonIndex) {
        case 0:{
            //ログアウトのセルの選択状態を解除する
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        }
        case 1:{
            
            //UserDefaultsからUserIDを消す
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
            [ud setObject:@"" forKey:@"UserID"];
            [ud synchronize];
            
            //データベースも空にする
            DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
            [dbHelper initialize];
            
            //開始画面へ遷移
            UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"start"];
            self.slidingViewController.topViewController = newTopViewController;
            break;
        }
        default:
            break;
    }
}

@end