//
//  DatabaseHelper.h
//  LiFE
//
//  Created by Answerer-ryo on 2014/05/27.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase/FMDatabase.h"

@interface DatabaseHelper : NSObject

-(void)initialize;
-(void)initializeWithVersion:(int)version;
-(void)upgrade;

-(FMDatabase *)openDB;
-(void)closeDB:(FMDatabase *) db;
-(NSMutableArray *)convertToArray:(FMResultSet *) result;

//各種INSERT文
-(void)insertStep:(NSString *)date value:(NSString *)value;
-(void)insertSleep:(NSString *)date value:(NSString *)value;
-(void)insertSleepDetail:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime;
-(void)insertRun:(NSString *)date value:(NSString *)value;
-(void)insertRunDetail:(int)runStep startDateTime:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime;
-(void)insertPhoto:(NSString *)date path:(NSString *)path index:(NSString *)index;
-(void)insertTimeline:(NSString *)date value:(NSString *)value percent:(int)percent type:(int)type;

//各種UPDATE文
-(void)updateVitalConnectData:(NSString *)value01 typeID:(NSString *)typeId date:(NSString *)date;

-(void)updateStep:(NSString *)date value:(NSString *)value;
-(void)updateSleep:(NSString *)date value:(NSString *)value;
-(void)updateSleepDetail:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime;
-(void)updateRun:(NSString *)date value:(NSString *)value;
-(void)updateRunDetail:(int)runStep startDateTime:(NSDate *)startDateTime endDateTime:(NSDate *)endDateTime;

//各種SELECT文
-(NSMutableDictionary *)selectDayStep:(NSString *)date;
-(NSMutableDictionary *)selectDaySleep:(NSString *)date;
-(NSMutableDictionary *)selectDaySleepDetail:(NSDate *)searchDateTime;
-(NSMutableDictionary *)selectDayRun:(NSString *)date;
-(NSMutableDictionary *)selectDayRunDetail:(NSDate *)searchDateTime;
-(NSMutableArray *)selectDayPhoto:(NSString *)date;

-(NSMutableArray *)selectMonthSteps:(NSString *)year :(NSString *)month;
-(NSMutableArray *)selectMonthSleeps:(NSString *)year :(NSString *)month;
-(NSMutableArray *)selectMonthRuns:(NSString *)year :(NSString *)month;

-(NSMutableArray *)selectYearSteps:(NSString *)year;
-(NSMutableArray *)selectYearSleeps:(NSString *)year;
-(NSMutableArray *)selectYearRuns:(NSString *)year;

-(NSMutableArray *)selectAllStep;
-(NSMutableArray *)selectAllSleep;
-(NSMutableArray *)selectAllRun;

-(NSMutableArray *)selectStepsFromDate:(NSString *)date;
-(NSMutableArray *)selectSleepsFromDate:(NSString *)date;
-(NSMutableArray *)selectRunsFromDate:(NSString *)date;

-(NSMutableArray *)selectTimelineDate:(int)limit offset:(int)offset;
-(NSMutableArray *)selectTimelineFromDate:(NSString *)date;

-(int)getCurrentStep:(NSString *)date;
-(int)getDiffSteps:(int) subtStep start:(NSDate *)startDate end:(NSDate *)endDate;

@end
