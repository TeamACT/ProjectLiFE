//
//  LoginViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/12.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "LoginViewController.h"

#import "DayViewController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "UploadHelper.h"
#import "DatabaseHelper.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize flag;

#define ACCESS_REGISTER 0
#define ACCESS_LOGIN 1
#define ACCESS_FACEBOOK_REGISTER 2

#define ALERT_REGISTER 0
#define ALERT_LOGIN 1



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
    
    //TextFieldを初期化
    self.nameTextField.text=@"";
    self.nameTextField.delegate = self;
    self.mailTextField.text=@"";
    self.mailTextField.delegate = self;
    self.passTextField.text=@"";
    self.passTextField.delegate = self;
    
    /***** 画面パーツ初期化　*****/
    if(flag == START_REGISTER){
        self.backgroundIamge.image = [UIImage imageNamed:@"LiFE_Login_RegisterBackground.png"];
        self.nameTextField.hidden = NO;
        [self.facebookButton setTitle:@"Facebookで登録" forState:UIControlStateNormal];
        [self.loginButton setTitle:@"登録" forState:UIControlStateNormal];
        
        NSString *helpStr = @"登録の前に利用規約をお読みください。";
        NSMutableAttributedString *attrHelpStr = [[NSMutableAttributedString alloc] initWithString:helpStr];
        [attrHelpStr addAttribute:NSForegroundColorAttributeName
                            value:[UIColor blackColor]
                            range:NSMakeRange(0, [attrHelpStr length])];
        [attrHelpStr addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"SourceHanSansJP-Light" size:15]
                            range:NSMakeRange(0, [attrHelpStr length])];
        [attrHelpStr addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"SourceHanSansJP-Medium" size:15]
                            range:[helpStr rangeOfString:@"利用規約"]];
        [self.helpButton setAttributedTitle:attrHelpStr forState:UIControlStateNormal];
        
        
    }else if(flag == START_LOGIN){
        self.backgroundIamge.image = [UIImage imageNamed:@"LiFE_Login_LoginBackground.png"];
        self.passTextField.center = self.mailTextField.center;
        self.mailTextField.center = self.nameTextField.center;
        self.nameTextField.hidden = YES;
        [self.facebookButton setTitle:@"Facebookでログイン" forState:UIControlStateNormal];
        [self.loginButton setTitle:@"ログイン" forState:UIControlStateNormal];
        self.loginButton.center = CGPointMake(self.loginButton.center.x, self.loginButton.center.y - 46);
        [self.helpButton setTitle:@"パスワードを忘れた場合はこちら" forState:UIControlStateNormal];
        self.helpButton.center = CGPointMake(self.helpButton.center.x, self.helpButton.center.y - 46);
    }
    
    [self.scrollView setScrollEnabled:NO];//スクロールは手動ではできなくする
    
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
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];//ナビゲーションバーを表示
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //選択されたTextFieldの入力適正位置までスクロールする
    [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 250) animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //初期位置に戻す
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    //キーボードを隠す
    [self.view endEditing:YES];
    
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)loginButtonAction:(UIButton *)sender {
    //初期位置に戻す
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    //キーボードを隠す
    [self.view endEditing:YES];
    
    NSString *userName = ([self.nameTextField.text length] <= 0) ? @"" : self.nameTextField.text;
    NSString *mailAddress = ([self.mailTextField.text length] <= 0) ? @"" : self.mailTextField.text;
    NSString *password = ([self.passTextField.text length] <= 0) ? @"" : self.passTextField.text;
    
    if(flag == START_REGISTER){
        //新規登録
        NSURL *url = [NSURL URLWithString:URL_REGISTER];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [request setTimeOutSeconds:60];
        [request setDelegate:self];
        [request setPostValue:userName forKey:@"UserName"];
        [request setPostValue:mailAddress forKey:@"MailAddress"];
        [request setPostValue:password forKey:@"Password"];
        [request setPostValue:[NSNumber numberWithInt:LOG_IN_NORMAL] forKey:@"LoginKind"];
        [request setTag:ACCESS_REGISTER];
        [request startAsynchronous];
    } else if(flag == START_LOGIN){
        //ログイン
        NSURL *url = [NSURL URLWithString:URL_LOGIN];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [request setTimeOutSeconds:60];
        [request setDelegate:self];
        [request setPostValue:mailAddress forKey:@"MailAddress"];
        [request setPostValue:password forKey:@"Password"];
        [request setPostValue:[NSNumber numberWithInt:LOG_IN_NORMAL] forKey:@"LoginKind"];
        [request setTag:ACCESS_LOGIN];
        [request startAsynchronous];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
}

- (IBAction)helpButtonAction:(id)sender {
    if(flag == START_REGISTER){
        //利用規約を開く
    } else if(flag == START_LOGIN) {
        //パスワード再設定画面を開く
        UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"forgetPassword"];
        controller.navigationItem.title = @"パスワードの再設定";
        [self.navigationController pushViewController:controller animated:YES];
    }
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    switch(request.tag) {
        case ACCESS_REGISTER:{
            [SVProgressHUD dismiss];
            
            //返ってきた内容をNSDefaultに保持
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            
            NSData *response = [request responseData];
            NSArray *results = PerformXMLXPathQuery(response, @"/tag/register_result");
            if ([results count] != 0) {
                if([[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] == 1) {
                    //登録成功
                    results = PerformXMLXPathQuery(response, @"/tag/user_ID");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserID"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_name");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserName"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_mail_address");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserMailAddress"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_password");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserPassword"];
                    results = PerformXMLXPathQuery(response, @"/tag/login_kind");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue]forKey:@"LoginKind"];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"登録完了" message: @"登録が完了しました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    alertView.tag = ALERT_REGISTER;
                    [alertView show];
                    
                } else {
                    //登録失敗
                    NSString *faultReason = @"不明なエラーです。";
                    NSArray *faultResult = PerformXMLXPathQuery(response, @"/tag/fault_reason");
                    if ([faultResult count] != 0) {
                        faultReason = [[faultResult objectAtIndex:0] objectForKey:@"nodeContent"];
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"登録失敗" message:faultReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            [ud synchronize];
            
            break;
        }
            
        case ACCESS_LOGIN:{
            [SVProgressHUD dismiss];
            
            //返ってきた内容をNSDefaultに保持
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            
            NSData *response = [request responseData];
            NSArray *results = PerformXMLXPathQuery(response, @"/tag/register_result");
            if ([results count] != 0) {
                if([[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] == 1) {
                    //ログイン成功
                    results = PerformXMLXPathQuery(response, @"/tag/user_ID");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserID"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_name");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserName"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_real_name");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserRealName"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_mail_address");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserMailAddress"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_password");
                    [ud setObject:[[results objectAtIndex:0] objectForKey:@"nodeContent"] forKey:@"UserPassword"];
                    results = PerformXMLXPathQuery(response, @"/tag/login_kind");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue]forKey:@"LoginKind"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_height");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"UserHeight"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_weight");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"UserWeight"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_birthday");
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *fromFormatDate = [dateFormatter dateFromString:[[results objectAtIndex:0] objectForKey:@"nodeContent"]];
                    [ud setObject:fromFormatDate forKey:@"UserBirthDay"];
                    results = PerformXMLXPathQuery(response, @"/tag/user_gender");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"UserGender"];
                    results = PerformXMLXPathQuery(response, @"/tag/share_profile");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"ShareProfile"];
                    results = PerformXMLXPathQuery(response, @"/tag/share_activity");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"ShareActivity"];
                    results = PerformXMLXPathQuery(response, @"/tag/push_apply");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"PushApply"];
                    results = PerformXMLXPathQuery(response, @"/tag/push_reply");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"PushReply"];
                    results = PerformXMLXPathQuery(response, @"/tag/push_comment");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"PushComment"];
                    results = PerformXMLXPathQuery(response, @"/tag/push_begin");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"PushBegin"];
                    results = PerformXMLXPathQuery(response, @"/tag/push_life");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"PushLiFE"];
                    results = PerformXMLXPathQuery(response, @"/tag/mail_apply");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"MailApply"];
                    results = PerformXMLXPathQuery(response, @"/tag/mail_reply");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"MailReply"];
                    results = PerformXMLXPathQuery(response, @"/tag/mail_comment");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"MailComment"];
                    results = PerformXMLXPathQuery(response, @"/tag/mail_begin");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"MailBegin"];
                    results = PerformXMLXPathQuery(response, @"/tag/mail_life");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"MailLiFE"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_sleep_time");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"GoalSleepTime"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_steps");
                    [ud setInteger:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] forKey:@"GoalSteps"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_distance");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"GoalDistance"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_calory");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"GoalCalory"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_running");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"GoalRunning"];
                    results = PerformXMLXPathQuery(response, @"/tag/goal_weight");
                    [ud setFloat:[[[results objectAtIndex:0] objectForKey:@"nodeContent"] floatValue] forKey:@"GoalWeight"];
                    
                    //ユーザーイメージの保存
                    results = PerformXMLXPathQuery(response, @"/tag/user_image");
                    NSString *imageName = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirPath = [paths objectAtIndex:0];
                    if(imageName != nil) {
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URL_PROFILE_IMAGE_PATH, imageName]];
                        NSData *dataProfileImage = [NSData dataWithContentsOfURL:url];
                        [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
                    } else {
                        //デフォルトのプロフィール画像を保存しておく
                        UIImage *profileImage = [UIImage imageNamed:@"LiFE_ProfileImage.png"];
                        NSData *dataProfileImage = UIImagePNGRepresentation(profileImage);
                        [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
                    }
                    [ud setObject:@"profile.png" forKey:@"UserImage"];
                    
                    //保存されていたデータを端末のデータベースにコピーする
                    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
                    [dbHelper initialize];
                    
                    NSArray *stepValueResults = PerformXMLXPathQuery(response, @"/tag/step_value");
                    NSArray *stepDateResults = PerformXMLXPathQuery(response, @"/tag/step_date");
                    
                    NSDate *lastDate = nil;
                    
                    for(int i = 0; i < [stepValueResults count]; i++) {
                        NSString *stepValue = [[stepValueResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        NSString *stepDate = [[stepDateResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        stepDate = [stepDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                        [dbHelper insertStep:stepDate value:stepValue];
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
                        NSDate *FormatDate = [dateFormatter dateFromString:stepDate];
                        
                        if(lastDate == nil){
                            lastDate = FormatDate;
                        }
                        
                        NSComparisonResult result = [FormatDate compare:lastDate];
                        
                        if(result == NSOrderedDescending){
                            lastDate = FormatDate;
                        }
                    }
                    
                    [ud setObject:lastDate forKey:@"LastUpdateDate"];
                    
                    NSArray *sleepValueResults = PerformXMLXPathQuery(response, @"/tag/sleep_value");
                    NSArray *sleepDateResults = PerformXMLXPathQuery(response, @"/tag/sleep_date");
                    for(int i = 0; i < [sleepValueResults count]; i++) {
                        NSString *sleepValue = [[sleepValueResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        NSString *sleepDate = [[sleepDateResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        sleepDate = [sleepDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                        [dbHelper insertSleep:sleepDate value:sleepValue];
                    }
                    
                    NSArray *runValueResults = PerformXMLXPathQuery(response, @"/tag/run_value");
                    NSArray *runDateResults = PerformXMLXPathQuery(response, @"/tag/run_date");
                    for(int i = 0; i < [runValueResults count]; i++) {
                        NSString *runValue = [[runValueResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        NSString *runDate = [[runDateResults objectAtIndex:i] objectForKey:@"nodeContent"];
                        runDate = [runDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                        [dbHelper insertRun:runDate value:runValue];
                    }
                    
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ログイン成功" message: @"正常にログインしました。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    alertView.tag = ALERT_LOGIN;
                    [alertView show];
                    
                } else {
                    //ログイン失敗
                    NSString *faultReason = @"不明なエラーです。";
                    NSArray *faultResult = PerformXMLXPathQuery(response, @"/tag/fault_reason");
                    if ([faultResult count] != 0) {
                        faultReason = [[faultResult objectAtIndex:0] objectForKey:@"nodeContent"];
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ログイン失敗" message:faultReason delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
            }
            
            [ud synchronize];
            
            break;
        }
    }
}

//httpリクエスト失敗時の処理
- (void)requestFailed:(ASIHTTPRequest *)request {
    switch(request.tag) {
        case ACCESS_REGISTER:
        case ACCESS_LOGIN: {
            [SVProgressHUD dismiss];
            
            // 通信ができなかったときの処理
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ネットワークエラー" message: @"インターネットに接続できませんでした。ネットワーク状況を確認して再度お試しください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            break;
        }
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    switch (alertView.tag) {
        case ALERT_REGISTER: {
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
            [ud setObject:@"profile.png" forKey:@"UserImage"];
            [ud setFloat:170.0 forKey:@"UserHeight"];
            [ud setFloat:60.0 forKey:@"UserWeight"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *fromFormatDate = [dateFormatter dateFromString:@"1980-01-01"];
            [ud setObject:fromFormatDate forKey:@"UserBirthDay"];
            [ud setInteger:SHARE_PUBLIC forKey:@"ShareProfile"];
            [ud setInteger:SHARE_PUBLIC forKey:@"ShareActivity"];
            [ud setInteger:SWITCH_ON forKey:@"PushApply"];
            [ud setInteger:SWITCH_ON forKey:@"PushReply"];
            [ud setInteger:SWITCH_ON forKey:@"PushComment"];
            [ud setInteger:SWITCH_ON forKey:@"PushBegin"];
            [ud setInteger:SWITCH_ON forKey:@"PushLiFE"];
            [ud setInteger:SWITCH_ON forKey:@"MailApply"];
            [ud setInteger:SWITCH_ON forKey:@"MailReply"];
            [ud setInteger:SWITCH_ON forKey:@"MailComment"];
            [ud setInteger:SWITCH_ON forKey:@"MailBegin"];
            [ud setInteger:SWITCH_ON forKey:@"MailLiFE"];
            [ud setInteger:27000 forKey:@"GoalSleepTime"];//秒数
            [ud setInteger:10000 forKey:@"GoalSteps"];
            [ud setFloat:7.0 forKey:@"GoalDistance"];
            [ud setFloat:1500.0 forKey:@"GoalCalory"];
            [ud setFloat:60.0 forKey:@"GoalWeight"];
            
            int loginKind = [ud integerForKey:@"LoginKind"];
            if(loginKind != LOG_IN_FACEBOOK) {
                [ud setObject:@"" forKey:@"UserRealName"];
                [ud setInteger:GENDER_MALE forKey:@"UserGender"];
                //デフォルトのプロフィール画像を保存しておく
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirPath = [paths objectAtIndex:0];
                UIImage *profileImage = [UIImage imageNamed:@"LiFE_ProfileImage.png"];
                NSData *dataProfileImage = UIImagePNGRepresentation(profileImage);
                [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
                
            }
            
            [ud synchronize];
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            
            UploadHelper *uploadHelper = [[UploadHelper alloc] init];
            [uploadHelper dataUpload:^{
                [SVProgressHUD dismiss];
                
                //初回プロフィール編集画面へ
                UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"registerProfile"];
                self.slidingViewController.topViewController = newTopViewController;
            }];
            break;
        }
        case ALERT_LOGIN: {
            //日ログの画面へ遷移
            UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
            self.slidingViewController.topViewController = newTopViewController;
            break;
        }
    }
}

- (IBAction)facebookButtonAction:(id)sender {
    //初期位置に戻す
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    //キーボードを隠す
    [self.view endEditing:YES];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey : @"708240455935864", ACFacebookPermissionsKey : @[@"basic_info", @"email"]};
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
                    
                    NSLog(@"%@", userData);
                    
                    if (userData != nil && deserializationError == nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(flag == START_REGISTER){
                                SLRequest *facebookRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://graph.facebook.com/me"] parameters:@{@"locale" : @"ja_JP", @"fields" : @"id,name,picture.width(512).height(512)"}];
                                [facebookRequest setAccount:facebookAccount];
                                [facebookRequest performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                                    
                                    NSError* err = nil;
                                    NSMutableDictionary *rootDocument = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&err];
                                    
                                    NSDictionary *userPicture = [rootDocument objectForKey:@"picture"];
                                    NSDictionary *userPictureData = [userPicture objectForKey:@"data"];
                                    
                                    NSLog(@"pic:%@", userPicture);
                                    NSLog(@"picData:%@", userPictureData);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //facebookで登録する
                                        NSURL *url = [NSURL URLWithString:URL_REGISTER];
                                        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                                        
                                        [request setTimeOutSeconds:60];
                                        [request setDelegate:self];
                                        [request setPostValue:[userData objectForKey:@"first_name"] forKey:@"UserName"];
                                        [request setPostValue:[userData objectForKey:@"email"] forKey:@"MailAddress"];
                                        [request setPostValue:PASSWORD_FOR_FACEBOOK forKey:@"Password"];
                                        [request setPostValue:[NSNumber numberWithInt:LOG_IN_FACEBOOK] forKey:@"LoginKind"];
                                        [request setPostValue:[userData objectForKey:@"id"] forKey:@"FacebookID"];
                                        [request setTag:ACCESS_REGISTER];
                                        [request startAsynchronous];
                                        
                                        //facebookで設定できるものを先に登録しておく
                                        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
                                        //facebookID
                                        [ud setObject:[userData objectForKey:@"id"] forKey:@"UserFacebookID"];
                                        
                                        //性別
                                        NSString *gender = [userData objectForKey:@"gender"];
                                        if([gender isEqual:@"male"]) {
                                            [ud setInteger:GENDER_MALE forKey:@"UserGender"];
                                        } else if([gender isEqual:@"female"]) {
                                            [ud setInteger:GENDER_FEMALE forKey:@"UserGender"];
                                        }
                                        //本名
                                        [ud setObject:[userData objectForKey:@"name"] forKey:@"UserRealName"];
                                        //プロフィール画像
                                        NSData *userImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userPictureData objectForKey:@"url"] ]];
                                        
                                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                        NSString *documentsDirPath = [paths objectAtIndex:0];
                                        if(userImageData != nil) {
                                            [userImageData writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
                                        } else {
                                            //デフォルトのプロフィール画像を保存しておく
                                            UIImage *profileImage = [UIImage imageNamed:@"LiFE_ProfileImage.png"];
                                            NSData *dataProfileImage = UIImagePNGRepresentation(profileImage);
                                            [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
                                        }
                                        [ud setObject:@"profile.png" forKey:@"UserImage"];
                                        [ud synchronize];
                                        
                                        NSLog(@"%@", [ud description]);
                                    });
                                }];
                                
                            } else if(flag == START_LOGIN){
                                //facebookでログイン
                                NSURL *url = [NSURL URLWithString:URL_LOGIN];
                                ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
                                
                                [request setTimeOutSeconds:60];
                                [request setDelegate:self];
                                [request setPostValue:[userData objectForKey:@"email"] forKey:@"MailAddress"];
                                [request setPostValue:PASSWORD_FOR_FACEBOOK forKey:@"Password"];
                                [request setPostValue:[NSNumber numberWithInt:LOG_IN_FACEBOOK] forKey:@"LoginKind"];
                                [request setTag:ACCESS_LOGIN];
                                [request startAsynchronous];
                            }
                            
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
}
@end
