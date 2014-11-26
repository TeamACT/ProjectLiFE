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
    
    baseColor = TIMELINE_COLOR_ORANGE;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setColor:(int)color{
    baseColor = color;
    
    UIColor *textColor;
    
    switch(color) {
        case TIMELINE_COLOR_ORANGE:{
            self.backgroundImageView.image = [UIImage imageNamed:@"LiFE_TimeLine_CellBackgroundOrange.png"];
            textColor = [UIColor colorWithRed:[[RGB_ORANGE_LIGHT objectAtIndex:0] floatValue] green:[[RGB_ORANGE_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_ORANGE_LIGHT objectAtIndex:2] floatValue] alpha:1.0f];
            break;
        }
        case TIMELINE_COLOR_GREEN:{
            self.backgroundImageView.image = [UIImage imageNamed:@"LiFE_TimeLine_CellBackgroundGreen.png"];
            textColor = [UIColor colorWithRed:[[RGB_GREEN_LIGHT objectAtIndex:0] floatValue] green:[[RGB_GREEN_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_GREEN_LIGHT objectAtIndex:2] floatValue] alpha:1.0f];
            break;
        }
        case TIMELINE_COLOR_RED:{
            self.backgroundImageView.image = [UIImage imageNamed:@"LiFE_TimeLine_CellBackgroundRed.png"];
            textColor = [UIColor colorWithRed:[[RGB_RED_LIGHT objectAtIndex:0] floatValue] green:[[RGB_RED_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_RED_LIGHT objectAtIndex:2] floatValue] alpha:1.0f];
            break;
        }
        case TIMELINE_COLOR_BLUE:{
            self.backgroundImageView.image = [UIImage imageNamed:@"LiFE_TimeLine_CellBackgroundBlue.png"];
            textColor = [UIColor colorWithRed:[[RGB_BLUE_LIGHT objectAtIndex:0] floatValue] green:[[RGB_BLUE_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_BLUE_LIGHT objectAtIndex:2] floatValue] alpha:1.0f];
            break;
        }
    }
    self.titleLabel.textColor = textColor;
    self.valueLabel.textColor = textColor;
    self.percentageLabel.textColor = textColor;
    self.percentLabel.textColor = textColor;
}

-(void)setCellItems:(NSString *)title value:(NSString *)value sub:(NSString *)sub percent:(int)percent{
    
    self.titleLabel.text = title;
    self.valueLabel.text = value;
    self.percentageLabel.text = [NSString stringWithFormat:@"%d", percent];
    
    //円グラフの値を設定して描画
    int lessColorValue = 0;
    int goalColorValue = 0;
    int muchColorValue = 0;
    
    //達成度によって表示色を変える
    if(percent < 100) {
        lessColorValue = 100 - percent;
        goalColorValue = percent;
        muchColorValue = 0;
    } else if(100 <= percent && percent < 200) {
        lessColorValue = 0;
        goalColorValue = 200 - percent;
        muchColorValue = percent - 100;
    } else if(200 <= percent) {
        lessColorValue = 0;
        goalColorValue = 0;
        muchColorValue = 100;
    }
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
    
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostingView.bounds];
    hostingView.hostedGraph = graph;
    graph.axisSet = nil;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.pieRadius = 35;
    pieChart.pieInnerRadius = 27;
    pieChart.dataSource = self;
    pieChart.delegate = self;
    [graph addPlot:pieChart];
    
    pieChartData = [NSMutableArray arrayWithObjects:
                    [NSNumber numberWithInt:muchColorValue],
                    [NSNumber numberWithInt:goalColorValue],
                    [NSNumber numberWithInt:lessColorValue],
                             nil];//表示する順番は濃い方から
    
    for(UIView *subview in [self.graphHostingView subviews]){
        [subview removeFromSuperview];
    }
    [self.graphHostingView addSubview:hostingView];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    CPTFill *sectorColor = [[CPTFill alloc] init];
    
    //表示色をベースカラーと達成度によってわける
    switch(idx) {
        case 0:{
            CPTColor *areaColorDark;
            switch(baseColor){
                case TIMELINE_COLOR_ORANGE:
                    areaColorDark = [CPTColor colorWithComponentRed:[[RGB_ORANGE_DARK objectAtIndex:0] floatValue] green:[[RGB_ORANGE_DARK objectAtIndex:1] floatValue] blue:[[RGB_ORANGE_DARK objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_GREEN:
                    areaColorDark = [CPTColor colorWithComponentRed:[[RGB_GREEN_DARK objectAtIndex:0] floatValue] green:[[RGB_GREEN_DARK objectAtIndex:1] floatValue] blue:[[RGB_GREEN_DARK objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_RED:
                    areaColorDark = [CPTColor colorWithComponentRed:[[RGB_RED_DARK objectAtIndex:0] floatValue] green:[[RGB_RED_DARK objectAtIndex:1] floatValue] blue:[[RGB_RED_DARK objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_BLUE:
                    areaColorDark = [CPTColor colorWithComponentRed:[[RGB_BLUE_DARK objectAtIndex:0] floatValue] green:[[RGB_BLUE_DARK objectAtIndex:1] floatValue] blue:[[RGB_BLUE_DARK objectAtIndex:2] floatValue] alpha:1.0];
                    break;
            }
            sectorColor = [CPTFill fillWithColor:areaColorDark];
            break;
        }
        case 1:{
            CPTColor *areaColorLight;
            switch(baseColor){
                case TIMELINE_COLOR_ORANGE:
                    areaColorLight = [CPTColor colorWithComponentRed:[[RGB_ORANGE_LIGHT objectAtIndex:0] floatValue] green:[[RGB_ORANGE_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_ORANGE_LIGHT objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_GREEN:
                    areaColorLight = [CPTColor colorWithComponentRed:[[RGB_GREEN_LIGHT objectAtIndex:0] floatValue] green:[[RGB_GREEN_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_GREEN_LIGHT objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_RED:
                    areaColorLight = [CPTColor colorWithComponentRed:[[RGB_RED_LIGHT objectAtIndex:0] floatValue] green:[[RGB_RED_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_RED_LIGHT objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_BLUE:
                    areaColorLight = [CPTColor colorWithComponentRed:[[RGB_BLUE_LIGHT objectAtIndex:0] floatValue] green:[[RGB_BLUE_LIGHT objectAtIndex:1] floatValue] blue:[[RGB_BLUE_LIGHT objectAtIndex:2] floatValue] alpha:1.0];
                    break;
            }
            sectorColor = [CPTFill fillWithColor:areaColorLight];
            break;
        }
        case 2:{
            CPTColor *areaColorWashy;
            switch(baseColor){
                case TIMELINE_COLOR_ORANGE:
                    areaColorWashy = [CPTColor colorWithComponentRed:[[RGB_ORANGE_WASHY objectAtIndex:0] floatValue] green:[[RGB_ORANGE_WASHY objectAtIndex:1] floatValue] blue:[[RGB_ORANGE_WASHY objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_GREEN:
                    areaColorWashy = [CPTColor colorWithComponentRed:[[RGB_GREEN_WASHY objectAtIndex:0] floatValue] green:[[RGB_GREEN_WASHY objectAtIndex:1] floatValue] blue:[[RGB_GREEN_WASHY objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_RED:
                    areaColorWashy = [CPTColor colorWithComponentRed:[[RGB_RED_WASHY objectAtIndex:0] floatValue] green:[[RGB_RED_WASHY objectAtIndex:1] floatValue] blue:[[RGB_RED_WASHY objectAtIndex:2] floatValue] alpha:1.0];
                    break;
                case TIMELINE_COLOR_BLUE:
                    areaColorWashy = [CPTColor colorWithComponentRed:[[RGB_BLUE_WASHY objectAtIndex:0] floatValue] green:[[RGB_BLUE_WASHY objectAtIndex:1] floatValue] blue:[[RGB_BLUE_WASHY objectAtIndex:2] floatValue] alpha:1.0];
                    break;
            }
            sectorColor = [CPTFill fillWithColor:areaColorWashy];
            break;
        }
    }
    
    return sectorColor;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    int records = [pieChartData count];
    return records;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return [pieChartData objectAtIndex:idx];
}


@end
