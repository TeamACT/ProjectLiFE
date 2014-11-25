//
//  ShowImageViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowImageViewDelegate <NSObject>
- (void)closeShowImageView;
@end

@interface ShowImageViewController : UIViewController
@property (nonatomic, retain) id delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)backButtonAction:(id)sender;

@end
