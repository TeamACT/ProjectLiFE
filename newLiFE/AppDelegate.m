//
//  AppDelegate.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "AppDelegate.h"

#import "ECSlidingViewController.h"

#import "VitalConnect.h"
#import "SDK.h"

void uncaughtExceptionHandler(NSException *exception){
    NSLog(@"CRASH:%@",exception);
    NSLog(@"Stack Trac:%@",[exception callStackSymbols]);
}

@implementation AppDelegate

@synthesize vitalConnectManager;

#define ALERT_VIEW_TAG_RESTART_SERVICE 0x00101
#define ALERT_VIEW_TAG_SENSOR_UNBOUND_BACKEND_ERROR 0x00103

-(void) doRegisterRelay {
    
    VitalConnectBackendErrorCode errorCode = [[VitalConnectManager getSharedInstance] registerRelay:SDK_RELAY_ID passCode:SDK_RELAY_PASSWORD];
    switch (errorCode) {
        case kBackendError_Success:
        {
            NSLog(@"RelayID given to library");
            break;
        }
        default:
        {
            [self performSelector:@selector(doRegisterRelay) withObject:nil afterDelay:1.0];
            break;
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    sleep(2);
    
    // Override point for customization after application launch.
    //DB初期化
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    [dbHelper initializeWithVersion:15];
    
    //ユーザー情報の初期化
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSString *userImage = [ud objectForKey:@"UserImage"];
    if(!userImage || [userImage isEqual:@""]) {
        [ud setObject:@"profile.png" forKey:@"UserImage"];
        //デフォルトのプロフィール画像を保存しておく
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirPath = [paths objectAtIndex:0];
        UIImage *profileImage = [UIImage imageNamed:@"LiFE_ProfileImage.png"];
        NSData *dataProfileImage = UIImagePNGRepresentation(profileImage);
        [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:@"profile.png"] atomically:YES];
    }
    if(!userImage)  [ud setObject:@"" forKey:@"UserImage"];
    NSString *userName = [ud objectForKey:@"UserName"];
    if(!userName)  [ud setObject:@"" forKey:@"UserName"];
    NSString *userRealName = [ud objectForKey:@"UserRealName"];
    if(!userRealName)  [ud setObject:@"" forKey:@"UserRealName"];
    NSString *userMailAddress = [ud objectForKey:@"UserMailAddress"];
    if(!userMailAddress)  [ud setObject:@"" forKey:@"UserMailAddress"];
    int loginKind = [ud integerForKey:@"LoginKind"];
    if(!loginKind)  [ud setInteger:LOG_IN_NORMAL forKey:@"LoginKind"];
    float userHeight = [ud floatForKey:@"UserHeight"];
    if(!userHeight)  [ud setFloat:170.0 forKey:@"UserHeight"];
    float userWeight = [ud floatForKey:@"UserWeight"];
    if(!userWeight)  [ud setFloat:60.0 forKey:@"UserWeight"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *fromFormatDate = [dateFormatter dateFromString:@"1980/01/01"];
    NSDate *userBirthDay = [ud objectForKey:@"UserBirthDay"];
    if(!userBirthDay)  [ud setObject:fromFormatDate forKey:@"UserBirthDay"];
    int userGender = [ud integerForKey:@"UserGender"];
    if(!userGender)  [ud setInteger:GENDER_MALE forKey:@"UserGender"];
    NSString *userFBID = [ud objectForKey:@"UserFacebookID"];
    if(!userFBID)  [ud setObject:@"" forKey:@"UserFacebookID"];
    int shareProfile = [ud integerForKey:@"ShareProfile"];
    if(!shareProfile)  [ud setInteger:SHARE_PUBLIC forKey:@"ShareProfile"];
    int shareActivity = [ud integerForKey:@"ShareActivity"];
    if(!shareActivity)  [ud setInteger:SHARE_PUBLIC forKey:@"ShareActivity"];
    NSString *userPassword = [ud objectForKey:@"UserPassword"];
    if(!userPassword)  [ud setObject:@"" forKey:@"UserPassword"];
    int pushApply = [ud integerForKey:@"PushApply"];
    if(!pushApply)  [ud setInteger:SWITCH_ON forKey:@"PushApply"];
    int pushReply = [ud integerForKey:@"PushReply"];
    if(!pushReply)  [ud setInteger:SWITCH_ON forKey:@"PushReply"];
    int pushComment = [ud integerForKey:@"PushComment"];
    if(!pushComment)  [ud setInteger:SWITCH_ON forKey:@"PushComment"];
    int pushBegin = [ud integerForKey:@"PushBegin"];
    if(!pushBegin)  [ud setInteger:SWITCH_ON forKey:@"PushBegin"];
    int pushLiFE = [ud integerForKey:@"PushLiFE"];
    if(!pushLiFE)  [ud setInteger:SWITCH_ON forKey:@"PushLiFE"];
    int mailApply = [ud integerForKey:@"MailApply"];
    if(!mailApply)  [ud setInteger:SWITCH_ON forKey:@"MailApply"];
    int mailReply = [ud integerForKey:@"MailReply"];
    if(!mailReply)  [ud setInteger:SWITCH_ON forKey:@"MailReply"];
    int mailComment = [ud integerForKey:@"MailComment"];
    if(!mailComment)  [ud setInteger:SWITCH_ON forKey:@"MailComment"];
    int mailBegin = [ud integerForKey:@"MailBegin"];
    if(!mailBegin)  [ud setInteger:SWITCH_ON forKey:@"MailBegin"];
    int mailLiFE = [ud integerForKey:@"MailLiFE"];
    if(!mailLiFE)  [ud setInteger:SWITCH_ON forKey:@"MailLiFE"];
    int goalSleepTime = [ud integerForKey:@"GoalSleepTime"];
    if(!goalSleepTime)  [ud setInteger:27000 forKey:@"GoalSleepTime"];//秒数
    int goalSteps = [ud integerForKey:@"GoalSteps"];
    if(!goalSteps)  [ud setInteger:10000 forKey:@"GoalSteps"];
    float goalDistance = [ud floatForKey:@"GoalDistance"];
    if(!goalDistance)  [ud setFloat:7.0 forKey:@"GoalDistance"];
    float goalCalory = [ud floatForKey:@"GoalCalory"];
    if(!goalCalory)  [ud setFloat:1500.0 forKey:@"GoalCalory"];
    float goalRunning = [ud floatForKey:@"GoalRunning"];
    if(!goalRunning)  [ud setFloat:5.0 forKey:@"GoalRunning"];
    float goalWeight = [ud floatForKey:@"GoalWeight"];
    if(!goalWeight)  [ud setFloat:60.0 forKey:@"GoalWeight"];
    NSDate *FormatDate = [dateFormatter dateFromString:@"1980/01/01 00:00:00"];
    NSDate *date = [ud objectForKey:@"LastUpdateDate"];
    if(!date)  [ud setObject:fromFormatDate forKey:@"LastUpdateDate"];
    [ud synchronize];
    
    //ECSlidingViewControllerオブジェクトを取得
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
    
    //ストーリーボードを取得
    if(![ud stringForKey:@"UserID"] || [[ud stringForKey:@"UserID"] isEqualToString:@""]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"start"];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        slidingViewController.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"day"];
    }
    
    //フォントの一括設定
    /*
     NSDictionary *navigationBarAttr = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"SourceHanSansJP-Light" size:20.0f], NSFontAttributeName, nil];
     [[UINavigationBar appearance] setTitleTextAttributes:navigationBarAttr];
     [[UILabel appearance] setFont:[UIFont fontWithName:@"SourceHanSansJP-Light" size:16.0f]];
     */
    
    // copy the sensor init file to the documents directory.  The sensor init file is applied to the sensor at every connection.  You can use this file to set options like easy fall and simulate data.
    NSString *fromPath = [[NSBundle mainBundle] pathForResource:@"initdevice" ofType:@"vcmcfg"];
    if (fromPath != nil) {
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        if (docsDir != nil) {
            NSString *toPath = [NSString pathWithComponents:@[docsDir, @"initdevice.vcmcfg"]];
            [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:toPath error: nil];
        }
    }
    
    isModuleBindingLostAlertAlreadyDisplayed = NO;
    isSDSNotFoundByCDSAlertAlreadyDisplayed = NO;
    
    /*
     * initialize the library
     */
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootFileDir = [dirPaths objectAtIndex:0];
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    rootFileDir = [rootFileDir stringByAppendingPathComponent:[bundleInfo objectForKey:@"CFBundleDisplayName"]];
    
    self.vitalConnectManager = [VitalConnectManager createVitalConnect:SDK_API_KEY
                                                           environment:kVitalConnectServerDevelopment
                                                              services:kVitalConnectServerServiceFWUpdate|
                                kVitalConnectServerServiceDemographics|
                                kVitalConnectServerServiceDataUplaod|
                                kVitalConnectServerServiceLogs|
                                kVitalConnectServerServiceWatches
                                                           rootFileDir:rootFileDir
                                                             encrypted:NO];
    
    
    [self.vitalConnectManager start];
    [self.vitalConnectManager addBackendListener:self];

    /*
     * register the relay, if it hasn't been registered already.  This will fail if service discovery is in process, so do it in the background (and allow for retry).
     */
    if([self.vitalConnectManager isVCICloudEnabled])
    {
        
        NSString * relayGUID = [self.vitalConnectManager getRelayIdentifier];
        if ((relayGUID == nil || relayGUID.length == 0) && [self.vitalConnectManager isVCICloudEnabled]){
            NSLog(@"Registering relay...");
            [self performSelector:@selector(doRegisterRelay) withObject:nil afterDelay:1.0];
        } else {
            NSLog(@"Using relay id: %@", relayGUID);
            
        }
    }
    
    /* Generate SDSGuid on the fist time launch of the app and save it in the user defaults for later use. This GUID will no longer be added in the SDK.H file for easing out security.
     */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [prefs objectForKey:@"SDK_SENSOR_DATA_SOURCE_GUID"];
    if(uuid == nil) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSLog(@"Generated SDSGuid: %@", uuid);
        [prefs setObject:uuid forKey:@"SDK_SENSOR_DATA_SOURCE_GUID"];
    }
    
    if([self.vitalConnectManager isVCICloudEnabled]) {
        [self.vitalConnectManager setRegisteredRelayGuid:uuid];
        
        if([self.vitalConnectManager isServiceSupported:kVitalConnectServerServiceDataUplaod])
            [self.vitalConnectManager enablePostDataToServer:YES];
        else
            [self.vitalConnectManager enablePostDataToServer:NO];
        
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Background Fetch Mode
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
- (void)application:(UIApplication*) application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Allow the VCI library to (1) reconnect to modules in the background if auto-connect is enabled and (2) fetch demographics and other
    // updated data from the VCI cloud if the VCI cloud is enabled.
    // NOTE: The background fetch option must be enabled in the app's target.
    NSString *guid = [[NSUserDefaults standardUserDefaults] objectForKey:kSDKSensorDataSourceGuidKey];
    [[VitalConnectManager getSharedInstance] performBackgroundFetch:guid completionHandler:^(BOOL backgroundFetchSuccessful)
     {
         // Crazy but true.  The completionHandler callback must be on the main thread:
         // http://stackoverflow.com/questions/18974251/app-crashes-after-executing-background-fetch-completionhandler
         dispatch_async(dispatch_get_main_queue(), ^{
             if (backgroundFetchSuccessful) {
                 completionHandler(UIBackgroundFetchResultNewData);
             }else{
                 completionHandler(UIBackgroundFetchResultNoData);
             }
         });
     }];
}
#endif

#pragma mark - Backend Error Methods
- (void) handleBackendModuleUnboundErrorMainThread
{
    
    /* Ignoring "Module binding lost" error as the new dynamic GUID generation causes this
     * to happen. Autobind without any alerts
     */
    
    NSLog(@"Module binding lost.");
    VitalConnectManager* vcm = [VitalConnectManager getSharedInstance];
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_SENSOR_DATA_SOURCE_GUID"];
    if([vcm getActiveSensor])
        [vcm bindSensor:[vcm getActiveSensor] withGUID:uuid];
    [self.vitalConnectManager setRegisteredRelayGuid:uuid];
    
}

- (void) handleBackendSDSNotFoundByCDSErrorMainThread
{
    /* Ignoring "Source guid not found by CDS" error as the new dynamic GUID generation causes this
     * to happen when the app is uninstalled and reinstalled or when the watches are downloaded before a bind
     */
    
    NSLog(@"Error: SDS not found by CDS.  Ignoring the error");
    VitalConnectManager* vcm = [VitalConnectManager getSharedInstance];
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDK_SENSOR_DATA_SOURCE_GUID"];
    if([vcm getActiveSensor])
        [vcm bindSensor:[vcm getActiveSensor] withGUID:uuid];
    [self.vitalConnectManager setRegisteredRelayGuid:uuid];
    
    
    
}

/*
 * callback for errors talking to the server
 */
-(void) onBackendError:(VitalConnectBackendErrorCode)error  inComponent:(NSString*)componentName
{
    BOOL shouldRestart = NO;
    NSString *message = @"";
    switch (error) {
        case kBackendError_AuthenticationError:
            if ([componentName hasPrefix:@"relay"]) {
                message = @"Relay Authentication failed";
                shouldRestart = YES;
            } else {
                message = NSLocalizedString(@"MODULE_AUTH_FAILED", nil);
            }
            break;
        case kBackendError_DiscoveryError:
            message = @"Discovery failed";
            shouldRestart = YES;
            break;
        case kBackendError_AuthorizationError:
            message = @"Authorization failed";
            shouldRestart = YES;
            break;
            break;
        case kBackendError_GeneralError:
            message = @"Something else failed";
            break;
        case kBackendError_CreateRelayError:
            message = @"Relay create Failed";
            break;
        case kBackendError_NetworkNotReachable:
            message = @"Please check your network settings";
            break;
        case kBackendError_NetworkNotReachablePairingError:
            message = @"Module pairing failed.  Please check your network settings";
            break;
        case kBackendError_NetworkNotReachableBindingError:
            message = @"Module binding failed.  Please check your network settings";
            break;
        case kBackendError_SensorUnbound:
            [self performSelectorOnMainThread:@selector(handleBackendModuleUnboundErrorMainThread) withObject:nil waitUntilDone: NO];
            return;
        case kBackendError_SDSNotRecognizedByCDS:
            [self performSelectorOnMainThread:@selector(handleBackendSDSNotFoundByCDSErrorMainThread) withObject:nil waitUntilDone: NO];
            return;
        case kBackendError_BindError:
        case kBackendError_Success:
            return;
    }
    UIAlertView *alert;
    if (shouldRestart)
    {
        alert = [[UIAlertView alloc]
                 initWithTitle: @"Notice"
                 message: message
                 delegate: self
                 cancelButtonTitle:@"No"
                 otherButtonTitles:@"Yes", nil];
        alert.tag = ALERT_VIEW_TAG_RESTART_SERVICE;
    } else {
        alert = [[UIAlertView alloc]
                 initWithTitle: @"Notice"
                 message: message
                 delegate: self
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
    }
    if (alert != nil)
        [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    VitalConnectManager* vcm = [VitalConnectManager getSharedInstance];
    
    if (alertView.tag == ALERT_VIEW_TAG_RESTART_SERVICE) {
        if (buttonIndex == 1) {
            [vcm restart];
        }
    }
}

@end
