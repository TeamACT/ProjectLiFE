//
//  TopViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "TopViewController.h"

#import "LoginViewController.h"

@interface TopViewController ()

@end

@implementation TopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ナビゲーションバーの色とテキスト色を変更（全画面に適用）
    UIColor *barBackColor = [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:barBackColor];
    UIColor *barItemColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    [[UIBarButtonItem appearance] setTintColor:barItemColor];
    //戻るボタンの画像を設定
    UIImage *backImg = [[UIImage imageNamed:@"LiFE_Common_BackButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backImg forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    
    //ページングビューの設定
    self.pagingView.delegate = self;
    [self.pagingView setContentSize:CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.pagingView setContentOffset:CGPointMake(0, 0)];
    self.pagingControl.currentPage = 0;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];//ナビゲーションバーを非表示
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    if((NSInteger) fmod(scrollView.contentOffset.x, pageWidth) == 0) {
        self.pagingControl.currentPage = scrollView.contentOffset.x / pageWidth;
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    LoginViewController *newTopViewController = [segue destinationViewController];
    
    if ( [[segue identifier] isEqualToString:@"StartRegisterSegue"] ) {
        newTopViewController.flag = START_REGISTER;
        newTopViewController.navigationItem.title = @"新規登録";
    } else if ( [[segue identifier] isEqualToString:@"StartLoginSegue"] ) {
        newTopViewController.flag = START_LOGIN;
        newTopViewController.navigationItem.title = @"ログイン";
    }
}

@end
