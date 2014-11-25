//
//  ResultGraphView.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/21.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "CorePlot-CocoaTouch.h"

@interface ResultGraphView : UIView <CPTPieChartDataSource,CPTPieChartDelegate>

@property(readwrite,nonatomic) NSMutableArray *pieChartData;
@property(readwrite,nonatomic) NSMutableArray *goalPieChartData;

@property(nonatomic) float value;

@end