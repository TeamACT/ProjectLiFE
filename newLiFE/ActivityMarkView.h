//
//  ActivityMarkView.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface ActivityMarkView : UIView

@property(nonatomic) NSDate *date;
@property(nonatomic) int deviceType;
@property(nonatomic) int dataValueType;
@property(nonatomic) NSMutableDictionary *steps;
@property(nonatomic) NSMutableDictionary *sleeps;
@property(nonatomic) NSMutableDictionary *runs;

@end
