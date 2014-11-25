//
//  TimeLineViewController.m
//  newLiFE
//
//  Created by YawataShoichi on 2014/10/24.
//  Copyright (c) 2014年 Answerer-ryo. All rights reserved.
//

#import "TimeLineViewController.h"
#import "MenuDrawerViewController.h"

#import "TimeLineMeTableViewCell.h"
#import "DatabaseHelper.h"

@interface TimeLineViewController ()

@end

@implementation TimeLineViewController

#define MY_TIME_LINE 0
#define FRIEND_TIME_LINE 1
#define PAGING_VIEW 2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ページングビューの設定
    self.pagingView.delegate = self;
    [self.pagingView setContentSize:CGSizeMake(self.view.frame.size.width * 2, self.pagingView.frame.size.height)];
    self.pagingView.tag = PAGING_VIEW;
    
    //切り替えセグメントの設定
    [self.changeSegmented setBackgroundImage:[UIImage imageNamed:@"LiFE_TimeLine_TabBGNormal.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.changeSegmented setBackgroundImage:[UIImage imageNamed:@"LiFE_TimeLine_TabBGSelected.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.changeSegmented addTarget:self action:@selector(changeSegmentedValue:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor] ,NSFontAttributeName:[UIFont fontWithName:@"SourceHanSansJP-Light" size:14.0f]};
    [self.changeSegmented setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.changeSegmented setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
    
    //タイトル用のラベルフォントを変更
    self.titleLabel.font = [UIFont fontWithName:@"SourceHanSansJP-Light" size:20.0f];
    
    //二つのテーブルビューを設定
    self.myTimeLineTableView.delegate = self;
    self.myTimeLineTableView.dataSource = self;
    self.myTimeLineTableView.tag = MY_TIME_LINE;
    UINib *nib = [UINib nibWithNibName:@"TimeLineMeTableViewCell" bundle:nil];
    [self.myTimeLineTableView registerNib:nib forCellReuseIdentifier:@"CellTimeLineMe"];
    
    //自分のタイムラインデータ取得
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    //timeLineListMe = [dbHelper select]
    
    
    self.friendTimeLineTableView.delegate = self;
    self.friendTimeLineTableView.dataSource = self;
    self.friendTimeLineTableView.tag = FRIEND_TIME_LINE;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuDrawerViewController class]]) {
        UIViewController *menu =  [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
        self.slidingViewController.underLeftViewController = menu;
    }
    [self.slidingViewController setAnchorRightRevealAmount:264.0f];
    
    self.slidingViewController.delegate = self;
    [self.slidingViewController.topViewController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//スクロール処理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //テーブルビューもこの処理に入ってしまうためここで処理を区切る
    if(scrollView.tag != PAGING_VIEW) return;
    
    //ページが切り替わった時にセグメントも更新する
    CGFloat pageWidth = scrollView.frame.size.width;
    if((NSInteger) fmod(scrollView.contentOffset.x, pageWidth) == 0) {
        NSLog(@"%f", scrollView.contentOffset.x / pageWidth);
        self.changeSegmented.selectedSegmentIndex = scrollView.contentOffset.x / pageWidth;
    }
}

//セグメントの更新処理
-(void)changeSegmentedValue:(id)sender {
    UISegmentedControl *segmented = (UISegmentedControl *)sender;
    
    //セグメントの切り替えでページを変える
    if([segmented selectedSegmentIndex] == 0){
        [self.pagingView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    } else {
        [self.pagingView setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = 0;
    
    if(tableView.tag == MY_TIME_LINE) {
        row = 3;
    } else {
        row = 5;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //各セルのIDを設定
    NSString* cellIdentifier;
    
    if(tableView.tag == MY_TIME_LINE) {
        TimeLineMeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimeLineMe"];
        
        //[cell setColor:];
        
        return cell;

    } else {
        cellIdentifier = @"CellTimeLineFriend";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellTimeLineFriend"];
        
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = [NSString stringWithFormat:@"%@:%d", cellIdentifier, [indexPath row] + 1];
        
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        return cell;
    }
    
}

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}
@end
