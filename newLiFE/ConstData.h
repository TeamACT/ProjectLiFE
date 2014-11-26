
#ifndef LiFE_ConstData_h
#define LiFE_ConstData_h

//font
//SourceHanSansJP-Light
//SourceHanSansJP-Medium

//アクセスURL
/*
 #define URL_REGISTER @"http://gcounter.net/LiFE/FirstRegister.php"
 #define URL_LOGIN @"http://gcounter.net/LiFE/LogIn.php"
 #define URL_UPDATE_USER_DATA @"http://gcounter.net/LiFE/UpdateUserData.php"
 #define URL_LAST_SAVED_DATE @"http://gcounter.net/LiFE/LastSavedDate.php"
 #define URL_UPLOAD_LOG @"http://gcounter.net/LiFE/UploadLog.php"
 #define URL_DOWNLOAD_LOG @"http://gcounter.net/LiFE/DwonloadLog.php"
 #define URL_UPLOAD_IMAGE @"http://gcounter.net/LiFE/UploadImage.php"
 #define URL_GET_FRIEND_LIST @"http://gcounter.net/LiFE/GetFriendList.php"
 #define URL_GET_REQUEST_COUNT @"http://gcounter.net/LiFE/GetFriendRequestCount.php"
 #define URL_PROFILE_IMAGE_PATH @"http://gcounter.net/LiFE/ProfileImages/"
 #define URL_UPDATE_PASSWORD @"http://gcounter.net/LiFE/UpdatePassword.php"
 #define URL_UPDATE_PASSWORD @"http://gcounter.net/LiFE/UpdatePassword.php"
 #define URL_SEARCH_FRIEND @"http://gcounter.net/LiFE/SearchFriend.php"
 #define URL_APPLY_FRIEND @"http://gcounter.net/LiFE/ApplyFriend.php"
 #define URL_APPROVE_FRIEND @"http://gcounter.net/LiFE/ApproveFriend.php"
 #define URL_DENY_FRIEND @"http://gcounter.net/LiFE/DenyFriend.php"
 #define URL_SEARCH_FRIEND_FROM_ADDRESS_BOOK @"http://gcounter.net/LiFE/SearchFriendFromAddressBook.php"
 #define URL_SEARCH_FRIEND_FROM_FACEBOOK @"http://gcounter.net/LiFE/SearchFriendFromFacebook.php"
 */

/*テスト用*/
#define URL_REGISTER @"http://gcounter.net/LiFE_Test/FirstRegister.php"
#define URL_LOGIN @"http://gcounter.net/LiFE_Test/LogIn.php"
#define URL_UPDATE_USER_DATA @"http://gcounter.net/LiFE_Test/UpdateUserData.php"
#define URL_LAST_SAVED_DATE @"http://gcounter.net/LiFE_Test/LastSavedDate.php"
#define URL_UPLOAD_LOG @"http://gcounter.net/LiFE_Test/UploadLog.php"
#define URL_DOWNLOAD_LOG @"http://gcounter.net/LiFE_Test/DwonloadLog.php"
#define URL_UPLOAD_IMAGE @"http://gcounter.net/LiFE_Test/UploadImage.php"
#define URL_GET_FRIEND_LIST @"http://gcounter.net/LiFE_Test/GetFriendList.php"
#define URL_GET_REQUEST_COUNT @"http://gcounter.net/LiFE_Test/GetFriendRequestCount.php"
#define URL_PROFILE_IMAGE_PATH @"http://gcounter.net/LiFE_Test/ProfileImages/"
#define URL_UPDATE_PASSWORD @"http://gcounter.net/LiFE_Test/UpdatePassword.php"
#define URL_SEARCH_FRIEND @"http://gcounter.net/LiFE_Test/SearchFriend.php"
#define URL_APPLY_FRIEND @"http://gcounter.net/LiFE_Test/ApplyFriend.php"
#define URL_APPROVE_FRIEND @"http://gcounter.net/LiFE_Test/ApproveFriend.php"
#define URL_DENY_FRIEND @"http://gcounter.net/LiFE_Test/DenyFriend.php"
#define URL_SEARCH_FRIEND_FROM_ADDRESS_BOOK @"http://gcounter.net/LiFE_Test/SearchFriendFromAddressBook.php"
#define URL_SEARCH_FRIEND_FROM_FACEBOOK @"http://gcounter.net/LiFE_Test/SearchFriendFromFacebook.php"

//開始時のログイン、新規登録分岐
#define START_REGISTER 0
#define START_LOGIN 1

//ログイン種類
#define LOG_IN_NORMAL 1
#define LOG_IN_FACEBOOK 2
#define LOG_IN_TWITTER 3

//仮パスワード
#define PASSWORD_FOR_FACEBOOK @"1234fb"
#define PASSWORD_FOR_TWITTER @"1234tw"

//公開範囲
#define SHARE_PUBLIC 0
#define SHARE_FRIEND 1
#define SHARE_SELF 2

//性別
#define GENDER_MALE 1
#define GENDER_FEMALE 2

//ON/OFF
#define SWITCH_OFF 1
#define SWITCH_ON 2

//編集中の通知
#define EDIT_NOTICE_PUSH 0
#define EDIT_NOTICE_MAIL 1

//編集中のデータ
#define EDIT_GOAL_SLEEP 0
#define EDIT_GOAL_STEP 1
#define EDIT_GOAL_DIST 2
#define EDIT_GOAL_CALORY 3
#define EDIT_GOAL_RUNNING 4
#define EDIT_GOAL_WEIGHT 5
#define EDIT_PROF_HEIGHT 6
#define EDIT_PROF_WEIGHT 7
#define EDIT_PROF_BIRTHDAY 8

//接続デバイス
#define DEVICE_TYPE_IOS 0
#define DEVICE_TYPE_VC 1

//デバイスの保持データ
#define DATA_TYPES_IN_IOS [NSArray arrayWithObjects:@"0",@"1",@"2",@"4",nil];

//データ状態
#define DATA_STATE_TYPE_STEP 0
#define DATA_STATE_TYPE_RUN 1
#define DATA_STATE_TYPE_SLEEP 2

//データ種類
#define DATA_VALUE_TYPE_STEP 0
#define DATA_VALUE_TYPE_CALORY 1
#define DATA_VALUE_TYPE_DIST 2
#define DATA_VALUE_TYPE_SLEEP 3
#define DATA_VALUE_TYPE_RUN 4

//曜日
#define SUNDAY 0
#define MONDAY 1
#define TUESDAY 2
#define WEDNESDAY 3
#define THURSDAY 4
#define FRIDAY 5
#define SATURDAY 6

//時計スタート・ストップ
#define TIMER_START 0
#define TIMER_STOP 1

//描画フラグ
#define DRAW_STEP 0
#define DRAW_OTHER 1

//描画用RGB値
//WEAKの色はアルファ値も設定して使用する
#define RGB_ORANGE_WEAK [NSArray arrayWithObjects: @"1.0", @"0.921", @"0.803", nil]
#define RGB_ORANGE_WASHY [NSArray arrayWithObjects: @"0.973", @"0.792", @"0.498", nil]
#define RGB_ORANGE_LIGHT [NSArray arrayWithObjects: @"0.949", @"0.588", @"0.0", nil]
#define RGB_ORANGE_DARK [NSArray arrayWithObjects: @"0.580", @"0.404", @"0.051", nil]
#define RGB_GREEN_WEAK [NSArray arrayWithObjects: @"0.776", @"0.976", @"0.866", nil]
#define RGB_GREEN_WASHY [NSArray arrayWithObjects: @"0.58", @"0.835", @"0.718", nil]
#define RGB_GREEN_LIGHT [NSArray arrayWithObjects: @"0.165", @"0.675", @"0.435", nil]
#define RGB_GREEN_DARK [NSArray arrayWithObjects: @"0.122", @"0.490", @"0.318", nil]
#define RGB_RED_WEAK [NSArray arrayWithObjects: @"1.0", @"0.858", @"0.858", nil]
#define RGB_RED_WASHY [NSArray arrayWithObjects: @"1.0", @"0.663", @"0.663", nil]
#define RGB_RED_LIGHT [NSArray arrayWithObjects: @"1.0", @"0.161", @"0.161", nil]
#define RGB_RED_DARK [NSArray arrayWithObjects: @"0.561", @"0.180", @"0.149", nil]
#define RGB_PURPLE_LIGHT [NSArray arrayWithObjects: @"1.0", @"0.392", @"1.0", nil]
#define RGB_PURPLE_DARK [NSArray arrayWithObjects: @"0.639", @"0.25", @"0.639", nil]
#define RGB_AQUA_LIGHT [NSArray arrayWithObjects: @"0.172", @"0.882", @"0.882", nil]
#define RGB_AQUA_DARK [NSArray arrayWithObjects: @"0.109", @"0.549", @"0.619", nil]
#define RGB_BLUE_WASHY [NSArray arrayWithObjects: @"0.498", @"0.718", @"0.933", nil]
#define RGB_BLUE_LIGHT [NSArray arrayWithObjects: @"0.0", @"0.435", @"0.866", nil]
#define RGB_BLUE_DARK [NSArray arrayWithObjects: @"0.0", @"0.29", @"0.568", nil]
#define RGB_GRAY [NSArray arrayWithObjects: @"0.607", @"0.607", @"0.607", nil]

//友達検索フラグ
#define SEARCH_FRIEND_ADDRESS_BOOK 0
#define SEARCH_FRIEND_FACEBOOK 1

//座標
#define DATE_LABEL [NSArray arrayWithObjects: @"0", @"28", @"320", @"25", nil]
#define DATA_VALUE_LABEL_X 85
#define DATA_VALUE_LABEL_Y 310
#define DATA_TYPE_LABEL_X 85
#define DATA_TYPE_LABEL_Y 326
#define DATA_RESULT_LABEL_X 65
#define DATA_RESULT_LABEL_Y 497
#define DATA_RESULT_PER_LABEL_X 142
#define DATA_RESULT_PER_LABEL_Y 425
#define DATA_RESULT_PER_MARK_LABEL_X 150
#define DATA_RESULT_PER_MARK_LABEL_Y 465
#define DATA_RESULT_MESSAGE_LABEL_X 65
#define DATA_RESULT_MESSAGE_LABEL_Y 475

//曜日用座標
#define WEEKDAY_BACKGROUND_WIDTH 90
#define WEEKDAY_BACKGROUND_HEIGHT 90
#define WEEKDAY_SUNDAY_BACKGROUND [NSArray arrayWithObjects: @"163", @"90", nil]
#define WEEKDAY_MONDAY_BACKGROUND [NSArray arrayWithObjects: @"223", @"164", nil]
#define WEEKDAY_TUESDAY_BACKGROUND [NSArray arrayWithObjects: @"202", @"258", nil]
#define WEEKDAY_WEDNESDAY_BACKGROUND [NSArray arrayWithObjects: @"115", @"298", nil]
#define WEEKDAY_THURSDAY_BACKGROUND [NSArray arrayWithObjects: @"30", @"258", nil]
#define WEEKDAY_FRIDAY_BACKGROUND [NSArray arrayWithObjects: @"9", @"164", nil]
#define WEEKDAY_SATURDAY_BACKGROUND [NSArray arrayWithObjects: @"67", @"90", nil]

//タイムライン用の色
#define TIMELINE_COLOR_ORANGE 0
#define TIMELINE_COLOR_GREEN 1
#define TIMELINE_COLOR_RED 2
#define TIMELINE_COLOR_BLUE 3

//タイムラインの種類
#define TIMELINE_TYPE_STEP 0
#define TIMELINE_TYPE_DIST 1
#define TIMELINE_TYPE_CALORY 2
#define TIMELINE_TYPE_RUN 3
#define TIMELINE_TYPE_SLEEP 4

#endif
