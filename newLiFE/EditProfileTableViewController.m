//
//  EditProfileTableViewController.m
//  newLiFE
//
//  Created by 八幡 翔一 on 2014/09/08.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "EditGoalTableViewController.h"

#import "UploadHelper.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"

@interface EditProfileTableViewController ()

@end

@implementation EditProfileTableViewController

#define TEXT_FIELD_NAME 0
#define TEXT_FIELD_REAL_NAME 1

#define PICKER_LIBRARY 0
#define PICKER_CAMERA 1

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //テーブルビューの背景色を変更
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.0]];
    
    //現在の階層を確認
    int count = [self.navigationController.viewControllers count];
    if(count == 1) {
        //完了ボタンを追加
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(doneEdit:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    //ナビゲーションバーの境界線を消す
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIImageView *navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];
    navBarHairlineImageView.hidden = YES;
    
    //戻るボタンのテキストを消す
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @" " style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //各セルのIDを設定
    NSString* cellIdentifier;
    switch([indexPath row]) {
        case 0:
            cellIdentifier = @"CellUserImage";
            break;
        case 1:
            cellIdentifier = @"CellUserName";
            break;
        case 2:
            cellIdentifier = @"CellUserRealName";
            break;
        case 3:
            cellIdentifier = @"CellUserMailAddress";
            break;
        case 4:
            cellIdentifier = @"CellUserHeight";
            break;
        case 5:
            cellIdentifier = @"CellUserWeight";
            break;
        case 6:
            cellIdentifier = @"CellUserBirthDay";
            break;
        case 7:
            cellIdentifier = @"CellUserGender";
            break;
    }
    
    //セルの中身を設定
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    switch([indexPath row]) {
        case 0:{
            //プロフィール画像
            UIImageView *profileImageView = (UIImageView *)[cell viewWithTag:3];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirPath = [paths objectAtIndex:0];
            UIImage *profileImage = [[UIImage alloc] initWithContentsOfFile:[documentsDirPath stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]]];
            profileImageView.image = profileImage;
            profileImageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        }
        case 1:{
            NSString *userName = [ud objectForKey:@"UserName"];
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            textField.delegate = self;
            textField.tag = TEXT_FIELD_NAME;
            [textField setText:userName];
            //セルはハイライトしない
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 2:{
            NSString *userRealName = [ud objectForKey:@"UserRealName"];
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            textField.delegate = self;
            textField.tag = TEXT_FIELD_REAL_NAME;
            [textField setText:userRealName];
            //セルはハイライトしない
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 3:{
            UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
            valueLabel.text = [ud objectForKey:@"UserMailAddress"];
            //セルはハイライトしない
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case 4:{
            float userHeight = [ud floatForKey:@"UserHeight"];
            
            UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
            valueLabel.text = [NSString stringWithFormat:@"%.1fcm", userHeight];
            break;
        }
        case 5:{
            float userWeight = [ud floatForKey:@"UserWeight"];
            
            UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
            valueLabel.text = [NSString stringWithFormat:@"%.1fkg", userWeight];
            break;
        }
        case 6:{
            NSDate *userBirthDay = [ud objectForKey:@"UserBirthDay"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            
            UILabel *valueLabel = (UILabel *)[cell viewWithTag:2];
            valueLabel.text = [dateFormatter stringFromDate:userBirthDay];
            break;
        }
        case 7:{
            int userGender = [ud integerForKey:@"UserGender"];
            
            UISegmentedControl *genderSegmented = (UISegmentedControl *)[cell viewWithTag:6];
            if(userGender == GENDER_MALE) {
                [genderSegmented setSelectedSegmentIndex:0];
            } else {
                [genderSegmented setSelectedSegmentIndex:1];
            }
            [genderSegmented addTarget:self action:@selector(segmentedValueChanged:) forControlEvents:UIControlEventValueChanged];
            //セルはハイライトしない
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
    }
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //名前を更新
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    switch([textField tag]) {
        case TEXT_FIELD_NAME:
            [ud setObject:[textField text] forKey:@"UserName"];
            break;
        case TEXT_FIELD_REAL_NAME:
            [ud setObject:[textField text] forKey:@"UserRealName"];
            break;
    }
    [ud synchronize];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)segmentedValueChanged:(UISegmentedControl *)sender {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    switch([sender selectedSegmentIndex]) {
        case 0:
            [ud setInteger:GENDER_MALE forKey:@"UserGender"];
            break;
        case 1:
            [ud setInteger:GENDER_FEMALE forKey:@"UserGender"];
            break;
    }
    [ud synchronize];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"EditImageSegue"]) {
        //アクションシートを表示
        UIActionSheet *as = [[UIActionSheet alloc] init];
        as.delegate = self;
        [as addButtonWithTitle:@"写真を撮る"];
        [as addButtonWithTitle:@"アルバムから選ぶ"];
        [as addButtonWithTitle:@"プロフィール写真を見る"];
        [as addButtonWithTitle:@"削除"];
        [as addButtonWithTitle:@"キャンセル"];
        as.destructiveButtonIndex = 3;
        as.cancelButtonIndex = 4;
        [as showInView:self.view];
        
        return NO;
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditGoalTableViewController *editGoalViewController = [segue destinationViewController];
    
    if ( [[segue identifier] isEqualToString:@"EditProfHeightSegue"] ) {
        editGoalViewController.editingGoal = EDIT_PROF_HEIGHT;
        editGoalViewController.navigationItem.title = @"身長";
    } else if ( [[segue identifier] isEqualToString:@"EditProfWeightSegue"] ) {
        editGoalViewController.editingGoal = EDIT_PROF_WEIGHT;
        editGoalViewController.navigationItem.title = @"体重";
    } else if ( [[segue identifier] isEqualToString:@"EditProfBirthDaySegue"] ) {
        editGoalViewController.editingGoal = EDIT_PROF_BIRTHDAY;
        editGoalViewController.navigationItem.title = @"生年月日";
    }
}

-(void)doneEdit:(id)sender{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    UploadHelper *uploadHelper = [[UploadHelper alloc] init];
    [uploadHelper dataUpload:^{
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if([ud integerForKey:@"LoginKind"] == LOG_IN_FACEBOOK) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *userID = [ud objectForKey:@"UserID"];
            
            NSURL *url = [NSURL URLWithString:URL_UPLOAD_IMAGE];
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
            
            [request setTimeOutSeconds:60];
            [request setDelegate:self];
            [request setPostValue:userID forKey:@"UserID"];
            [request setPostValue:@"0" forKey:@"SetDefault"];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]];
            NSData *data = [NSData dataWithContentsOfFile:imagePath];
            [request setData:data withFileName:[NSString stringWithFormat:@"%@.png", userID] andContentType:nil forKey:@"upfile"];
            [request setCompletionBlock:^{
                [SVProgressHUD dismiss];
                
                //初期登録時のプロフィール編集が完了した場合の処理
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"完了" message: @"初期登録が完了しました。修正したい場合は、設定→プロフィール編集より可能です。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }];
            [request setFailedBlock:^{
                
            }];
            [request startAsynchronous];
        } else {
            [SVProgressHUD dismiss];
            
            //初期登録時のプロフィール編集が完了した場合の処理
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"完了" message: @"初期登録が完了しました。修正したい場合は、設定→プロフィール編集より可能です。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
    
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger) buttonIndex {
    switch(buttonIndex) {
        case 0:{
            //日ログ画面へ遷移
            UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"day"];
            self.slidingViewController.topViewController = newTopViewController;
            break;
        }
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:{
            //カメラを起動
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
            break;
        }
        case 1:{
            //アルバムから選択
            UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerVC.delegate = self;
            imagePickerVC.allowsEditing = YES;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
            break;
        }
        case 2:{
            //現在の写真を見る
            ShowImageViewController *showIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"showImage"];
            showIVC.delegate = self;
            [self presentViewController:showIVC animated:YES completion:nil];
            break;
        }
        case 3:{
            //プロフィール写真を削除する
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirPath = [paths objectAtIndex:0];
            UIImage *profileImage = [UIImage imageNamed:@"LiFE_ProfileImage.png"];
            NSData *dataProfileImage = UIImagePNGRepresentation(profileImage);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]] atomically:YES];
            
            [self.tableView reloadData];
            [self uploadUserImage:YES];
            
            break;
        }
        case 4:{
            //キャンセル:セルの選択状態を解除する
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        }
    }
    
}

#pragma mark - UIImagePickerControllerDelegate protocol methods

/// 撮影した画像を選択後に呼ばれる
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirPath = [paths objectAtIndex:0];
    
    NSData *dataProfileImage = UIImagePNGRepresentation(image);
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [dataProfileImage writeToFile:[documentsDirPath stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]] atomically:YES];
    
    //カメラで撮影した場合はカメラロールに保存
    if([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        [SVProgressHUD showWithStatus:@"アルバムに撮影した写真を保存しています..." maskType:SVProgressHUDMaskTypeBlack];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [self uploadUserImage:NO];
        }];
    }
    
}

/// キャンセルを選択した際に呼ばれる
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void) savingImageIsFinished:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo
{
    [SVProgressHUD dismiss];
    
    if(_error){//エラーのとき
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"画像の保存に失敗しました。" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self uploadUserImage:NO];
    }];
}

-(void)closeShowImageView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void) uploadUserImage:(Boolean)isDefault {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *userID = [ud objectForKey:@"UserID"];
    
    
    NSURL *url = [NSURL URLWithString:URL_UPLOAD_IMAGE];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setPostValue:userID forKey:@"UserID"];
    [request setPostValue:isDefault ? @"1" : @"0" forKey:@"SetDefault"];
    
    if(!isDefault) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[ud stringForKey:@"UserImage"]];
        NSData *data = [NSData dataWithContentsOfFile:imagePath];
        [request setData:data withFileName:[NSString stringWithFormat:@"%@.png", userID] andContentType:nil forKey:@"upfile"];
    }
    
    [request startAsynchronous];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
}

//httpリクエスト完了後の処理
- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
}

//httpリクエスト失敗時の処理
- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    
    // 通信ができなかったときの処理
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"ネットワークエラー" message: @"インターネットに接続できませんでした。ネットワーク状況を確認して再度お試しください。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@end
