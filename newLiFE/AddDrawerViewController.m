//
//  AddDrawerViewController.m
//  newLiFE
//
//  Created by Answerer-ryo on 2014/09/16.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "AddDrawerViewController.h"
#import "AlarmViewController.h"
#import "RunningViewController.h"

@interface AddDrawerViewController ()

@end

@implementation AddDrawerViewController

@synthesize deviceType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)transferSleepVC:(id)sender {
    AlarmViewController *alarmViewController = [[AlarmViewController alloc] init];
    alarmViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"sleep"];
    alarmViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:alarmViewController animated:YES completion:^{
        [self.slidingViewController resetTopViewAnimated:NO];
    }];
}

- (IBAction)transferRunningVC:(id)sender {
    RunningViewController *runningViewController = [[RunningViewController alloc] init];
    runningViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"running"];
    runningViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:runningViewController animated:YES completion:^{
        [self.slidingViewController resetTopViewAnimated:NO];
    }];
}

- (IBAction)photoButtonAction:(id)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.delegate = self;
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        //ipc.allowsEditing = YES;
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photoImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *saveImage;
    float compressionPer;
    
    if(photoImage.size.width < photoImage.size.height){
        compressionPer = 640 / photoImage.size.width;
    }else{
        compressionPer = 640 / photoImage.size.height;
    }

    CGSize size = CGSizeMake(photoImage.size.width * compressionPer, photoImage.size.height *compressionPer);
    UIGraphicsBeginImageContext(size);
    [photoImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //NSData *originalData = UIImagePNGRepresentation(photoImage);
    //NSData *originalData = UIImageJPEGRepresentation(photoImage, 0.5f);
    //NSData *data = UIImagePNGRepresentation(saveImage);
    NSData *data = UIImageJPEGRepresentation(saveImage, 0.5f);
    
    NSDate *today = [NSDate date];
    
    //日にち取得
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned flags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *todayComponents = [calendar components:flags fromDate:today];
    int todayHour = [todayComponents hour];
    int todayMin = [todayComponents minute];
    
    int arrayIndex = todayHour * 6 + (todayMin/10);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"image/"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(result){
        NSLog(@"ディレクトリの作成に成功：%@",dirPath);
    }else{
        NSLog(@"ディレクトリの作成に失敗：%@",error);
    }
    
    NSString *pathString = [NSString stringWithFormat:@"%d_%@.jpg",arrayIndex,[formatter stringFromDate:today]];
    //NSString *originalPathString = [NSString stringWithFormat:@"%d_%@_original.jpg",arrayIndex,[formatter stringFromDate:today]];
    
    NSString *filePath = [dirPath stringByAppendingPathComponent:pathString];
    //NSString *originalFilePath = [dirPath stringByAppendingPathComponent:originalPathString];
    
    if([data writeToFile:filePath atomically:YES]){
        NSLog(@"ImageSave OK");
        
        //[originalData writeToFile:originalFilePath atomically:YES];
        
        /***** 日にちフォーマット *****/
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        NSString *todayString = [formatter stringFromDate:today];
        /***** 日にちフォーマット *****/
        
        DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
        [dbHelper insertPhoto:todayString path:pathString index:[NSString stringWithFormat:@"%d",arrayIndex]];
    }else{
        NSLog(@"ImageSave NG");
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
