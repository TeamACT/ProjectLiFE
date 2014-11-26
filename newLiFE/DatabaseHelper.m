//
//  DatabaseHelper.m
//  LiFE
//
//  Created by Answerer-ryo on 2014/05/27.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "DatabaseHelper.h"

@implementation DatabaseHelper

NSString *DATABASE_FILE_NAME = @"LiFE.sqlite";

//各種CREATE文
NSString *CREATE_STEP_TABLE =
@"CREATE TABLE if not exists STEP ("
@"step_id INTEGER PRIMARY KEY NOT NULL,"
@"step_date TEXT,"
@"step_value TEXT)";

NSString *CREATE_SLEEP_TABLE =
@"CREATE TABLE if not exists SLEEP ("
@"sleep_id INTEGER PRIMARY KEY NOT NULL,"
@"sleep_date TEXT,"
@"sleep_value TEXT)";

NSString *CREATE_SLEEP_DETAIL_TABLE =
@"CREATE TABLE if not exists SLEEP_DETAIL ("
@"sleep_detail_id INTEGER PRIMARY KEY NOT NULL,"
@"start_datetime DATETIME,"
@"end_datetime DATETIME,"
@"search_start_datetime DATETIME,"
@"search_end_datetime DATETIME)";

NSString *CREATE_RUN_TABLE =
@"CREATE TABLE if not exists RUN ("
@"run_id INTEGER PRIMARY KEY NOT NULL,"
@"run_date TEXT,"
@"run_value TEXT)";

NSString *CREATE_RUN_DETAIL_TABLE =
@"CREATE TABLE if not exists RUN_DETAIL ("
@"run_detail_id INTEGER PRIMARY KEY NOT NULL,"
@"start_datetime DATETIME,"
@"end_datetime DATETIME,"
@"run_step INTEGER,"
@"search_start_datetime DATETIME,"
@"search_end_datetime DATETIME)";

NSString *CREATE_PHOTO_TABLE =
@"CREATE TABLE if not exists PHOTO ("
@"photo_id INTEGER PRIMARY KEY NOT NULL,"
@"photo_date TEXT,"
@"photo_path TEXT,"
@"photo_index TEXT)";

NSString *CREATE_TIMELINE_TABLE =
@"CREATE TABLE if not exists TIMELINE ("
@"timeline_id INTEGER PRIMARY KEY NOT NULL,"
@"timeline_date TEXT,"
@"timeline_value TEXT,"
@"timeline_attainment INTEGER,"
@"timeline_type INTEGER)";

//各種INSERT文
NSString *INSERT_STEP =
@"INSERT INTO STEP(step_date, step_value) values (?,?)";

NSString *INSERT_SLEEP =
@"INSERT INTO SLEEP(sleep_date, sleep_value) values (?,?)";

NSString *INSERT_SLEEP_DETAIL =
@"INSERT INTO SLEEP_DETAIL(start_datetime, end_datetime, search_start_datetime, search_end_datetime) values (?,?,?,?)";

NSString *INSERT_RUN =
@"INSERT INTO RUN(run_date, run_value) values (?,?)";

NSString *INSERT_RUN_DETAIL =
@"INSERT INTO RUN_DETAIL(start_datetime, end_datetime, run_step, search_start_datetime, search_end_datetime) values (?,?,?,?,?)";

NSString *INSERT_PHOTO =
@"INSERT INTO PHOTO(photo_date, photo_path, photo_index) values (?,?,?)";

NSString *INSERT_TIMELINE =
@"INSERT INTO TIMELINE(timeline_date, timeline_value, timeline_attainment, timeline_type) values (?,?,?,?)";

//各種UPDATE文
NSString *UPDATE_DATA_VITALCONNECT =
@"UPDATE DATA SET data_value_01=? WHERE data_type_id=? and data_date=?";

NSString *UPDATE_STEP =
@"UPDATE STEP SET step_value = ? WHERE step_date = ?";

NSString *UPDATE_SLEEP =
@"UPDATE SLEEP SET sleep_value = ? WHERE sleep_date = ?";

NSString *UPDATE_SLEEP_DETAIL =
@"UPDATE SLEEP_DETAIL SET end_datetime = ?, search_end_datetime = ? WHERE start_datetime = ?" ;

NSString *UPDATE_RUN =
@"UPDATE RUN SET run_value = ? WHERE run_date = ?";

NSString *UPDATE_RUN_DETAIL =
@"UPDATE RUN_DETAIL SET end_datetime = ?, run_step = ?, search_end_datetime = ? WHERE start_datetime = ?" ;

//各種SELECT文
NSString *SELECT_DAY_STEP =
@"SELECT * FROM STEP WHERE step_date=?";

NSString *SELECT_DAY_SLEEP =
@"SELECT * FROM SLEEP WHERE sleep_date=?";

NSString *SELECT_DAY_SLEEP_DETAIL =
@"SELECT * FROM SLEEP_DETAIL WHERE search_start_datetime <= ? AND search_end_datetime >= ?";

NSString *SELECT_DAY_RUN =
@"SELECT * FROM RUN WHERE run_date=?";

NSString *SELECT_DAY_RUN_DETAIL =
@"SELECT * FROM RUN_DETAIL WHERE search_start_datetime <= ? AND search_end_datetime >= ?";

NSString *SELECT_DAY_PHOTO =
@"SELECT * FROM PHOTO WHERE photo_date=?";

NSString *SELECT_TERM_STEP =
@"SELECT * FROM STEP WHERE step_date like ? ORDER BY step_date";

NSString *SELECT_TERM_SLEEP =
@"SELECT * FROM SLEEP WHERE sleep_date like ? ORDER BY sleep_date";

NSString *SELECT_TERM_RUN =
@"SELECT * FROM RUN WHERE run_date like ? ORDER BY run_date";

NSString *SELECT_ALL_STEP =
@"SELECT * FROM STEP";

NSString *SELECT_ALL_SLEEP =
@"SELECT * FROM SLEEP";

NSString *SELECT_ALL_RUN =
@"SELECT * FROM RUN";

NSString *SELECT_STEP_FROM_DATE =
@"SELECT * FROM STEP WHERE step_date >= ? ORDER BY step_date";

NSString *SELECT_SLEEP_FROM_DATE =
@"SELECT * FROM SLEEP WHERE sleep_date >= ? ORDER BY sleep_date";

NSString *SELECT_RUN_FROM_DATE =
@"SELECT * FROM RUN WHERE run_date >= ? ORDER BY run_date";

NSString *SELECT_TIMELINE_DATE =
@"SELECT DISTINCT(timeline_date) FROM TIMELINE ORDER BY timeline_date desc LIMIT ? OFFSET ?";

NSString *SELECT_TIMELINE_FROM_DATE =
@"SELECT * FROM TIMELINE WHERE timeline_date = ?";


-(void)initialize{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:DATABASE_FILE_NAME];
    
    //ファイルが既存なら参照、なければ新規作成
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    
    [db open];
    
    [db executeUpdate:@"DROP TABLE if exists STEP"];
    [db executeUpdate:@"DROP TABLE if exists SLEEP"];
    [db executeUpdate:@"DROP TABLE if exists SLEEP_DETAIL"];
    [db executeUpdate:@"DROP TABLE if exists RUN"];
    [db executeUpdate:@"DROP TABLE if exists RUN_DETAIL"];
    [db executeUpdate:@"DROP TABLE if exists PHOTO"];
    [db executeUpdate:@"DROP TABLE if exists TIMELINE"];
    
    //テーブルの作成
    [db executeUpdate:CREATE_STEP_TABLE];
    [db executeUpdate:CREATE_SLEEP_TABLE];
    [db executeUpdate:CREATE_SLEEP_DETAIL_TABLE];
    [db executeUpdate:CREATE_RUN_TABLE];
    [db executeUpdate:CREATE_RUN_DETAIL_TABLE];
    [db executeUpdate:CREATE_PHOTO_TABLE];
    [db executeUpdate:CREATE_TIMELINE_TABLE];
    
    //タイムライン用テストデータ作成
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/10", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/10", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/10", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/10", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/10", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/11", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/11", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/11", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/11", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/11", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/12", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/12", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/12", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/12", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/12", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/13", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/13", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/13", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/13", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/13", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/14", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/14", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/14", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/14", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/14", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/15", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/15", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/15", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/15", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/15", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/16", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/16", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/16", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/16", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/16", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/17", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/17", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/17", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/17", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/17", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/18", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/18", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/18", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/18", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/18", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/19", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/19", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/19", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/19", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/19", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/20", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/20", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/20", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/20", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/20", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/21", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/21", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/21", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/21", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/21", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/22", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/22", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/22", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/22", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/22", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/23", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/23", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/23", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/23", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/23", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/24", @"10,901", [NSNumber numberWithInt:109], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/24", @"5.4km", [NSNumber numberWithInt:88], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/24", @"2,804", [NSNumber numberWithInt:189], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/24", @"3.25km", [NSNumber numberWithInt:106], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/24", @"7:12", [NSNumber numberWithInt:96], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/25", @"10,234", [NSNumber numberWithInt:102], [NSNumber numberWithInt:TIMELINE_TYPE_STEP]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/25", @"5.1km", [NSNumber numberWithInt:83], [NSNumber numberWithInt:TIMELINE_TYPE_DIST]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/25", @"1,234", [NSNumber numberWithInt:79], [NSNumber numberWithInt:TIMELINE_TYPE_CALORY]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/25", @"2.75km", [NSNumber numberWithInt:92], [NSNumber numberWithInt:TIMELINE_TYPE_RUN]];
    [db executeUpdate:INSERT_TIMELINE, @"2014/11/25", @"7:50", [NSNumber numberWithInt:107], [NSNumber numberWithInt:TIMELINE_TYPE_SLEEP]];

    [db close];
}

-(void)initializeWithVersion:(int)version
{
    //データベースのバージョンを保持しておいて、引数によって更新をかける
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int dbVersion = [ud integerForKey:@"DatabaseVersion"];
    if(!dbVersion) {
        dbVersion = 1;
        [ud setInteger:dbVersion forKey:@"DatabaseVersion"];
    }
    //引数のバージョンが保存されているもの以下の場合、データベースの更新を行わない
    if(version <= dbVersion) {
        return;
    }
    //更新する場合、引数のバージョンを保存
    [ud setInteger:version forKey:@"DatabaseVersion"];
    
    [self initialize];
}

-(void)upgrade
{
    
}

-(FMDatabase *)openDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:DATABASE_FILE_NAME];
    
    //ファイルが既存なら参照、なければ新規作成
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    
    [db open];
    
    return db;
}

-(void)closeDB:(FMDatabase *) db
{
    [db close];
}

-(NSMutableArray *)convertToArray:(FMResultSet *) result
{
    NSMutableArray *array = [NSMutableArray array];
    
    while([result next]) {
        NSMutableDictionary *dict = [result resultDictionary];
        [array addObject:dict];
    }
    
    return array;
}

/***** insert *****/

-(void)insertStep:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    NSString *stepDate = date;
    NSString *stepValue = value;
    
    [db executeUpdate:INSERT_STEP, stepDate, stepValue];
    
    [self closeDB:db];
}

-(void)insertSleep:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    NSString *sleepDate = date;
    NSString *sleepValue = value;
    
    [db executeUpdate:INSERT_SLEEP, sleepDate, sleepValue, @""];
    
    [self closeDB:db];
}

-(void)insertSleepDetail:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime
{
    FMDatabase* db = [self openDB];
    
    //検索用の就寝、起床時間を作成
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:startDateTime];
    
    int startIndexByTenMins = startDateComps.hour * 6 + startDateComps.minute / 10;
    NSDateComponents* searchStartDateComps = [NSDateComponents new];
    [searchStartDateComps setYear:startDateComps.year];
    [searchStartDateComps setMonth:startDateComps.month];
    [searchStartDateComps setDay:startDateComps.day];
    [searchStartDateComps setMinute:10 * startIndexByTenMins];
    
    NSDate* searchStartDate = [calendar dateFromComponents:searchStartDateComps];
    
    NSDateComponents *endDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:endDateTime];
    
    int endIndexByTenMins = endDateComps.hour * 6 + endDateComps.minute / 10;
    NSDateComponents* searchEndDateComps = [NSDateComponents new];
    [searchEndDateComps setYear:endDateComps.year];
    [searchEndDateComps setMonth:endDateComps.month];
    [searchEndDateComps setDay:endDateComps.day];
    [searchEndDateComps setMinute:10 * endIndexByTenMins];
    
    NSDate* searchEndDate = [calendar dateFromComponents:searchEndDateComps];

    [db executeUpdate:INSERT_SLEEP_DETAIL, startDateTime, endDateTime, searchStartDate, searchEndDate];
    
    [self closeDB:db];
}

-(void)insertRun:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    NSString *runDate = date;
    NSString *runValue = value;
    
    [db executeUpdate:INSERT_RUN, runDate, runValue];
    
    [self closeDB:db];
}


-(void)insertRunDetail:(int)runStep startDateTime:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime{
    
    FMDatabase* db = [self openDB];
    
    //検索用の就寝、起床時間を作成
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *startDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:startDateTime];
    
    int startIndexByTenMins = startDateComps.hour * 6 + startDateComps.minute / 10;
    NSDateComponents* searchStartDateComps = [NSDateComponents new];
    [searchStartDateComps setYear:startDateComps.year];
    [searchStartDateComps setMonth:startDateComps.month];
    [searchStartDateComps setDay:startDateComps.day];
    [searchStartDateComps setMinute:10 * startIndexByTenMins];
    
    NSDate* searchStartDate = [calendar dateFromComponents:searchStartDateComps];
    
    NSDateComponents *endDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:endDateTime];
    
    int endIndexByTenMins = endDateComps.hour * 6 + endDateComps.minute / 10;
    NSDateComponents* searchEndDateComps = [NSDateComponents new];
    [searchEndDateComps setYear:endDateComps.year];
    [searchEndDateComps setMonth:endDateComps.month];
    [searchEndDateComps setDay:endDateComps.day];
    [searchEndDateComps setMinute:10 * endIndexByTenMins];
    
    NSDate* searchEndDate = [calendar dateFromComponents:searchEndDateComps];
    
    [db executeUpdate:INSERT_RUN_DETAIL, startDateTime, endDateTime, [NSNumber numberWithInt:runStep], searchStartDate, searchEndDate];
    
    [self closeDB:db];
}

-(void)insertPhoto:(NSString *)date path:(NSString *)path index:(NSString *)index
{
    FMDatabase* db = [self openDB];
    
    NSString *photoDate = date;
    NSString *photoPath = path;
    NSString *photoIndex = index;
    
    [db executeUpdate:INSERT_PHOTO, photoDate, photoPath,photoIndex];
    
    [self closeDB:db];
}

-(void)insertPhoto:(NSString *)date path:(NSString *)path
{
    FMDatabase* db = [self openDB];
    
    NSString *photoDate = date;
    NSString *photoPath = path;
    
    [db executeUpdate:INSERT_PHOTO, photoDate, photoPath];
    
    [self closeDB:db];
}

/***** update *****/

-(void)updateVitalConnectData:(NSString *)value01 typeID:(NSString *)typeId date:(NSString *)date{
    FMDatabase* db = [self openDB];
    
    [db executeUpdate:UPDATE_DATA_VITALCONNECT,value01,typeId,date];
    
    [self closeDB:db];
}

-(void)updateStep:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    [db executeUpdate:UPDATE_STEP, value, date];
    
    [self closeDB:db];
}

-(void)updateSleep:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    [db executeUpdate:UPDATE_SLEEP, value, date];
    
    [self closeDB:db];
}

-(void)updateSleepDetail:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime
{
    FMDatabase* db = [self openDB];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *endDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:endDateTime];
    
    int endIndexByTenMins = endDateComps.hour * 6 + endDateComps.minute / 10;
    NSDateComponents* searchEndDateComps = [NSDateComponents new];
    [searchEndDateComps setYear:endDateComps.year];
    [searchEndDateComps setMonth:endDateComps.month];
    [searchEndDateComps setDay:endDateComps.day];
    [searchEndDateComps setMinute:10 * endIndexByTenMins];
    
    NSDate* searchEndDate = [calendar dateFromComponents:searchEndDateComps];
    
    [db executeUpdate:UPDATE_SLEEP_DETAIL, endDateTime, searchEndDate, startDateTime];
    
    [self closeDB:db];
}

-(void)updateRun:(NSString *)date value:(NSString *)value
{
    FMDatabase* db = [self openDB];
    
    [db executeUpdate:UPDATE_RUN, value, date];
    
    [self closeDB:db];
}

-(void)updateRunDetail:(int)runStep startDateTime:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime{
    FMDatabase* db = [self openDB];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *endDateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit  fromDate:endDateTime];
    
    int endIndexByTenMins = endDateComps.hour * 6 + endDateComps.minute / 10;
    NSDateComponents* searchEndDateComps = [NSDateComponents new];
    [searchEndDateComps setYear:endDateComps.year];
    [searchEndDateComps setMonth:endDateComps.month];
    [searchEndDateComps setDay:endDateComps.day];
    [searchEndDateComps setMinute:10 * endIndexByTenMins];
    
    NSDate* searchEndDate = [calendar dateFromComponents:searchEndDateComps];
    
    [db executeUpdate:UPDATE_RUN_DETAIL, endDateTime, [NSNumber numberWithInt:runStep], searchEndDate, startDateTime];
    
    [self closeDB:db];
}

/***** select *****/

-(NSMutableDictionary *)selectDayStep:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_STEP,date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return [array objectAtIndex:0];
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableDictionary *)selectDaySleep:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_SLEEP,date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return [array objectAtIndex:0];
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableDictionary *)selectDaySleepDetail:(NSDate *)searchDateTime
{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_SLEEP_DETAIL, searchDateTime, searchDateTime];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return [array objectAtIndex:0];
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableDictionary *)selectDayRun:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_RUN,date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return [array objectAtIndex:0];
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableDictionary *)selectDayRunDetail:(NSDate *)searchDateTime{
    
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_RUN_DETAIL, searchDateTime, searchDateTime];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return [array objectAtIndex:0];
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableArray *)selectDayPhoto:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_PHOTO,date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        [self closeDB:db];
        return array;
    }else{
        [self closeDB:db];
        return nil;
    }
}

-(NSMutableArray *)selectMonthSteps:(NSString *)year :(NSString *)month{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_STEP, [NSString stringWithFormat:@"%@/%@%%", year, month]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectMonthSleeps:(NSString *)year :(NSString *)month{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_SLEEP, [NSString stringWithFormat:@"%@/%@%%", year, month]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectMonthRuns:(NSString *)year :(NSString *)month{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_RUN, [NSString stringWithFormat:@"%@/%@%%", year, month]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectYearSteps:(NSString *)year{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_STEP, [NSString stringWithFormat:@"%@%%", year]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectYearSleeps:(NSString *)year{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_SLEEP, [NSString stringWithFormat:@"%@%%", year]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectYearRuns:(NSString *)year{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TERM_RUN, [NSString stringWithFormat:@"%@%%", year]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

//ステップを取得
-(NSMutableArray *)selectAllStep{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_ALL_STEP];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

//睡眠の深さを取得
-(NSMutableArray *)selectAllSleep{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_ALL_SLEEP];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectAllRun {
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_ALL_RUN];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectStepsFromDate:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_STEP_FROM_DATE, date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectSleepsFromDate:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_SLEEP_FROM_DATE, date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectRunsFromDate:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_RUN_FROM_DATE, date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectTimelineDate:(int)limit offset:(int)offset{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TIMELINE_DATE, [NSNumber numberWithInt:limit], [NSNumber numberWithInt:offset]];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(NSMutableArray *)selectTimelineFromDate:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_TIMELINE_FROM_DATE, date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    [self closeDB:db];
    return array;
}

-(int)getCurrentStep:(NSString *)date{
    FMDatabase* db = [self openDB];
    FMResultSet *result = [db executeQuery:SELECT_DAY_STEP,date];
    
    NSMutableArray *array = [self convertToArray:result];
    
    if(array.count > 0){
        NSDictionary *stepRecord = [array objectAtIndex:0];
        NSString *stepValue = [stepRecord objectForKey:@"step_value"];
        NSArray *stepArray = [stepValue componentsSeparatedByString:@","];
        return [[stepArray objectAtIndex:143] intValue];
    } else {
        return 0;
    }
}

-(int)getDiffSteps:(int)subtStep start:(NSDate *)startDate end:(NSDate *)endDate{
    int totalStep = 0;
    
    //開始日と終了日の差を日にちで出す
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *differenceDays = [cal components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    
    //間の日にちの歩数を全て取得(当日も含めて)
    for(int i = 0; i <= [differenceDays day]; i++) {
        NSDateComponents *comp = [[NSDateComponents alloc] init];
        [comp setDay:i];
        
        NSDate *day = [cal dateByAddingComponents:comp toDate:startDate options:0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [formatter stringFromDate:day];
        
        int steps = [self getCurrentStep:dayString];
        
        totalStep += steps;
    }
    
    //最後にスタート時の歩数を引く
    totalStep = totalStep - subtStep;
    
    return totalStep;
}

@end
