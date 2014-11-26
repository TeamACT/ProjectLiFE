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

#define ME_LIMITED_DAYS 2

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
    self.myTimeLineTableView.backgroundView = nil;
    [self.myTimeLineTableView setBackgroundColor:[UIColor clearColor]];
    
    //自分のタイムラインデータ取得
    timeLineListMe = [NSMutableArray array];
    myTimeLineOffset = 0;
    
    DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
    //まずは一度に取得する制限数分の日付を取得
    NSMutableArray *dates = [dbHelper selectTimelineDate:ME_LIMITED_DAYS offset:myTimeLineOffset];
    myTimeLineOffset += ME_LIMITED_DAYS;//offset値の更新
    //該当日付のデータをまとめて取得
    for(NSMutableDictionary *date in dates) {
        NSMutableArray *meDataFromDate = [dbHelper selectTimelineFromDate:[date objectForKey:@"timeline_date"]];
        
        NSDictionary *meData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [date objectForKey:@"timeline_date"], @"date",
                                 meDataFromDate, @"data",nil];
        
        [timeLineListMe addObject:meData];
    }
    
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
    if(scrollView.tag == FRIEND_TIME_LINE) return;
    
    if(scrollView.tag == PAGING_VIEW) {
        //ページが切り替わった時にセグメントも更新する
        CGFloat pageWidth = scrollView.frame.size.width;
        if((NSInteger) fmod(scrollView.contentOffset.x, pageWidth) == 0) {
            NSLog(@"%f", scrollView.contentOffset.x / pageWidth);
            self.changeSegmented.selectedSegmentIndex = scrollView.contentOffset.x / pageWidth;
        }
    } else if(scrollView.tag == MY_TIME_LINE) {
        //自分のタイムラインのテーブルを一番下までスクロールしたら、追加でデータを読み込む
        if(self.myTimeLineTableView.contentOffset.y >= (self.myTimeLineTableView.contentSize.height - self.myTimeLineTableView.bounds.size.height)) {
            
            DatabaseHelper *dbHelper = [[DatabaseHelper alloc] init];
            //まずは一度に取得する制限数分の日付を取得
            NSMutableArray *dates = [dbHelper selectTimelineDate:ME_LIMITED_DAYS offset:myTimeLineOffset];
            //新しい日付がなければ更新をかけない
            if([dates count] > 0) {
                myTimeLineOffset += ME_LIMITED_DAYS;//offset値の更新
                //該当日付のデータをまとめて取得
                for(NSMutableDictionary *date in dates) {
                    //表示用に日付をフォーマット
                    
                    
                    //該当日付のデータを取得
                    NSMutableArray *meDataFromDate = [dbHelper selectTimelineFromDate:[date objectForKey:@"timeline_date"]];
                    
                    //日付とその日に保存された各データをまとめる
                    NSDictionary *meData = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [date objectForKey:@"timeline_date"], @"date",
                                            meDataFromDate, @"data",nil];
                    
                    [timeLineListMe addObject:meData];
                }
                [self.myTimeLineTableView reloadData];
            }
        }
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
    int section = 0;
    
    if(tableView.tag == MY_TIME_LINE) {
        section = [timeLineListMe count];
    } else {
        section = 1;
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    int row = 0;
    
    if(tableView.tag == MY_TIME_LINE) {
        NSDictionary *meData = [timeLineListMe objectAtIndex:section];
        NSMutableArray *meDataFromDate = [meData objectForKey:@"data"];
        row = [meDataFromDate count];
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
        
        //データの取得はまずセクションごとに日付でわけて、行数からデータを割り出す
        NSDictionary *meData = [timeLineListMe objectAtIndex:[indexPath section]];
        NSMutableArray *meDataFromDate = [meData objectForKey:@"data"];
        NSDictionary *meDayData = [meDataFromDate objectAtIndex:[indexPath row]];
        
        int type = [[meDayData objectForKey:@"timeline_type"] intValue];
        NSString *title = @"";
        NSString *value = [meDayData objectForKey:@"timeline_value"];
        int percent = [[meDayData objectForKey:@"timeline_attainment"] intValue];
        
        switch(type) {
            case TIMELINE_TYPE_STEP:
                [cell setColor:TIMELINE_COLOR_ORANGE];
                title = @"歩数";
                break;
            case TIMELINE_TYPE_DIST:
                [cell setColor:TIMELINE_COLOR_ORANGE];
                title = @"歩行距離";
                break;
            case TIMELINE_TYPE_CALORY:
                [cell setColor:TIMELINE_COLOR_GREEN];
                title = @"カロリー";
                break;
            case TIMELINE_TYPE_RUN:
                [cell setColor:TIMELINE_COLOR_RED];
                title = @"ランニング";
                break;
            case TIMELINE_TYPE_SLEEP:
                [cell setColor:TIMELINE_COLOR_BLUE];
                title = @"睡眠時間";
                break;
        }
        [cell setCellItems:title value:value sub:@"" percent:percent];
        
        
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //各セクションのタイトルを設定
    NSString *title = @"";
    if(tableView.tag == MY_TIME_LINE) {
        NSDictionary *meData = [timeLineListMe objectAtIndex:section];
        NSString *meDate = [meData objectForKey:@"date"];
        title = meDate;
    } else {
        title = @"";
    }
    return title;
}

- (IBAction)openDrawerMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
    if ([self.slidingViewController currentTopViewPosition] == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        [self.slidingViewController resetTopViewAnimated:YES];
    }
}
@end
