//
//  EditGoalTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/17.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "EditGoalTableViewController.h"

@interface EditGoalTableViewController ()

@end

@implementation EditGoalTableViewController

@synthesize editingGoal;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    timePicker = [[UIDatePicker alloc] init];
    timePicker.hidden = YES;
    [timePicker setDatePickerMode:UIDatePickerModeCountDownTimer];
    [timePicker addTarget:self action:@selector(timePickerDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timePicker];
    
    datePicker = [[UIDatePicker alloc] init];
    datePicker.hidden = YES;
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(datePickerDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    valuePicker = [[UIPickerView alloc]init];
    valuePicker.hidden = YES;
    valuePicker.delegate = self;
    valuePicker.dataSource = self;
    [self.view addSubview:valuePicker];
    
    [self.tableView setScrollEnabled:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //各ピッカーの位置を設定
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    timePicker.center = CGPointMake(screenRect.size.width / 2 , 100 + timePicker.frame.size.height / 2);
    datePicker.center = CGPointMake(screenRect.size.width / 2 , 100 + datePicker.frame.size.height / 2);
    valuePicker.center = CGPointMake(screenRect.size.width / 2 , 100 + valuePicker.frame.size.height / 2);
    
    //必要なピッカーを表示する
    switch(editingGoal) {
        case EDIT_GOAL_SLEEP:
            timePicker.hidden = NO;
            break;
        case EDIT_GOAL_STEP:
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
        case EDIT_GOAL_CALORY:
        case EDIT_GOAL_WEIGHT:
        case EDIT_PROF_HEIGHT:
        case EDIT_PROF_WEIGHT:
            valuePicker.hidden = NO;
            break;
        case EDIT_PROF_BIRTHDAY:
            datePicker.hidden = NO;
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellGoalEdit"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    //セルはハイライトしない
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch(editingGoal) {
        case EDIT_GOAL_SLEEP: {
            titleLabel.text = @"睡眠時間";
            int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
            int sleepHour = goalSleepTime / (60 * 60);
            int sleepMinute = (goalSleepTime - sleepHour * 60 * 60) / 60;
            valueLabel.text = [NSString stringWithFormat:@"%d時間%d分", sleepHour, sleepMinute];
            //ピッカーの初期値の設定
            [timePicker setCountDownDuration:goalSleepTime];
            break;
        }
        case EDIT_GOAL_STEP:{
            titleLabel.text = @"歩数";
            int goalSteps = [ud integerForKey:@"GoalSteps"];
            valueLabel.text = [NSString stringWithFormat:@"%d歩", goalSteps];
            //ピッカーの初期値の設定
            [valuePicker selectRow:(goalSteps / 500) - 1 inComponent:0 animated:NO];
            break;
        }
        case EDIT_GOAL_DIST:{
            titleLabel.text = @"歩行距離";
            float goalDistance = [ud floatForKey:@"GoalDistance"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkm", goalDistance];
            //ピッカーの初期値の設定
            NSString *distStr = [NSString stringWithFormat:@"%.1f", goalDistance];
            NSArray *distArray = [distStr componentsSeparatedByString:@"."];
            int distRow0 = [[distArray objectAtIndex:0] intValue];
            int distRow1 = [[distArray objectAtIndex:1] intValue];
            [valuePicker selectRow:distRow0 - 1 inComponent:0 animated:NO];
            [valuePicker selectRow:distRow1 inComponent:1 animated:NO];
            break;
        }
        case EDIT_GOAL_CALORY:{
            titleLabel.text = @"消費カロリー";
            float goalCalory = [ud floatForKey:@"GoalCalory"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkcal", goalCalory];
            //ピッカーの初期値の設定
            [valuePicker selectRow:(goalCalory / 100) - 1 inComponent:0 animated:NO];
            break;
        }
        case EDIT_GOAL_RUNNING:{
            titleLabel.text = @"歩行距離";
            float goalRunning = [ud floatForKey:@"GoalRunning"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkm", goalRunning];
            //ピッカーの初期値の設定
            NSString *runStr = [NSString stringWithFormat:@"%.1f", goalRunning];
            NSArray *runArray = [runStr componentsSeparatedByString:@"."];
            int runRow0 = [[runArray objectAtIndex:0] intValue];
            int runRow1 = [[runArray objectAtIndex:1] intValue];
            [valuePicker selectRow:runRow0 - 1 inComponent:0 animated:NO];
            [valuePicker selectRow:runRow1 inComponent:1 animated:NO];
            break;
        }
        case EDIT_GOAL_WEIGHT:{
            titleLabel.text = @"体重";
            float goalWeight = [ud floatForKey:@"GoalWeight"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkg", goalWeight];
            //ピッカーの初期値の設定
            NSString *weightStr = [NSString stringWithFormat:@"%.1f", goalWeight];
            NSArray *weightArray = [weightStr componentsSeparatedByString:@"."];
            int weightRow0 = [[weightArray objectAtIndex:0] intValue];
            int weightRow1 = [[weightArray objectAtIndex:1] intValue];
            [valuePicker selectRow:weightRow0 - 1 inComponent:0 animated:NO];
            [valuePicker selectRow:weightRow1 inComponent:1 animated:NO];
            break;
        }
        case EDIT_PROF_HEIGHT:{
            titleLabel.text = @"身長";
            float userHeight = [ud floatForKey:@"UserHeight"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fcm", userHeight];
            //ピッカーの初期値の設定
            NSString *heightStr = [NSString stringWithFormat:@"%.1f", userHeight];
            NSArray *heightArray = [heightStr componentsSeparatedByString:@"."];
            int heightRow0 = [[heightArray objectAtIndex:0] intValue];
            int heightRow1 = [[heightArray objectAtIndex:1] intValue];
            [valuePicker selectRow:heightRow0 - 1 inComponent:0 animated:NO];
            [valuePicker selectRow:heightRow1 inComponent:1 animated:NO];
            break;
        }
        case EDIT_PROF_WEIGHT:{
            titleLabel.text = @"体重";
            float userWeight = [ud floatForKey:@"UserWeight"];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkg", userWeight];
            //ピッカーの初期値の設定
            NSString *weightStr = [NSString stringWithFormat:@"%.1f", userWeight];
            NSArray *weightArray = [weightStr componentsSeparatedByString:@"."];
            int weightRow0 = [[weightArray objectAtIndex:0] intValue];
            int weightRow1 = [[weightArray objectAtIndex:1] intValue];
            [valuePicker selectRow:weightRow0 - 1 inComponent:0 animated:NO];
            [valuePicker selectRow:weightRow1 inComponent:1 animated:NO];
            break;
        }
        case EDIT_PROF_BIRTHDAY: {
            titleLabel.text = @"生年月日";
            NSDate *userBirthday = [ud objectForKey:@"UserBirthDay"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            valueLabel.text = [dateFormatter stringFromDate:userBirthday];
            //ピッカーの初期値の設定
            [datePicker setDate:userBirthday];
            break;
        }
    }
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellGoalEdit"];
    }
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * title = @"";
    switch(editingGoal) {
        case EDIT_GOAL_SLEEP:
        case EDIT_GOAL_STEP:
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
        case EDIT_GOAL_CALORY:
        case EDIT_GOAL_WEIGHT:
            title =  @"目標設定";
        default:
            title =  @"";
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)timePickerDidChange:(UIDatePicker*)picker{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud setInteger:picker.countDownDuration forKey:@"GoalSleepTime"];//秒数
    [ud synchronize];
    
    //再読み込み
    [self.tableView reloadData];
}

- (void)datePickerDidChange:(UIDatePicker*)picker{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud setObject:picker.date forKey:@"UserBirthDay"];
    [ud synchronize];
    
    //再読み込み
    [self.tableView reloadData];
}

/**
 * ピッカーに表示する列数を返す
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch(editingGoal) {
        default:
            return 0;
        case EDIT_GOAL_STEP:
        case EDIT_GOAL_CALORY:
            return 1;
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
        case EDIT_GOAL_WEIGHT:
        case EDIT_PROF_HEIGHT:
        case EDIT_PROF_WEIGHT:
            return 2;
    }
}

/**
 * ピッカーに表示する行数を返す
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    int row = 0;
    switch(editingGoal) {
        default:
            break;
        case EDIT_GOAL_STEP:
        case EDIT_GOAL_CALORY:
            row = 100;
            break;
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
            switch(component) {
                case 0:
                    row = 100;
                    break;
                case 1:
                    row = 10;
                    break;
            }
            break;
        case EDIT_GOAL_WEIGHT:
        case EDIT_PROF_WEIGHT:
            switch(component) {
                case 0:
                    row = 200;
                    break;
                case 1:
                    row = 10;
                    break;
            }
            break;
        case EDIT_PROF_HEIGHT:
            switch(component) {
                case 0:
                    row = 300;
                    break;
                case 1:
                    row = 10;
                    break;
            }
            break;
    }
    return row;
}

/**
 * 行のサイズを変更
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView
    widthForComponent:(NSInteger)component
{
    switch(editingGoal) {
        default:
            return 0;
        case EDIT_GOAL_STEP:
        case EDIT_GOAL_CALORY:
            return 100.0;
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
        case EDIT_GOAL_WEIGHT:
        case EDIT_PROF_HEIGHT:
        case EDIT_PROF_WEIGHT:
            switch (component) {
                case 0: // 1列目
                    return 52.0;
                case 1: // 2列目
                    return 32.0;
                default:
                    return 0;
            }
    }
}

/**
 * ピッカーに表示する値を返す
 */
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(editingGoal) {
        default:
            return 0;
        case EDIT_GOAL_STEP:
            return [NSString stringWithFormat:@"%d", (row + 1) * 500];
        case EDIT_GOAL_DIST:
        case EDIT_GOAL_RUNNING:
        case EDIT_GOAL_WEIGHT:
        case EDIT_PROF_HEIGHT:
        case EDIT_PROF_WEIGHT:
            switch (component) {
                case 0: // 1列目
                    return [NSString stringWithFormat:@"%d", row + 1];
                case 1: // 2列目
                    return [NSString stringWithFormat:@".%d", row];
                default:
                    return 0;
            }
        case EDIT_GOAL_CALORY:
            return [NSString stringWithFormat:@"%d", (row + 1) * 100];
    }
}

/**
 * ピッカーの選択行が決まったとき
 */
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    switch(editingGoal) {
        default:
            break;
        case EDIT_GOAL_STEP:{
            NSInteger step = ([pickerView selectedRowInComponent:0] + 1) * 500;
            [ud setInteger:step forKey:@"GoalSteps"];
            break;
        }
        case EDIT_GOAL_DIST:{
            NSString *dist = [NSString stringWithFormat:@"%d.%d", [pickerView selectedRowInComponent:0] + 1, [pickerView selectedRowInComponent:1]];
            [ud setFloat:[dist floatValue] forKey:@"GoalDistance"];
            break;
        }
        case EDIT_GOAL_CALORY:{
            NSInteger calory = ([pickerView selectedRowInComponent:0] + 1) * 100;
            [ud setFloat:calory forKey:@"GoalCalory"];
            break;
        }
        case EDIT_GOAL_RUNNING:{
            NSString *run = [NSString stringWithFormat:@"%d.%d", [pickerView selectedRowInComponent:0] + 1, [pickerView selectedRowInComponent:1]];
            [ud setFloat:[run floatValue] forKey:@"GoalRunning"];
            break;
        }
        case EDIT_GOAL_WEIGHT:{
            NSString *weight = [NSString stringWithFormat:@"%d.%d", [pickerView selectedRowInComponent:0] + 1, [pickerView selectedRowInComponent:1]];
            [ud setFloat:[weight floatValue] forKey:@"GoalWeight"];
            break;
        }
        case EDIT_PROF_HEIGHT:{
            NSString *height = [NSString stringWithFormat:@"%d.%d", [pickerView selectedRowInComponent:0] + 1, [pickerView selectedRowInComponent:1]];
            [ud setFloat:[height floatValue] forKey:@"UserHeight"];
            break;
        }
        case EDIT_PROF_WEIGHT:{
            NSString *weight = [NSString stringWithFormat:@"%d.%d", [pickerView selectedRowInComponent:0] + 1, [pickerView selectedRowInComponent:1]];
            [ud setFloat:[weight floatValue] forKey:@"UserWeight"];
            break;
        }
    }
    [ud synchronize];
    
    //再読み込み
    [self.tableView reloadData];
    
}


@end
