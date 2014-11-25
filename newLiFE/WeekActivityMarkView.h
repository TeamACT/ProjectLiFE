//
//  WeekActivityMarkView.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/08/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DatabaseHelper.h"

@interface WeekActivityMarkView : UIView
{
    int coorX;
    int coorY;
    
    int tCal;
    float tDistance;
    
    int sumSteps;
    int sumCalory;
    float sumDistance;
}

@property NSDate *date;

@property(nonatomic) int dataValueType;

@end
