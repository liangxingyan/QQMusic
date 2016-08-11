//
//  leftViewController.m
//  qqMusic
//
//  Created by lxy on 16/4/4.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "leftViewController.h"


@interface leftViewController ()

@end

@implementation leftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    //使用毛玻璃效果视图
    UIView *leftblurView = [[UIView alloc] initWithFrame:self.view.bounds];
    leftblurView.backgroundColor = [UIColor colorWithRed:28/255.0 green:52/255.0 blue:67/255.0 alpha:1];
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = [UIColor colorWithRed:24/255.0 green:39/255.0 blue:57/255.0 alpha:1];
    [self.view addSubview:leftblurView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
