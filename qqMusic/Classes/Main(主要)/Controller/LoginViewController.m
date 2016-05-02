//
//  LoginViewController.m
//  qqMusic
//
//  Created by lxy on 16/3/22.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LoginViewController.h"
#import "MusicModel.h"
#import <AVFoundation/AVFoundation.h>
#import "MJExtension.h"
#import "UIImageView+WebCache.h"

#define kWidth self.view.bounds.size.width //self.view的宽度
#define kHeight self.view.bounds.size.height //self.view的高度

// static 修饰的对象，只有在程序结束对才会被释放
static LoginViewController *loginViewController = nil;

@interface LoginViewController ()

@end

@implementation LoginViewController

/**
    创建单例的步骤
 1.保留一个单例对象的静态实例，并初始化为nil
 2.声明和实现一个类方法，返回一个有值的该类对象
 3.重写allocWithZoon方法，做判空处理
 */


// 单例的类方法命名一般用share+当前类名
+ (instancetype)shareLoginViewController {
    
    // synchronized能保证里面的内容同时只能被一个线程执行
    @synchronized(self) {
        
        // 先判断是否为空，如果为空再创建
        if (loginViewController == nil) {
            loginViewController = [[self alloc] init];
        }
    }
    
    return loginViewController;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (loginViewController == nil) {
        loginViewController = [super allocWithZone:zone];
    }
    return loginViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSMutableArray *)musicData {
    if (!_musicData) {
        self.musicData = [NSMutableArray array];
    }
    return _musicData;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    /*
     一定要注意先后顺序
     */
    
    //1.设置背景图片
    [self _createBackgroundLogin];
    
    //2,创建毛玻璃视图
    [self _createBlur];
    
    //3.设置返回图片按钮
    [self _backButton];
    
    //4.创建播放界面
    [self _createPlayBar];
    
    //5，创建进度工具视图
    [self _createProgressBar];
    
    //6.拿到音乐文件
    
    // 取出音乐数据
    NSURL *url = [NSURL URLWithString:@"http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist"];
    NSArray *array = [NSArray arrayWithContentsOfURL:url];
    NSArray *newMusic = [MusicModel mj_objectArrayWithKeyValuesArray:array];
    
    NSRange range = NSMakeRange(0, newMusic.count);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.musicData insertObjects:newMusic atIndexes:set];
    
    _index = 0;
    _firstplay = 1;
    
    // 取出音乐模型
    MusicModel *music = self.musicData[_index];

    
    //8.显示歌曲的数据
    [self loadData:music];
    
    
}

#pragma mark - 歌曲数据

- (void)loadData:(MusicModel *)music {
    
    //歌手
    NSString *singer = music.singer;
    
    //歌名
    NSString *song =  music.name;
    
    //专辑图
    NSString *image = music.picUrl;
    
    //MP3文件
    _url = music.mp3Url;
 
    //歌名的label
    UILabel *songLabel = (UILabel *)[blurView viewWithTag:100];
    
    //歌手label
    UILabel *singerLabel = [(UILabel *)blurView viewWithTag:200];
    
    songLabel.text = song;
    singerLabel.text = singer;
    
    //背景图片
    [imageView sd_setImageWithURL:[NSURL URLWithString:image]];
    
   
}


#pragma mark - 播放功能
    //1，播放
- (void)play:(NSString *)playFile {

    // 这里调用block是因为点击了cell，所以FirstViewController里面也要改变
    if (_myBlock) {
        _myBlock(_singerLable, _songLable);
        
        // 这里调用block，因为我点击了cell播放，那么FirstViewController里面也有改变播放状态
        if (_playing) {
            _playing(YES, NO);
        }
    }
    
    NSData *mp3Data = [NSData dataWithContentsOfURL:[NSURL URLWithString:playFile]];
    //2.创建播放器
    _player = [[AVAudioPlayer alloc] initWithData:mp3Data
                                            error:nil];
    //3.播放
    [_player play];
    
    //4.显示暂停按钮
    _playButton.hidden = YES;
    pauseButton.hidden = NO;
    
    //5.显示歌曲总时间
    NSTimeInterval duation = _player.duration;
    UILabel *rightLabel = (UILabel *)[play viewWithTag:301];
    rightLabel.text = [self convertTime:duation];
    
    //将播放的时间作为滑块的最大值
    slider.maximumValue = duation;
    slider.value = 0;
    
    //开启定时器，同步播放进度

    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(timerAction:)
                                                 userInfo:nil
                                                  repeats:YES];

}

#pragma mark - 定时器方法

- (void)timerAction:(NSTimer *)timer {
    
    //滑块动起来
    slider.value ++;
    
    //更新播放时间
    NSString *playTime = [self convertTime:slider.value];
    UILabel *timeLabel = [play viewWithTag:300];
    timeLabel.text = playTime;
    
    //判断是否播放完成，自动播放
    if (slider.value >= slider.maximumValue) {
        
        _index ++;
        // 销毁定时器
        [timer invalidate];
        if (_index < 0) {
            _index = _musicData.count-1;
        } else if (_index >= _musicData.count) {
            _index = 0;
        }
        // 加载数据
        MusicModel *dic =  _musicData[_index];
        [self loadData:dic];
        [self play:_url];
        
        // 这里调用block是因为歌手，歌名都改变了，所以FirstViewController里面也要改变
        if (_myBlock) {
            _myBlock(_singerLable, _songLable);
        }
    }
}

#pragma mark - 时间值
    //时间值
- (NSString *)convertTime:(int)t {
    
    //duation % 60 得到秒数
    //duation / 60 得到分数
    
    int s = t % 60;
    int m = t / 60;
    
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", m, s];
    
    return timeString;
}


#pragma mark - 设置背景视图
    //1.设置背景图片
- (void)_createBackgroundLogin {
    
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_homepage_default_bg.jpg"]];
    //直接拿view的尺寸就行
    //    imageView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-64);
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    
}

#pragma mark - 歌手显示栏
    //2,创建毛玻璃视图
- (void)_createBlur {
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    [imageView addSubview:blurView];
    
    //创建一个标题label
    _songLable = [[UILabel alloc] initWithFrame:CGRectMake((kWidth-180)/2, 20, 180, 30)];
    _songLable.tag = 100;
    _songLable.backgroundColor = [UIColor clearColor];
    _songLable.text = @"喜欢你";
    _songLable.textAlignment = NSTextAlignmentCenter;
//    songLable.font = [UIFont boldSystemFontOfSize:20];
    [blurView addSubview:_songLable];
    
    _singerLable = [[UILabel alloc] initWithFrame:CGRectMake((kWidth-180)/2, 50, 180, 64-50)];
    _singerLable.tag = 200;
    _singerLable.backgroundColor = [UIColor clearColor];
    _singerLable.text = @"徐佳莹";
    _singerLable.textAlignment = NSTextAlignmentCenter;
    _singerLable.font = [UIFont systemFontOfSize:10];
    [blurView addSubview:_singerLable];
    
}

#pragma mark - 显示栏返回按钮
    //3.设置返回图片按钮
- (void)_backButton {
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton"]
                          forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 20, 40, 40);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - 播放界面
    //4.创建播放界面
- (void)_createPlayBar {
    //毛玻璃效果的视图
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    play = [[UIVisualEffectView alloc] initWithEffect:blur];
    play.frame = CGRectMake(0, kHeight-150, kWidth, 150);
    [self.view addSubview:play];
    
    //播放
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"hp_player_btn_play_normal"] forState:UIControlStateNormal];
    _playButton.frame = CGRectMake((kWidth-60)/2, (150-60)/2, 60, 60);
    _playButton.tag = 102;
    _playButton.hidden = NO;
    [_playButton addTarget:self action:@selector(playsongAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:_playButton];
    

    //停止
    pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseButton setImage:[UIImage imageNamed:@"hp_player_btn_pause_normal"] forState:UIControlStateNormal];
    pauseButton.frame = CGRectMake((kWidth-60)/2, (150-60)/2, 60, 60);
    pauseButton.tag = 103;
    pauseButton.hidden = YES;
    [pauseButton addTarget:self action:@selector(playsongAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:pauseButton];
    
    //上一首
    UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lastButton setImage:[UIImage imageNamed:@"hp_player_btn_pre_normal"] forState:UIControlStateNormal];
    lastButton.frame = CGRectMake(_playButton.frame.origin.x-80, (150-40)/2, 40, 40);
    lastButton.tag = 100;
    [lastButton addTarget:self action:@selector(passAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:lastButton];
    
    //下一首
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"hp_player_btn_next_normal"] forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(_playButton.frame.origin.x+_playButton.frame.size.width+40, (150-40)/2, 40, 40);
    nextButton.tag = 101;
    [nextButton addTarget:self action:@selector(passAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:nextButton];
  
    //收藏喜欢的按钮
    UIButton *favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [favorite setImage:[UIImage imageNamed:@"player_btn_favorite_normal"] forState:UIControlStateNormal];
    [favorite setImage:[UIImage imageNamed:@"concise_icon_favorite_normal"] forState:UIControlStateSelected];
    favorite.frame = CGRectMake(kWidth/5-60, 100, 50, 50);
    [favorite addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:favorite];
    
    //循环播放
    repeat = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeat setImage:[UIImage imageNamed:@"player_btn_repeat_highlight"] forState:UIControlStateNormal];
    repeat.frame = CGRectMake(kWidth/5, 100, 50, 50);
    repeat.tag =200;
    repeat.hidden = NO;
    [repeat addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:repeat];
    
    //单曲循环
    repeatone = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeatone setImage:[UIImage imageNamed:@"player_btn_repeatone_highlight"] forState:UIControlStateNormal];
    repeatone.frame = CGRectMake(kWidth/5, 100, 50, 50);
    repeatone.tag =201;
    repeatone.hidden = YES;
    [repeatone addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:repeatone];
    
    //随机播放
    random = [UIButton buttonWithType:UIButtonTypeCustom];
    [random setImage:[UIImage imageNamed:@"player_btn_random_highlight"] forState:UIControlStateNormal];
    random.frame = CGRectMake(kWidth/5, 100, 50, 50);
    random.tag =202;
    random.hidden = YES;
    [random addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:random];
    
    //下载
    UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
    [download setImage:[UIImage imageNamed:@"player_btn_downloaded_normal_1"] forState:UIControlStateNormal];
    [download setImage:[UIImage imageNamed:@"player_btn_downloaded_normal"] forState:UIControlStateSelected];
    download.frame = CGRectMake((kWidth/5)*2, 100, 50, 50);
    [download addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:download];
    
    //分享
    UIButton *sharButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sharButton setImage:[UIImage imageNamed:@"player_btn_share_normal"] forState:UIControlStateNormal];
    sharButton.frame = CGRectMake((kWidth/5)*3, 100, 50, 50);
    [sharButton addTarget:self action:@selector(sharAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:sharButton];
    
    //列表按钮
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listButton setImage:[UIImage imageNamed:@"playing_recommend_floder_pressed"] forState:UIControlStateNormal];
    listButton.frame = CGRectMake((kWidth/5)*4, 100, 50, 50);
    [listButton addTarget:self action:@selector(listAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:listButton];
    
    
}

#pragma mark - 进度视图
    //4创建进度工具视图
- (void)_createProgressBar {
    
    //创建左边lable
    UILabel *leftLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 40, 10)];
    leftLable.text = @"00:00";
    leftLable.tag = 300;
    leftLable.textColor = [UIColor grayColor];
    leftLable.font = [UIFont systemFontOfSize:10];
//    [leftLable sizeToFit];
    [play addSubview:leftLable];
    
    //创建右边lable
    UILabel *rightLable = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-40, 30, 40, 10)];
    rightLable.text = @"00:00";
    rightLable.tag = 301;
    rightLable.textColor = [UIColor grayColor];
    rightLable.font = [UIFont systemFontOfSize:10];
//    [rightLable sizeToFit];
//    CGRect frame = rightLable.frame;
//    frame.origin.x = kWidth-(frame.size.width+20);
//    rightLable.frame = frame;
    [play addSubview:rightLable];
    
    //创建滑块
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake((leftLable.frame.size.width+20), 30, kWidth-((leftLable.frame.size.width+20)*2), 10)];

    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    
    //设置滑块图片
    [slider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    //设置左边进度条图片
    [slider setMinimumTrackImage:[UIImage imageNamed:@"player_slider_playback_left"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"player_slider_playback_right"] forState:UIControlStateNormal];
    [play addSubview:slider];
    
}

#pragma mark - UIButton Acton 点击事件
    //上一首，下一首
- (void)passAction:(UIButton *)button {
    if (button.tag == 100) {
        //上一首
        _index --;
        [_timer invalidate];
        
    } else if (button.tag == 101) {
        //下一首
        _index ++;
        [_timer invalidate];
    }
    
    if (_index < 0) {
        _index = _musicData.count-1;
    } else if (_index >= _musicData.count) {
        _index = 0;
    }
    
    MusicModel *dic =  _musicData[_index];
    [self loadData:dic];
    [self play:_url];
    
    // 这里调用block，因为我点击了下一曲，会自动播放按钮，那么FirstViewController里面也有改变播放状态
    if (_playing) {
        _playing(YES, NO);
    }
    
    
}

    //播放、暂停
- (void)playsongAction:(UIButton *)button {
    //播放

    if (button.tag == 102) {
        
        if (_firstplay == 1) {
            
            [self play:_url];
            
        }
        
        /*
         播放是隐藏，停止是显示
         */
        _playButton.hidden = YES;
        pauseButton.hidden = NO;
        
        // 这里调用block，因为我点击了播放按钮，那么FirstViewController里面也有改变状态
        if (_playing) {
            _playing(YES, NO);
        }

        //播放器播放
        [_player play];
        
        //问题原因：音乐播放到最后，再播放的话，音乐是播放了，但是滑块也没有动，左边label也没有重新显示
        if (slider.value >= slider.maximumValue) {
            
            slider.value = 0;
            //滑块要从头来
            UILabel *leftLable = [play viewWithTag:300];
            
            //左边label也要重新定位
            leftLable.text =  [self convertTime:slider.value];
            
        }
        
        if (_firstplay == 2) {
            
        //重新开始定时器
                _timer =  [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(timerAction:)
                                                         userInfo:nil
                                                          repeats:YES];
    
        }
        
        
        
    } else if (button.tag == 103) {
        _firstplay = 2;
        //暂停
        /*
         播放是显示，停止是隐藏
         */
        _playButton.hidden = NO;
        pauseButton.hidden = YES;
        
        // 这里调用block，因为我点击了播放按钮，那么FirstViewController里面也有改变状态
        if (_playing) {
            _playing(NO, YES);
        }
        
        //播放器暂停
        [_player pause];
        
        //停止定时器
        [_timer invalidate];

    }
}

    //返回事件
- (void)backAction {

    //这里真的不能停止，应该在播放小视图中加播放按钮
    
    //停止播放
//     [_player pause];
    
    //关闭当前的模态视图
    
    // 这里调用block，因为模态视图关闭，那么FirstViewController中要改变歌手和歌名
    if (_myBlock) {
        _myBlock(_singerLable, _songLable);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

    //喜欢收藏
- (void)favoriteAction:(UIButton *)button {
    button.selected = !button.selected;
}

    //播放模式
- (void)playermodelActon:(UIButton *)button {
    if (button.tag == 200) {
        //循环播放
        /*
         循环隐藏
         单曲显示
         随机隐藏
         */
        repeat.hidden = YES;
        repeatone.hidden = NO;
        random.hidden = YES;
        
        
    } if (button.tag == 201) {
        //单曲循环
        /*
         循环隐藏
         单曲隐藏
         随机显示
         */
        repeat.hidden = YES;
        repeatone.hidden = YES;
        random.hidden = NO;
        
    } if (button.tag == 202) {
        //随机
        /*
         循环显示
         单曲隐藏
         随机隐藏
         */
        repeat.hidden = NO;
        repeatone.hidden = YES;
        random.hidden = YES;
        
    }
    
}

    //下载
- (void)downloadAction:(UIButton *)button {
    button.selected = !button.selected;
    
}

    //分享
- (void)sharAction:(UIButton *)button {
    
}

    //列表
- (void)listAction:(UIButton *)button {
    
}

    //滑块时间
- (void)sliderAction:(UISlider *)s {
    
    //更新播放器的播放时间
    _player.currentTime = s.value;
    
}

#pragma mark - 默认方法
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
