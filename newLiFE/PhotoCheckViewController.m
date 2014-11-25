//
//  PhotoCheckViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "PhotoCheckViewController.h"

@interface PhotoCheckViewController ()

@end

@implementation PhotoCheckViewController

@synthesize image;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.photoImageView.image = image;
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

- (IBAction)backAction:(UIButton *)sender {
    DayViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
    self.slidingViewController.topViewController = newTopViewController;
}
@end
