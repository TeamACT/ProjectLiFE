//
//  YYImageLoader.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/15.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^YYImageLoaderCompletion)(UIImage *image, NSError *error);
@interface YYImageLoader : NSObject
+ (void)imageWithURL:(NSURL*)url completion:(YYImageLoaderCompletion)completion;
@end
