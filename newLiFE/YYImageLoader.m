//
//  YYImageLoader.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/15.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "YYImageLoader.h"
@implementation YYImageLoader
+ (void)imageWithURL:(NSURL*)url completion:(YYImageLoaderCompletion)completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (connectionError) {
             completion(nil, connectionError);
             return;
         }
         UIImage *image = [UIImage imageWithData:data];
         completion(image, nil);
     }];
}
@end
