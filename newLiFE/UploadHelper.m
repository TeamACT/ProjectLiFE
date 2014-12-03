//
//  UploadHelper.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/22.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "UploadHelper.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "XPathQuery.h"
#import "DatabaseHelper.h"


@implementation UploadHelper

-(void)dataUpload:(void (^)())block{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    
    NSString *userID = [ud objectForKey:@"UserID"];
    NSString *userName = [ud objectForKey:@"UserName"];
    NSString *userRealName = [ud objectForKey:@"UserRealName"];
    float userHeight = [ud floatForKey:@"UserHeight"];
    float userWeight = [ud floatForKey:@"UserWeight"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *userBirthDayDate = [ud objectForKey:@"UserBirthDay"];
    NSString *userBirthDay = [dateFormatter stringFromDate:userBirthDayDate];
    int userGender = [ud integerForKey:@"UserGender"];
    int shareProfile = [ud integerForKey:@"ShareProfile"];
    int shareActivity = [ud integerForKey:@"ShareActivity"];
    int pushApply = [ud integerForKey:@"PushApply"];
    int pushReply = [ud integerForKey:@"PushReply"];
    int pushComment = [ud integerForKey:@"PushComment"];
    int pushBegin = [ud integerForKey:@"PushBegin"];
    int pushLiFE = [ud integerForKey:@"PushLiFE"];
    int mailApply = [ud integerForKey:@"MailApply"];
    int mailReply = [ud integerForKey:@"MailReply"];
    int mailComment = [ud integerForKey:@"MailComment"];
    int mailBegin = [ud integerForKey:@"MailBegin"];
    int mailLiFE = [ud integerForKey:@"MailLiFE"];
    int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
    int goalSteps = [ud integerForKey:@"GoalSteps"];
    float goalDistance = [ud floatForKey:@"GoalDistance"];
    float goalCalory = [ud floatForKey:@"GoalCalory"];
    float goalRunning = [ud floatForKey:@"GoalRunning"];
    float goalWeight = [ud floatForKey:@"GoalWeight"];
    
    //新規登録の後、初期値をサーバーに保存させる
    NSURL *url = [NSURL URLWithString:URL_UPDATE_USER_DATA];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:60];
    [request setPostValue:userID forKey:@"UserID"];
    [request setPostValue:userName forKey:@"UserName"];
    [request setPostValue:userRealName forKey:@"UserRealName"];
    [request setPostValue:[NSNumber numberWithFloat:userHeight] forKey:@"UserHeight"];
    [request setPostValue:[NSNumber numberWithFloat:userWeight] forKey:@"UserWeight"];
    [request setPostValue:userBirthDay forKey:@"UserBirthDay"];
    [request setPostValue:[NSNumber numberWithInt:userGender] forKey:@"UserGender"];
    [request setPostValue:[NSNumber numberWithInt:shareProfile] forKey:@"ShareProfile"];
    [request setPostValue:[NSNumber numberWithInt:shareActivity] forKey:@"ShareActivity"];
    [request setPostValue:[NSNumber numberWithInt:pushApply] forKey:@"PushApply"];
    [request setPostValue:[NSNumber numberWithInt:pushReply] forKey:@"PushReply"];
    [request setPostValue:[NSNumber numberWithInt:pushComment] forKey:@"PushComment"];
    [request setPostValue:[NSNumber numberWithInt:pushBegin] forKey:@"PushBegin"];
    [request setPostValue:[NSNumber numberWithInt:pushLiFE] forKey:@"PushLiFE"];
    [request setPostValue:[NSNumber numberWithInt:mailApply] forKey:@"MailApply"];
    [request setPostValue:[NSNumber numberWithInt:mailReply] forKey:@"MailReply"];
    [request setPostValue:[NSNumber numberWithInt:mailComment] forKey:@"MailComment"];
    [request setPostValue:[NSNumber numberWithInt:mailBegin] forKey:@"MailBegin"];
    [request setPostValue:[NSNumber numberWithInt:mailLiFE] forKey:@"MailLiFE"];
    [request setPostValue:[NSNumber numberWithInt:goalSleepTime] forKey:@"GoalSleepTime"];
    [request setPostValue:[NSNumber numberWithInt:goalSteps] forKey:@"GoalSteps"];
    [request setPostValue:[NSNumber numberWithFloat:goalDistance] forKey:@"GoalDistance"];
    [request setPostValue:[NSNumber numberWithFloat:goalCalory] forKey:@"GoalCalory"];
    [request setPostValue:[NSNumber numberWithFloat:goalRunning] forKey:@"GoalRunning"];
    [request setPostValue:[NSNumber numberWithFloat:goalWeight] forKey:@"GoalWeight"];
    [request setCompletionBlock:^{
        block();
    }];
    [request setFailedBlock:^{
        
    }];
    [request startAsynchronous];
}

-(void)logUpload:(void (^)())block{
    //保存されている各ログの最後の日付を取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userID = [ud objectForKey:@"UserID"];
    
    NSURL *url = [NSURL URLWithString:URL_LAST_SAVED_DATE];
    __block ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:60];
    [request setPostValue:userID forKey:@"UserID"];
    [request setCompletionBlock:^{
        NSString *lastStepDate = nil, *lastSleepDate = nil, *lastRunDate = nil;
        
        //結果
        NSData *response = [request responseData];
        NSArray *results = PerformXMLXPathQuery(response, @"/tag/last_step_date");
        if([results count] > 0) {
            lastStepDate = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
            lastStepDate = [lastStepDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        results = PerformXMLXPathQuery(response, @"/tag/last_sleep_date");
        if([results count] > 0) {
            lastSleepDate = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
            lastSleepDate = [lastSleepDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        results = PerformXMLXPathQuery(response, @"/tag/last_run_date");
        if([results count] > 0) {
            lastRunDate = [[results objectAtIndex:0] objectForKey:@"nodeContent"];
            lastRunDate = [lastRunDate stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        
        //取得した最終日からの各ログを全て取得
        NSMutableArray *stepLogs = [NSMutableArray array];
        NSMutableArray *sleepLogs = [NSMutableArray array];
        NSMutableArray *runLogs = [NSMutableArray array];
        
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        
        if(lastStepDate != nil) {
            stepLogs = [dbHelper selectStepsFromDate:lastStepDate];
        } else {
            stepLogs = [dbHelper selectAllStep];//サーバー上にデータが一つも保存されていない場合
        }
        if(lastSleepDate != nil) {
            sleepLogs = [dbHelper selectSleepsFromDate:lastSleepDate];
        } else {
            sleepLogs = [dbHelper selectAllSleep];//サーバー上にデータが一つも保存されていない場合
        }
        if(lastRunDate != nil) {
            runLogs = [dbHelper selectRunsFromDate:lastRunDate];
        } else {
            runLogs = [dbHelper selectAllRun];//サーバー上にデータが一つも保存されていない場合
        }
        
        //取得したログデータを送信
        NSURL *url = [NSURL URLWithString:URL_UPLOAD_LOG];
        ASIFormDataRequest *requestPost = [[ASIFormDataRequest alloc] initWithURL:url];
        
        [requestPost setTimeOutSeconds:60];
        [requestPost setPostValue:userID forKey:@"UserID"];
        [requestPost setPostValue:[NSNumber numberWithInt:[stepLogs count]] forKey:@"StepLogCount"];
        [requestPost setPostValue:[NSNumber numberWithInt:[sleepLogs count]] forKey:@"SleepLogCount"];
        [requestPost setPostValue:[NSNumber numberWithInt:[runLogs count]] forKey:@"RunLogCount"];
        for(int i = 0; i < [stepLogs count]; i++) {
            NSMutableDictionary *stepLog = [stepLogs objectAtIndex:i];
            [requestPost setPostValue:[stepLog objectForKey:@"step_value"] forKey:[NSString stringWithFormat:@"StepLogValue%d", i]];
            NSString *logDate = [[stepLog objectForKey:@"step_date"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            [requestPost setPostValue:logDate forKey:[NSString stringWithFormat:@"StepLogDate%d", i]];
        }
        for(int i = 0; i < [sleepLogs count]; i++) {
            NSMutableDictionary *sleepLog = [sleepLogs objectAtIndex:i];
            [requestPost setPostValue:[sleepLog objectForKey:@"sleep_value"] forKey:[NSString stringWithFormat:@"SleepLogValue%d", i]];
            NSString *logDate = [[sleepLog objectForKey:@"sleep_date"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            [requestPost setPostValue:logDate forKey:[NSString stringWithFormat:@"SleepLogDate%d", i]];
        }
        for(int i = 0; i < [runLogs count]; i++) {
            NSMutableDictionary *runLog = [runLogs objectAtIndex:i];
            [requestPost setPostValue:[runLog objectForKey:@"run_value"] forKey:[NSString stringWithFormat:@"RunLogValue%d", i]];
            NSString *logDate = [[runLog objectForKey:@"run_date"] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            [requestPost setPostValue:logDate forKey:[NSString stringWithFormat:@"RunLogDate%d", i]];
        }
        [requestPost setCompletionBlock:^{
            block();
        }];
        [requestPost setFailedBlock:^{
            
        }];
        [requestPost startAsynchronous];
    }];
    [request setFailedBlock:^{
        
    }];
    [request startAsynchronous];

}

@end
