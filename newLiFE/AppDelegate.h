//
//  AppDelegate.h
//  newLiFE
//
//  Created by Answerer-ryo on 2014/07/09.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DatabaseHelper.h"

#import "VitalConnect.h"
#import "SDK.h"

#define kSDKSensorDataSourceGuidKey @"SDK_SENSOR_DATA_SOURCE_GUID"

@interface AppDelegate : UIResponder <UIApplicationDelegate,VitalConnectBackendListener>
{
    BOOL isModuleBindingLostAlertAlreadyDisplayed;
    BOOL isSDSNotFoundByCDSAlertAlreadyDisplayed;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) VitalConnectManager *vitalConnectManager;

@end
