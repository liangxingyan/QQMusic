//
//  FirstViewController.h
//  qqMusic
//
//  Created by lxy on 16/4/8.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface FirstViewController : UIViewController
    
 

@property (nonatomic, strong) UIButton *button;
    
// 暂停
@property (nonatomic, strong) UIButton *pauseButton;
    
// 歌手
@property (nonatomic, strong) UILabel *singerLable1;
    
 // 歌名
@property (nonatomic, strong) UILabel *songlable1;
    

// 播放
@property (nonatomic, strong) UIButton *playBtn;


//- (void)setSonglabel:(NSString *)songlable withSetSingerLabel:(NSString *)singerLable;

@end
