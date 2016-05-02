//
//  TowViewController.m
//  qqMusic
//
//  Created by lxy on 16/4/8.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "TowViewController.h"
#import "CareChoseViewController.h"
#import "LineViewController.h"
#import "SingSheetViewController.h"
#import "RadioStationViewController.h"
#import "MVViewController.h"
#import "SongYCSlideView.h"

#define kWindowWidth            self.view.frame.size.width
#define kWindowHeight           self.view.frame.size.height

@interface TowViewController ()

@end

@implementation TowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CareChoseViewController *careChoseVC = [[CareChoseViewController alloc] init];
    LineViewController *lineVC = [[LineViewController alloc] init];
    SingSheetViewController *singSheetVC = [[SingSheetViewController alloc] init];
    RadioStationViewController *radioStationVC = [[RadioStationViewController alloc] init];
    MVViewController *mvViewController = [[MVViewController alloc] init];
    
    NSArray *arraySControllers = @[@{@"精选" : careChoseVC}, @{@"排行" : lineVC}, @{@"歌单" : singSheetVC},
                                   @{@"电台" : radioStationVC}, @{@"MV" : mvViewController}];
    
    //这里的坐标是关键
    SongYCSlideView *songerYCSlideView = [[SongYCSlideView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) WithViewControllers:arraySControllers];
    
    [self.view addSubview:songerYCSlideView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
