//
//  FirstViewController.m
//  qqMusic
//
//  Created by lxy on 16/4/8.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "FirstViewController.h"
#import "TowViewController.h"
#import "ThreeViewController.h"
#import "RootViewController.h"
#import "YCSlideView.h"
#import "LoginViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "MMDrawerController.h"

#define kWindowWidth  self.view.frame.size.width
#define kWindowHeight   self.view.frame.size.height

#define kWidth self.view.bounds.size.width
#define kHeight self.view.bounds.size.height




@interface FirstViewController ()

@end

@implementation FirstViewController {
    
      UIVisualEffectView *blurView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.创建顶部视图
    [self _createYCSliderView];
    
    //2,创建毛玻璃视图
    [self _createBlur];
    
    //3.创建一个图片按钮
    [self _imageButton];
    
    //4.创建导航栏左侧按钮
    [self setupLeftMenuButton];
    
    //5.创建一个播放按钮
    [self _createPlayButton];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark -YCSlideView 顶部视图
- (void)_createYCSliderView {
    
    RootViewController *rootController = [[RootViewController alloc] init];
    TowViewController *towViewContorller = [[TowViewController alloc] init];
    ThreeViewController *threeViewController = [[ThreeViewController alloc] init];
    
    NSArray *viewControllers = @[@{@"我的" : rootController}, @{@"音乐馆" : towViewContorller}, @{@"发现" : threeViewController}];
    YCSlideView *ycSliderView = [[YCSlideView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight) WithViewControllers:viewControllers];
    
    UINavigationItem *navigatoinItem = self.navigationItem;
    navigatoinItem.titleView = ycSliderView.topView;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    navigationBar.barTintColor = [UIColor colorWithRed:24/255.0 green:39/255.0 blue:57/255.0 alpha:1];
    
    [self.view addSubview:ycSliderView];
    
}

#pragma mark - MMDrawerBarButtonItem 左侧按钮
//创建导航栏左侧按钮
-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(MMDrawerController*)mm_drawerController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[MMDrawerController class]]){
            return (MMDrawerController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

#pragma mark - 播放视图
- (void)_createPlayButton {

    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-90, kHeight-64+10, 45, 45)];
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"hp_player_btn_play_normal"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.hidden = NO;
    _playBtn.tag = 102;
    [self.view addSubview:_playBtn];
    
    _pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-90, kHeight-64+10, 45, 45)];
    [_pauseButton setImage:[UIImage imageNamed:@"hp_player_btn_pause_normal"] forState:UIControlStateNormal];
    _pauseButton.hidden = YES;
    _pauseButton.tag = 103;
    [_pauseButton addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pauseButton];
  
}

// 点击播放事件
- (void)playAction:(UIButton *)btn {
    
    // 播放
    if (btn.tag == 102) {
        // 创建单例对象，要播放还要加下面那句
        LoginViewController *log = [[LoginViewController alloc] init];

        [log loadViewIfNeeded];
        _playBtn.hidden = YES;
        _pauseButton.hidden = NO;
        // 这里直接调用播放器
        [log playsongAction:btn];
        
    } else if(btn.tag == 103){
        // 暂停
        LoginViewController *log = [[LoginViewController alloc] init];
        _playBtn.hidden = NO;
        _pauseButton.hidden = YES;
        [log playsongAction:btn];
    }
}


//创建毛玻璃视图
- (void)_createBlur {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = CGRectMake(0, kHeight-64, kWidth, 64);
    [self.view addSubview:blurView];
}

//创建一个图片按钮
- (void)_imageButton {
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, kHeight-64, kWidth, 64)];
    [self.view addSubview:self.button];
    
    _songlable1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 100, 35)];
    _songlable1.text = @"See You Again";
    _songlable1.textColor = [UIColor whiteColor];
    _songlable1.font = [UIFont systemFontOfSize:10];
    _songlable1.numberOfLines = 0;
    [self.button addSubview:_songlable1];
    
    _singerLable1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 5+20, 100, 35)];
    _singerLable1.text = @"Wiz Khalifa";
    _singerLable1.textColor = [UIColor whiteColor];
    _singerLable1.font = [UIFont systemFontOfSize:10];
    _singerLable1.numberOfLines = 0;
    [self.button addSubview:_singerLable1];
    
    LoginViewController *log = [LoginViewController shareLoginViewController];
    // 接受block，用来改变歌名和歌手
    log.myBlock = ^(UILabel *singerLable, UILabel *songLable) {
        _songlable1.text = songLable.text;
        _singerLable1.text = singerLable.text;
    };
    
    // 这里的block用来改变播放的状态
    log.playing = ^(BOOL a, BOOL b) {
        _playBtn.hidden = a ;
        _pauseButton.hidden = b;
    };
    
    [self.button addTarget:self
               action:@selector(loginAction:)
     forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark 进入播放界面

- (void)loginAction:(UIButton *)button {
    
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    
    //修改动画效果
    loginVc.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
    
    //使用模态视图的方式弹出控制器
    [self presentViewController:loginVc
                       animated:YES
                     completion:^{
                         // 接受block，用来改变歌名和歌手
                         loginVc.myBlock = ^(UILabel *singerLable, UILabel *songLable) {
                             _songlable1.text = songLable.text;
                             _singerLable1.text = singerLable.text;
                         };
                         // 这里的block用来改变播放的状态
                         loginVc.playing = ^(BOOL a, BOOL b) {
                             _playBtn.hidden = a ;
                             _pauseButton.hidden = b;
                         };
                         
                     }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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
 