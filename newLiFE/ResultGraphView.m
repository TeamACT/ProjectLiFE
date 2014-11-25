//
//  ResultGraphView.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/21.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "ResultGraphView.h"

@implementation ResultGraphView
@synthesize pieChartData;
@synthesize goalPieChartData;

@synthesize value;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    /***** 日にち曜日フォーマット *****/
    /*
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    monthFormatter.dateFormat = @"MM";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd";
    
    NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
    weekdayFormatter.dateFormat = @"EE";
    
    NSDateFormatter *dataBaseFormatter = [[NSDateFormatter alloc] init];
    dataBaseFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSString *formattedDataBaseString = [dataBaseFormatter stringFromDate:date];
    NSString *formattedTodayString = [dataBaseFormatter stringFromDate:[NSDate date]];
    */
    /***** 日にち曜日フォーマットここまで *****/
    
    /***** 時計グラフ表示用処理 *****/
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *todayComponents = [calendar components:flags fromDate:[NSDate date]];
    int hour = [todayComponents hour];
    int min = [todayComponents minute];
    
    float timeGraphValue = (hour * 6 * 0.6944) + ((min * 0.6944) / 10);
    */
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(-40,260,400,400)];
    
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostingView.bounds];
    hostingView.hostedGraph = graph;
    
    graph.axisSet = nil;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    
    pieChart.pieRadius = 35;
    
    pieChart.pieInnerRadius = 28;
    
    pieChart.dataSource = self;
    
    pieChart.delegate = self;
    
    [graph addPlot:pieChart];
    
    self.pieChartData = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithDouble:value],
                         [NSNumber numberWithDouble:100-value],
                         nil];
    
    /*
    if([formattedDataBaseString isEqualToString:formattedTodayString]){
        self.pieChartData = [NSMutableArray arrayWithObjects:
                             [NSNumber numberWithDouble:value],
                             [NSNumber numberWithDouble:100-value],
                             nil];
    }else{
        NSComparisonResult comparisonResult = [date compare:[NSDate date]];
        switch (comparisonResult) {
            case NSOrderedAscending:
                self.pieChartData = [NSMutableArray arrayWithObjects:
                                     [NSNumber numberWithDouble:100],
                                     [NSNumber numberWithDouble:0],
                                     nil];
                break;
                
            case NSOrderedDescending:
                self.pieChartData = [NSMutableArray arrayWithObjects:
                                     [NSNumber numberWithDouble:0],
                                     [NSNumber numberWithDouble:0],
                                     nil];
                break;
        }
    }
    */
    
    for(UIView *subview in [self subviews]){
        [subview removeFromSuperview];
    }
    
    [self addSubview:hostingView];
    /***** 時計グラフ表示用処理ここまで *****/
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    CPTFill *sectorColor = [[CPTFill alloc] init];
    
    if(idx == 0){
        CPTColor *areaColor1 = [CPTColor colorWithComponentRed:1.00 green:1.00 blue:1.00 alpha:1.0];
        sectorColor = [CPTFill fillWithColor:areaColor1];
    }else{
        CPTColor *areaColor2 = [CPTColor colorWithComponentRed:0.84 green:0.84 blue:0.84 alpha:0.5];
        sectorColor = [CPTFill fillWithColor:areaColor2];
    }
    return sectorColor;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    int count;
    
    count = [self.pieChartData count];
    
    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    return [self.pieChartData objectAtIndex:idx];
}

@end
