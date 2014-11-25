//
//  UITableView+reloadDataWithCompletion.h
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/24.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView(ReloadDataWithCompletion)

-(void)reloadDataWithCompletion:( void (^) (void) )completionBlock;

@end

