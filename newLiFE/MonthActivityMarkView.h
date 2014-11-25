//
//  MonthActivityMarkView.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/16.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonthActivityMarkView : UIView
{
    NSArray *runArray;
}

@property(nonatomic) NSDate *date;

@property(nonatomic) int dataValueType;

@end
