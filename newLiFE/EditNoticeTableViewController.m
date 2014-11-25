//
//  EditNoticeTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/18.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "EditNoticeTableViewController.h"

@interface EditNoticeTableViewController ()

@end

@implementation EditNoticeTableViewController

@synthesize editingNotice;

#define SWITCH_APPLY 0
#define SWITCH_REPLY 1
#define SWITCH_COMMENT 2
#define SWITCH_BEGIN 3
#define SWITCH_LIFE 4

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellEditNotice"];
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UISwitch *noticeSwitch = (UISwitch *)[cell viewWithTag:2];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    int switchOnOff;
    switch([indexPath row]) {
        case 0:
            titleLabel.text = @"友達申請";
            if(editingNotice == EDIT_NOTICE_PUSH) {
                switchOnOff = [ud integerForKey:@"PushApply"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                switchOnOff = [ud integerForKey:@"MailApply"];
            }
            noticeSwitch.tag = SWITCH_APPLY;
            break;
        case 1:
            titleLabel.text = @"自分のコメントへの返信";
            if(editingNotice == EDIT_NOTICE_PUSH) {
                switchOnOff = [ud integerForKey:@"PushReply"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                switchOnOff = [ud integerForKey:@"MailReply"];
            }
            noticeSwitch.tag = SWITCH_REPLY;
            break;
        case 2:
            titleLabel.text = @"友達の新しいコメント";
            if(editingNotice == EDIT_NOTICE_PUSH) {
                switchOnOff = [ud integerForKey:@"PushComment"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                switchOnOff = [ud integerForKey:@"MailComment"];
            }
            noticeSwitch.tag = SWITCH_COMMENT;
            break;
        case 3:
            titleLabel.text = @"知り合いがLiFEをはじめた時";
            if(editingNotice == EDIT_NOTICE_PUSH) {
                switchOnOff = [ud integerForKey:@"PushBegin"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                switchOnOff = [ud integerForKey:@"MailBegin"];
            }
            noticeSwitch.tag = SWITCH_BEGIN;
            break;
        case 4:
            titleLabel.text = @"LiFEからのお知らせ";
            if(editingNotice == EDIT_NOTICE_PUSH) {
                switchOnOff = [ud integerForKey:@"PushLiFE"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                switchOnOff = [ud integerForKey:@"MailLiFE"];
            }
            noticeSwitch.tag = SWITCH_LIFE;
            break;
    }
    
    if(switchOnOff == SWITCH_ON) {
        [noticeSwitch setOn:YES];
    } else {
        [noticeSwitch setOn:NO];
    }
    [noticeSwitch addTarget:self action:@selector(changeSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    //セルはハイライトしない
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellEditNotice"];
    }
    
    // Configure the cell...
    
    return cell;
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

-(void)changeSwitchState:(UISwitch*)sender{
    int switchState;
    if(sender.on) {
        switchState = SWITCH_ON;
    } else {
        switchState = SWITCH_OFF;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    switch([sender tag]) {
        case SWITCH_APPLY:
            if(editingNotice == EDIT_NOTICE_PUSH) {
                [ud setInteger:switchState forKey:@"PushApply"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                [ud setInteger:switchState forKey:@"MailApply"];
            }
            break;
        case SWITCH_REPLY:
            if(editingNotice == EDIT_NOTICE_PUSH) {
                [ud setInteger:switchState forKey:@"PushReply"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                [ud setInteger:switchState forKey:@"MailReply"];
            }
            break;
        case SWITCH_COMMENT:
            if(editingNotice == EDIT_NOTICE_PUSH) {
                [ud setInteger:switchState forKey:@"PushComment"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                [ud setInteger:switchState forKey:@"MailComment"];
            }
            break;
        case SWITCH_BEGIN:
            if(editingNotice == EDIT_NOTICE_PUSH) {
                [ud setInteger:switchState forKey:@"PushBegin"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                [ud setInteger:switchState forKey:@"MailBegin"];
            }
            break;
        case SWITCH_LIFE:
            if(editingNotice == EDIT_NOTICE_PUSH) {
                [ud setInteger:switchState forKey:@"PushLiFE"];
            } else if (editingNotice == EDIT_NOTICE_MAIL){
                [ud setInteger:switchState forKey:@"MailLiFE"];
            }
            break;
    }
    [ud synchronize];
}

@end
