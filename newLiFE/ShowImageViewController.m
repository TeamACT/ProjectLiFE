//
//  ShowImageViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "ShowImageViewController.h"

@interface ShowImageViewController ()

@end

@implementation ShowImageViewController
@synthesize delegate;
@synthesize imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //プロフィール画像を表示
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    UIImage *profileImage = [[UIImage alloc] initWithContentsOfFile:[documentsDirPath stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]]];
    imageView.image = profileImage;    
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

- (IBAction)backButtonAction:(id)sender {
    [delegate closeShowImageView];
}
@end
