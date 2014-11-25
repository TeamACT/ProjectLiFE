//
//  EditGoalTableViewController.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditGoalTableViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    UIDatePicker *timePicker;
    UIDatePicker *datePicker;
    UIPickerView *valuePicker;
}
@property(nonatomic) int editingGoal;

@end
