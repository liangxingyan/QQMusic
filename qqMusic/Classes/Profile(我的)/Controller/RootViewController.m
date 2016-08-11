//
//  RootViewController.m
//  qqMusic
//
//  Created by lxy on 16/3/22.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "RootViewController.h"
#import "MusicModel.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "FirstViewController.h"
#import "UIImageView+BSExtension.h"

@interface RootViewController ()

// 定义一个音乐数组，放音乐模型
@property (nonatomic, strong) NSMutableArray *music;

@property (nonatomic, strong) FirstViewController *firstVc;

@end

@implementation RootViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSMutableArray *)music {
    if (!_music) {
        self.music = [NSMutableArray array];
    }
    return _music;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //1.创建背景视图
    [self _createBackgroundView];
    
    [self loadNewStatus];
    

}

#pragma mark - 加载最新的数据
- (void)loadNewStatus {

    /**
     请求音乐接口
     http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist
     */
    
    NSURL *url = [NSURL URLWithString:@"http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist"];
    NSArray *array = [NSArray arrayWithContentsOfURL:url];
    NSArray *newMusic = [MusicModel mj_objectArrayWithKeyValuesArray:array];
    
    NSRange range = NSMakeRange(0, newMusic.count);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.music insertObjects:newMusic atIndexes:set];
 

}

//1.创建背景视图
- (void)_createBackgroundView {
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"player_albumblur_default"]];
    //直接拿view的尺寸就行
    imageView.frame = self.view.bounds;
    [self.view insertSubview:imageView atIndex:0];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 单元格的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.music.count;
}

// 创建单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"music";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    }
    
    // 取出音乐模型
    MusicModel *music = self.music[indexPath.row];
    
    // 设置cell的值
    cell.textLabel.text = music.name;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = music.singer;
 
    // 设置头像
    NSString *imageUrl = music.picUrl;
    [cell.imageView setHeader:imageUrl];
    
    // 设置cell的背景
    cell.backgroundColor = [UIColor colorWithRed:35/255.0 green:53/255.0 blue:68/255.0 alpha:1];
    
    
    return cell;
}

// 点击cell播放
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LoginViewController *log = [LoginViewController shareLoginViewController];
    [log loadViewIfNeeded];

    // 取出音乐模型
    MusicModel *music =  log.musicData[indexPath.row];
    
    // 载入歌曲的数据
    [log loadData:music];
    
    
    // 改变index
    log.index = indexPath.row;
    
    // 播放
    [log play:music.mp3Url];
    
}


@end
