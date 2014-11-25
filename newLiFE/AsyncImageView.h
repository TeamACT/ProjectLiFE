//
//  AsyncImageView.h
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/10/10.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView {
@private
    NSURLConnection *conn;
    NSMutableData *data;
}
-(void)loadImage:(NSString *)url;
-(void)abort;
@end
