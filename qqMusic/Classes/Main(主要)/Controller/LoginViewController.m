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
#import "Masonry.h"
#import "CALayer+PauseAnimate.h"
#import "UIImageView+BSExtension.h"
#import "LrcView.h"
#import "LXYLrcLabel.h"
#import <MediaPlayer/MediaPlayer.h>

#define kWidth self.view.bounds.size.width
#define kHeight self.view.bounds.size.height

static LoginViewController *loginViewController = nil;

@interface LoginViewController () <UIScrollViewDelegate>

/** 旋转视图 */
@property (nonatomic, weak) UIImageView *circleView;
/** 歌词view */
@property (nonatomic, strong) LrcView *lrcView;
/** 歌词更新的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcLink;
/** 歌词label */
@property (nonatomic, strong) LXYLrcLabel *lrcLabel;
/** 上一首 */
@property (nonatomic, weak) UIButton *lastButton;
@end

@implementation LoginViewController

+ (instancetype)shareLoginViewController {

    @synchronized(self) {
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 动画
    [self startIconAnimate];
    [self.circleView.layer resumeAnimate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    // 设置歌词view
    [self _lrcView];
    
    //6.拿到音乐文件
    NSURL *url = [NSURL URLWithString:@"http://project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist"];
    NSArray *array = [NSArray arrayWithContentsOfURL:url];
    NSArray *newMusic = [MusicModel mj_objectArrayWithKeyValuesArray:array];
    
    NSRange range = NSMakeRange(0, newMusic.count);
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.musicData insertObjects:newMusic atIndexes:set];
    
    _index = 0;
    _firstplay = 1;
    MusicModel *music = self.musicData[_index];

    //8.显示歌曲的数据
    [self loadData:music];

    
}

#pragma mark - 歌词 view
- (void)_lrcView {
    self.lrcView = [[LrcView alloc] init];
    self.lrcView.backgroundColor = [UIColor clearColor];
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    self.lrcView.pagingEnabled = YES;
    self.lrcView.delegate = self;
    [self.view addSubview:self.lrcView];
    [self.lrcView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(blurView.mas_bottom);
        make.bottom.equalTo(play.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    self.lrcView.lrcLabel = self.lrcLabel;
    self.lrcView.musicData = self.musicData;
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
    //设置旋转图片
    [self.circleView setHeader:image];
    self.lrcView.lyric = music.lyric;
}


#pragma mark - 播放功能
- (void)play:(NSString *)playFile {
    
    [self removeLrcTimer];
    [self addLrcTimer];
    
    self.lrcView.index = self.index;
    self.lrcView.duration = self.player.duration;
    
    // 这里调用block是因为点击了cell，所以FirstViewController里面也要改变
    if (_myBlock) {
        _myBlock(_singerLable, _songLable);
        
        // 这里调用block，因为我点击了cell播放，那么FirstViewController里面也有改变播放状态
        if (_playing) {
            _playing(YES, NO);
        }
    }
    
    NSData *mp3Data = [NSData dataWithContentsOfURL:[NSURL URLWithString:playFile]];
    _player = [[AVAudioPlayer alloc] initWithData:mp3Data error:nil];
    [_player play];
    _playButton.hidden = YES;
    pauseButton.hidden = NO;
    NSTimeInterval duation = _player.duration;
    UILabel *rightLabel = (UILabel *)[play viewWithTag:301];
    rightLabel.text = [self convertTime:duation];
    
    //将播放的时间作为滑块的最大值
    slider.maximumValue = duation;
    slider.value = 0;

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
    slider.value ++;
    
    //更新播放时间
    NSString *playTime = [self convertTime:slider.value];
    UILabel *timeLabel = [play viewWithTag:300];
    timeLabel.text = playTime;
    
    //判断是否播放完成，自动播放
    if (slider.value >= slider.maximumValue) {
        
        _index ++;
        [timer invalidate];
        if (_index < 0) {
            _index = _musicData.count-1;
        } else if (_index >= _musicData.count) {
            _index = 0;
        }
        
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
    int s = t % 60;
    int m = t / 60;
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", m, s];
    return timeString;
}

- (void)addLrcTimer {
    self.lrcLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrc)];
    [self.lrcLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer {
    [self.lrcLink invalidate];
    self.lrcLink = nil;
}

#pragma mark - 更新歌词
- (void)updateLrc {
    self.lrcView.currentTime = self.player.currentTime;
}

#pragma mark - 设置背景视图
- (void)_createBackgroundLogin {
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_homepage_default_bg.jpg"]];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    
    // 添加毛玻璃效果
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [imageView addSubview:toolBar];
    toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    [toolBar setBarStyle:UIBarStyleBlack];
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_top);
        make.bottom.equalTo(imageView.mas_bottom);
        make.left.equalTo(imageView.mas_left);
        make.right.equalTo(imageView.mas_right);
    }];
    
    // 圆形视图
    UIImageView *circleView = [[UIImageView alloc] init];
    circleView.frame = CGRectMake(0, 0, 300, 300);
    circleView.center = self.view.center;
    [self.view addSubview:circleView];
    self.circleView = circleView;
    
    // 歌词label
    self.lrcLabel = [[LXYLrcLabel alloc] init];
    self.lrcLabel.textColor = [UIColor whiteColor];
    self.lrcLabel.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:self.lrcLabel];
    self.lrcLabel.frame = CGRectMake(0, 100, imageView.bounds.size.width, 50);
}

#pragma mark - 歌手显示栏
- (void)_createBlur {
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    [imageView addSubview:blurView];
    
    _songLable = [[UILabel alloc] initWithFrame:CGRectMake((kWidth-180)/2, 20, 180, 30)];
    _songLable.tag = 100;
    _songLable.backgroundColor = [UIColor clearColor];
    _songLable.text = @"喜欢你";
    _songLable.textAlignment = NSTextAlignmentCenter;
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
- (void)_backButton {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton"]
                          forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 20, 40, 40);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - 播放界面
- (void)_createPlayBar {
    //毛玻璃效果的视图
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    play = [[UIVisualEffectView alloc] initWithEffect:blur];
    play.frame = CGRectMake(0, kHeight-150, kWidth, 150);
    [self.view addSubview:play];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"hp_player_btn_play_normal"] forState:UIControlStateNormal];
    _playButton.frame = CGRectMake((kWidth-60)/2, (150-60)/2, 60, 60);
    _playButton.tag = 102;
    _playButton.hidden = NO;
    [_playButton addTarget:self action:@selector(playsongAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:_playButton];

    pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pauseButton setImage:[UIImage imageNamed:@"hp_player_btn_pause_normal"] forState:UIControlStateNormal];
    pauseButton.frame = CGRectMake((kWidth-60)/2, (150-60)/2, 60, 60);
    pauseButton.tag = 103;
    pauseButton.hidden = YES;
    [pauseButton addTarget:self action:@selector(playsongAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:pauseButton];
    
    // 上一首
    UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lastButton setImage:[UIImage imageNamed:@"hp_player_btn_pre_normal"] forState:UIControlStateNormal];
    lastButton.frame = CGRectMake(_playButton.frame.origin.x-80, (150-40)/2, 40, 40);
    lastButton.tag = 100;
    [lastButton addTarget:self action:@selector(passAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:lastButton];
    self.lastButton = lastButton;
    
    // 下一首
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"hp_player_btn_next_normal"] forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(_playButton.frame.origin.x+_playButton.frame.size.width+40, (150-40)/2, 40, 40);
    nextButton.tag = 101;
    [nextButton addTarget:self action:@selector(passAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:nextButton];
  
    // 收藏喜欢的按钮
    UIButton *favorite = [UIButton buttonWithType:UIButtonTypeCustom];
    [favorite setImage:[UIImage imageNamed:@"player_btn_favorite_normal"] forState:UIControlStateNormal];
    [favorite setImage:[UIImage imageNamed:@"concise_icon_favorite_normal"] forState:UIControlStateSelected];
    favorite.frame = CGRectMake(kWidth/5-60, 100, 50, 50);
    [favorite addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:favorite];
    
    // 循环播放
    repeat = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeat setImage:[UIImage imageNamed:@"player_btn_repeat_highlight"] forState:UIControlStateNormal];
    repeat.frame = CGRectMake(kWidth/5, 100, 50, 50);
    repeat.tag =200;
    repeat.hidden = NO;
    [repeat addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:repeat];
    
    // 单曲循环
    repeatone = [UIButton buttonWithType:UIButtonTypeCustom];
    [repeatone setImage:[UIImage imageNamed:@"player_btn_repeatone_highlight"] forState:UIControlStateNormal];
    repeatone.frame = CGRectMake(kWidth/5, 100, 50, 50);
    repeatone.tag =201;
    repeatone.hidden = YES;
    [repeatone addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:repeatone];
    
    // 随机播放
    random = [UIButton buttonWithType:UIButtonTypeCustom];
    [random setImage:[UIImage imageNamed:@"player_btn_random_highlight"] forState:UIControlStateNormal];
    random.frame = CGRectMake(kWidth/5, 100, 50, 50);
    random.tag =202;
    random.hidden = YES;
    [random addTarget:self action:@selector(playermodelActon:) forControlEvents:UIControlEventTouchUpInside];
    [play  addSubview:random];
    
    // 下载
    UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
    [download setImage:[UIImage imageNamed:@"player_btn_downloaded_normal_1"] forState:UIControlStateNormal];
    [download setImage:[UIImage imageNamed:@"player_btn_downloaded_normal"] forState:UIControlStateSelected];
    download.frame = CGRectMake((kWidth/5)*2, 100, 50, 50);
    [download addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:download];
    
    // 分享
    UIButton *sharButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sharButton setImage:[UIImage imageNamed:@"player_btn_share_normal"] forState:UIControlStateNormal];
    sharButton.frame = CGRectMake((kWidth/5)*3, 100, 50, 50);
    [sharButton addTarget:self action:@selector(sharAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:sharButton];
    
    // 列表按钮
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [listButton setImage:[UIImage imageNamed:@"playing_recommend_floder_pressed"] forState:UIControlStateNormal];
    listButton.frame = CGRectMake((kWidth/5)*4, 100, 50, 50);
    [listButton addTarget:self action:@selector(listAction:) forControlEvents:UIControlEventTouchUpInside];
    [play addSubview:listButton];
}

#pragma mark - 进度视图
- (void)_createProgressBar {
    UILabel *leftLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 40, 10)];
    leftLable.text = @"00:00";
    leftLable.tag = 300;
    leftLable.textColor = [UIColor whiteColor];
    leftLable.font = [UIFont systemFontOfSize:10];
    [play addSubview:leftLable];
    
    UILabel *rightLable = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-40, 30, 40, 10)];
    rightLable.text = @"00:00";
    rightLable.tag = 301;
    rightLable.textColor = [UIColor whiteColor];
    rightLable.font = [UIFont systemFontOfSize:10];
    [play addSubview:rightLable];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake((leftLable.frame.size.width+20), 30, kWidth-((leftLable.frame.size.width+20)*2), 10)];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"player_slider_playback_left"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"player_slider_playback_right"] forState:UIControlStateNormal];
    [play addSubview:slider];
    
}

#pragma mark -  播放功能 点击事件
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

- (void)playsongAction:(UIButton *)button {
    //播放

    if (button.tag == 102) {
        
        // 开启动画
        [self.circleView.layer pauseAnimate];
        [self.circleView.layer resumeAnimate];
        if (_firstplay == 1) {
            [self play:_url];
        }
        _playButton.hidden = YES;
        pauseButton.hidden = NO;
        
        // 这里调用block，因为我点击了播放按钮，那么FirstViewController里面也有改变状态
        if (_playing) {
            _playing(YES, NO);
        }
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
        _playButton.hidden = NO;
        pauseButton.hidden = YES;
        
        // 这里调用block，因为我点击了播放按钮，那么FirstViewController里面也有改变状态
        if (_playing) {
            _playing(NO, YES);
        }
        
        [_player pause];
        [_timer invalidate];

        // 暂停动画
        [self.circleView.layer pauseAnimate];
    }
    
}

#pragma mark - 旋转动画
- (void)startIconAnimate {
 
    // 1.创建基本动画
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    // 2.设置基本属性
    rotation.fromValue = @(0);
    rotation.toValue = @(M_PI * 2);
    rotation.repeatCount = NSIntegerMax;
    rotation.duration = 30;
    // 3.添加到图层上
    [self.circleView.layer addAnimation:rotation forKey:nil];
}

- (void)backAction {
    // 这里调用block，因为模态视图关闭，那么FirstViewController中要改变歌手和歌名
    if (_myBlock) {
        _myBlock(_singerLable, _songLable);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)favoriteAction:(UIButton *)button {
    button.selected = !button.selected;
}

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

- (void)downloadAction:(UIButton *)button {
    button.selected = !button.selected;
    
}

- (void)sharAction:(UIButton *)button {
    
}

- (void)listAction:(UIButton *)button {
    
}

- (void)sliderAction:(UISlider *)s {
    
    //更新播放器的播放时间
    _player.currentTime = s.value;
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取到滑动的多少
    CGPoint point = scrollView.contentOffset;
    // 计算滑动的比例
    CGFloat ratio = 1 - point.x / scrollView.bounds.size.width;
    // 设置
    self.circleView.alpha = ratio;
    self.lrcLabel.alpha = ratio;
}

#pragma mark - 监听锁屏界面事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay :
        case UIEventSubtypeRemoteControlPause :
            [self playsongAction:self.playButton];
            break;
        case UIEventSubtypeRemoteControlNextTrack :
        case UIEventSubtypeRemoteControlPreviousTrack :
            [self passAction:self.lastButton];
            break;
        default:
            break;
    }
}

#pragma mark - 默认方法
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
