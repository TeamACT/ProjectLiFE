//
//  NowActivityMarkView.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/10/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface NowActivityMarkView : UIView

@property(nonatomic) NSDate *date;
@property(nonatomic) int deviceType;
@property(nonatomic) int dataValueType;
@property(nonatomic) NSMutableDictionary *steps;
@property(nonatomic) NSMutableDictionary *sleeps;
@property(nonatomic) NSMutableDictionary *runs;

@end
