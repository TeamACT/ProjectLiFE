//
//  MenuDrawerViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/01.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "MenuDrawerViewController.h"
#import "DayViewController.h"
#import "WeekViewController.h"
#import "MonthViewController.h"
#import "YearViewController.h"
#import "SettingTableViewController.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"

@interface MenuDrawerViewController ()

@end

@implementation MenuDrawerViewController

@synthesize deviceType;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //ユーザー名
    self.nameLabel.text = [ud stringForKey:@"UserName"];
    self.nameLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Medium" size:16.0f];
    //プロフィール画像
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    UIImage *profileImage = [[UIImage alloc] initWithContentsOfFile:[documentsDirPath stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]]];
    self.profileImageView.image = profileImage;
    self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //友達のリクエスト数を取得する
    NSString *userID = [ud objectForKey:@"UserID"];
    
    NSURL *url = [NSURL URLWithString:URL_GET_REQUEST_COUNT];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:userID forKey:@"UserID"];
    [request startAsynchronous];
    
    self.requestCountLabel.hidden = YES;
    
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData *response = [request responseData];
    NSArray *results = PerformXMLXPathQuery(response, @"/tag/request_count");
    int requestCount = [[[results objectAtIndex:0] objectForKey:@"nodeContent"] intValue] ;
    
    if(requestCount > 0) {
        self.requestCountLabel.hidden = NO;
        [[self.requestCountLabel layer] setCornerRadius:10.0];
        [[self.requestCountLabel layer] setMasksToBounds:YES];
        [self.requestCountLabel setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
        [self.requestCountLabel setTextColor:[UIColor whiteColor]];
        self.requestCountLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:16.0f];
        
        NSString *count = [NSString stringWithFormat:@"%d", requestCount];
        [self.requestCountLabel setText:count];
        CGSize size = [count sizeWithAttributes:@{NSFontAttributeName:self.requestCountLabel.font}];
        [self.requestCountLabel setFrame:CGRectMake(0, 0, (size.width + 6.0 < 20.0 ? 20.0 : size.width+ 6.0), 20.0)];
        self.requestCountLabel.center = CGPointMake(250 - self.requestCountLabel.frame.size.width / 2, 252);
    }
}

//httpリクエスト失敗時の処理
- (void)requestFailed:(ASIHTTPRequest *)request {
    //失敗していても特に何もしない
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)transferDayVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferSettingVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferGoalVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"goal"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferTimelineVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"timeline"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferChallengeVC:(id)sender {
}

- (IBAction)transferFriendVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"friend"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferInformationVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"info"];
    self.slidingViewController.topViewController = newTopViewController;
}

- (IBAction)transferDeviceVC:(id)sender {
    [self.slidingViewController resetTopViewAnimated:NO];
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"device"];
    self.slidingViewController.topViewController = newTopViewController;
}

@end
