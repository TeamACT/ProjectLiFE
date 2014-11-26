//
//  TimeLineMeTableViewCell.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/11/20.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"

@interface TimeLineMeTableViewCell : UITableViewCell<CPTPieChartDataSource,CPTPieChartDelegate> {
    int baseColor;
    
    NSMutableArray *pieChartData;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UIView *graphHostingView;

-(void)setColor:(int)color;
-(void)setCellItems:(NSString *)title value:(NSString *)value sub:(NSString *)sub percent:(int)percent;

@end
