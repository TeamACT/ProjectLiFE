//
//  UITableView+reloadDataWithCompletion.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/24.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "UITableView+ReloadDataWithCompletion.h"

@implementation UITableView(ReloadDataWithCompletion)

//reloadData完了後に同期的に処理を行う
-(void)reloadDataWithCompletion:(void (^) (void))completionBlock{
    [self reloadData];
    if(completionBlock) {
        completionBlock();
    }
}

@end
