//
//  LoginViewController.h
//  qqMusic
//
//  Created by lxy on 16/3/22.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAudioPlayer;
@class MusicModel;

@interface LoginViewController : UIViewController   {
    // 背景视图
    UIImageView *imageView;
    
    // 上面的毛玻璃视图
    UIVisualEffectView *blurView;

    // 停止按钮
    UIButton *pauseButton;
    
    // 循环播放
    UIButton *repeat;
    
    // 单曲循环
    UIButton *repeatone;
    
    // 随机播放
    UIButton *random;
    
    // 播放界面视图
    UIVisualEffectView *play;
    
    // 滑块
    UISlider *slider;

}

// 用来传递歌曲名和歌唱者
@property (nonatomic, strong) void(^myBlock)(UILabel *, UILabel *);

// 用来传递状态
@property (nonatomic, strong) void(^playing)(BOOL, BOOL);

// 歌名
@property (nonatomic, strong) UILabel *songLable;

// 歌手
@property (nonatomic, strong) UILabel *singerLable;

// 播放按钮
@property (nonatomic, strong) UIButton *playButton;

// 播放器
@property (nonatomic, strong) AVAudioPlayer *player;

// 取得MP3音乐
@property (nonatomic, weak) NSString *url;


// 定时器
@property (nonatomic, weak) NSTimer *timer;

// 存放音乐模型数据
@property (nonatomic, strong) NSMutableArray *musicData;

// 换歌
@property (nonatomic, assign) NSInteger index;

// 我想控制刚启动界面时不直接播放
@property (nonatomic, assign) NSInteger firstplay;

// 单例的类方法命名一般用share+当前类名
+ (instancetype)shareLoginViewController;

// 播放歌曲
- (void)playsongAction:(UIButton *)button;

// 播放
- (void)play:(NSString *)playFile;

// 载入歌曲
- (void)loadData:(MusicModel *)music;

@end
