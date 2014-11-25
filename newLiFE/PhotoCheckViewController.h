//
//  PhotoCheckViewController.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DayViewController.h"

@interface PhotoCheckViewController : UIViewController

@property UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (IBAction)backAction:(UIButton *)sender;
@end
