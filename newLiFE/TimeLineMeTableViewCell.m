//
//  TimeLineMeTableViewCell.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/11/20.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "TimeLineMeTableViewCell.h"

@implementation TimeLineMeTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setColor:(int)color{
    baseColor = color;
}

-(void)setCellItems:(NSString *)title value:(NSString *)value sub:(NSString *)sub percent:(int)percent{
    self.titleLabel.text = title;
    self.valueLabel.text = value;
    
    //円グラフの値を設定して描画
    //
}

@end
