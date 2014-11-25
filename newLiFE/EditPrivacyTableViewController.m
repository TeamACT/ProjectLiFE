//
//  EditPrivacyTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "EditPrivacyTableViewController.h"

@interface EditPrivacyTableViewController ()

@end

@implementation EditPrivacyTableViewController

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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellEditPrivacy"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int share = -1;
    switch ([indexPath section]) {
        case 0:
            share = [ud integerForKey:@"ShareProfile"];
            break;
        case 1:
            share = [ud integerForKey:@"ShareActivity"];
            break;
    }
    
    switch ([indexPath row]) {
        case 0:
            titleLabel.text = @"公開";
            break;
        case 1:
            titleLabel.text = @"友達";
            break;
        case 2:
            titleLabel.text = @"自分のみ";
            break;
        default:
            break;
    }
    
    //一度全てのセルでチェックマークを外す
    cell.accessoryType = UITableViewCellAccessoryNone;
    //選択されている範囲をチェックマークにする
    if(share == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellEditPrivacy"];
    }
    
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"";
    switch(section) {
        case 0:
            title = @"プロフィールの公開範囲";
            break;
        case 1:
            title = @"アクティビティの公開範囲";
            break;
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //選択された範囲を保存する
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    switch ([indexPath section]) {
        case 0:
            [ud setInteger:[indexPath row] forKey:@"ShareProfile"];
            break;
        case 1:
            [ud setInteger:[indexPath row] forKey:@"ShareActivity"];
            break;
    }
    [ud synchronize];
    
    //テーブルビューをリロード
    [self.tableView reloadData];
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

@end
