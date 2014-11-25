//
//  GoalTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/11.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "GoalTableViewController.h"
#import "EditGoalTableViewController.h"
#import "MenuDrawerViewController.h"

#import "UploadHelper.h"

@interface GoalTableViewController ()

@end

@implementation GoalTableViewController

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
    
    //ナビゲーションバーの境界線を消す
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    self.slidingViewController.delegate = self;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    //データを更新する
    UploadHelper *uploadHelper = [[UploadHelper alloc] init];
    [uploadHelper dataUpload:^{}];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int row = 0;
    switch(section) {
        case 0:
            row = 5;
            break;
        case 1:
            row = 1;
            break;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //各セルのIDを設定
    NSString* cellIdentifier = @"";
    switch([indexPath section]) {
        case 0:
            switch([indexPath row]) {
                case 0:
                    cellIdentifier = @"CellGoalSleepTime";
                    break;
                case 1:
                    cellIdentifier = @"CellGoalSteps";
                    break;
                case 2:
                    cellIdentifier = @"CellGoalDistance";
                    break;
                case 3:
                    cellIdentifier = @"CellGoalCalory";
                    break;
                case 4:
                    cellIdentifier = @"CellGoalRunning";
                    break;
            }
            break;
        case 1:
            cellIdentifier = @"CellGoalWeight";
            break;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    switch([indexPath section]) {
        case 0:
            switch([indexPath row]) {
                case 0: {
                    int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
                    int sleepHour = goalSleepTime / (60 * 60);
                    int sleepMinute = (goalSleepTime - sleepHour * 60 * 60) / 60;
                    label.text = [NSString stringWithFormat:@"%d時間%d分", sleepHour, sleepMinute];
                    break;
                }
                case 1: {
                    int goalSteps = [ud integerForKey:@"GoalSteps"];
                    label.text = [NSString stringWithFormat:@"%d歩", goalSteps];
                    break;
                }
                case 2: {
                    float goalDistance = [ud floatForKey:@"GoalDistance"];
                    label.text = [NSString stringWithFormat:@"%.1fkm", goalDistance];
                    break;
                }
                case 3: {
                    float goalCalory = [ud floatForKey:@"GoalCalory"];
                    label.text = [NSString stringWithFormat:@"%.1fkcal", goalCalory];
                    break;
                }
                case 4: {
                    float goalRunning = [ud floatForKey:@"GoalRunning"];
                    label.text = [NSString stringWithFormat:@"%.1fkm", goalRunning];
                    break;
                }
            }
            break;
        case 1: {
            float goalWeight = [ud floatForKey:@"GoalWeight"];
            label.text = [NSString stringWithFormat:@"%.1fkg", goalWeight];
            break;
        }
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
    //各セクションのタイトルを設定
    NSString *title = @"";
    switch(section) {
        case 0:
            title = @"一日の目標";
            break;
        case 1:
            title = @"将来の目標";
            break;
    }
    return title;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditGoalTableViewController *editGoalViewController = [segue destinationViewController];
    
    if ( [[segue identifier] isEqualToString:@"EditGoalSleepSegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_SLEEP;
        editGoalViewController.navigationItem.title = @"睡眠時間";
    } else if ( [[segue identifier] isEqualToString:@"EditGoalStepSegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_STEP;
        editGoalViewController.navigationItem.title = @"歩数";
    } else if ( [[segue identifier] isEqualToString:@"EditGoalDistSegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_DIST;
        editGoalViewController.navigationItem.title = @"歩行距離";
    } else if ( [[segue identifier] isEqualToString:@"EditGoalRunningSegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_RUNNING;
        editGoalViewController.navigationItem.title = @"ランニング距離";
    } else if ( [[segue identifier] isEqualToString:@"EditGoalCalorySegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_CALORY;
        editGoalViewController.navigationItem.title = @"消費カロリー";
    } else if ( [[segue identifier] isEqualToString:@"EditGoalWeightSegue"] ) {
        editGoalViewController.editingGoal = EDIT_GOAL_WEIGHT;
        editGoalViewController.navigationItem.title = @"体重";
    }
}
@end
