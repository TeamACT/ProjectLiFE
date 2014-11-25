//
//  TimeLineMeTableViewCell.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/11/20.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineMeTableViewCell : UITableViewCell {
    int baseColor;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

-(void)setColor:(int)color;
-(void)setCellItems:(NSString *)title value:(NSString *)value sub:(NSString *)sub percent:(int)percent;

@end
