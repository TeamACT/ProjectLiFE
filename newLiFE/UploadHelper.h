//
//  UploadHelper.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/22.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadHelper : NSObject

-(void)dataUpload:(void (^)())block;
-(void)logUpload:(void (^)())block;

@end
