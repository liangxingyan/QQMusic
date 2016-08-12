//
//  LrcView.m
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LrcView.h"
#import "Masonry.h"
#import "LyricTool.h"
#import "LXYLrc.h"
#import "Masonry.h"
#import "LrcTableViewCell.h"
#import "LXYLrcLabel.h"
#import "MusicModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LrcView () <UITableViewDataSource>

/** 表视图 */
@property (nonatomic, weak) UITableView *tableView;
/** 歌词 */
@property (nonatomic, strong) NSArray *lyrices;
/** 当前播放的下标值 */
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation LrcView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupTableView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupTableView];
    }
    return self;
}

- (void)setupTableView {
 
    // 创建tableview
    UITableView *tableView = [[UITableView alloc] init];
    [self addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 40;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = self;
    self.tableView = tableView;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(self.mas_height);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.right.equalTo(self.mas_right);
        make.width.equalTo(self.mas_width);
    }];
    
    // 设置tableview的多出的区域
    self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return self.lyrices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LrcTableViewCell *cell = [LrcTableViewCell lrcCellWithTableView:tableView];
    
    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:15];
    } else {
        cell.lrcLabel.font = [UIFont systemFontOfSize:12];
        cell.lrcLabel.progress = 0;
    }
    
    LXYLrc *lrc = self.lyrices[indexPath.row];
    cell.lrcLabel.text = lrc.content;
    return cell;

}

#pragma mark - 重写set方法
- (void)setLyric:(NSString *)lyric {
    
    // 下一首歌不会出现上一首歌的残留下标
    self.currentIndex = 0;
    
    // 下一首歌不会出现上一首歌的残留歌词
    self.lrcLabel.text = @"";
    
    _lyric = lyric;
    
    // 解析歌词
    self.lyrices = [LyricTool lyricToolWithLrcname:lyric];
    
    // 刷新表格
    [self.tableView reloadData];
    
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    
    NSInteger count = self.lyrices.count;
    for (int i = 0; i < count; i++) {
        LXYLrc *currentLrc = self.lyrices[i];
        NSInteger next = i + 1;
        LXYLrc *nextLrc = nil;
        if (next < count) {
            nextLrc = self.lyrices[next];
        }
        
        if (self.currentIndex != i && currentTime >= currentLrc.time && currentTime < nextLrc.time) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            // 上一个
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            self.currentIndex = i;
            // 刷新
            [self.tableView reloadRowsAtIndexPaths:@[indexPath, previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            // 滚动
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // 设置外面歌词的label
            self.lrcLabel.text = currentLrc.content;

            // 生成锁屏界面的歌词
            [self generatorLockImage];
            
        }
        
        // 根据速度，显示label画多少
        if (self.currentIndex == i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            LrcTableViewCell *cell = (LrcTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            
            // 更新label的进度
            CGFloat progress = (currentTime - currentLrc.time) / (nextLrc.time - currentLrc.time);
            cell.lrcLabel.progress = progress;
            
            // 设置外面的歌词进度
            self.lrcLabel.progress = progress;
        }
    }
    
}

#pragma mark - 生成锁屏界面的图片
- (void)generatorLockImage {
    // 拿到当前播放歌曲的图片
    MusicModel *musicData = self.musicData[self.index];
    NSURL *url = [NSURL URLWithString:musicData.picUrl];
    UIImage *currentImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    NSLog(@"%@", musicData.name);
    NSLog(@"%@", currentImage);
    
    // 拿到三句歌词
    LXYLrc *currentLrc = self.lyrices[self.currentIndex];
    NSInteger previousIndex = self.currentIndex - 1;
    LXYLrc *previousLrc = nil;
    if (previousIndex >= 0) {
        previousLrc = self.lyrices[previousIndex];
    }
    NSInteger nextIndex = self.currentIndex + 1;
    LXYLrc *nextLrc = nil;
    if (nextIndex < self.lyrices.count) {
        nextLrc = self.lyrices[nextIndex];
    }
    
    // 生成水印图片
    // 图形上下文
    UIGraphicsBeginImageContext(currentImage.size);
    // 画图片
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    // 画文字
    CGFloat titleH = 25;
    // 设置文字居中
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributesDic1 = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:14],
                                     NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                     NSParagraphStyleAttributeName : style
                                     };
    [previousLrc.content drawInRect:CGRectMake(0, currentImage.size.height - 3 * titleH, currentImage.size.width, titleH) withAttributes:attributesDic1];
    [nextLrc.content drawInRect:CGRectMake(0, currentImage.size.height - titleH, currentImage.size.width, titleH) withAttributes:attributesDic1];
    NSDictionary *attributesDic2 = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:17],
                                     NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSParagraphStyleAttributeName : style
                                    };
    [currentLrc.content drawInRect:CGRectMake(0, currentImage.size.height - 2 * titleH, currentImage.size.width, titleH) withAttributes:attributesDic2];
    // 生成图片
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setupLockScreenInfoWithLockImage:lockImage];
}

#pragma mark - 设置锁屏界面的信息
- (void)setupLockScreenInfoWithLockImage:(UIImage *)lockImage {
    
    // 获取当前正在播放的歌曲
    MusicModel *music = self.musicData[_index];
    
    // 获取锁屏界面中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:music.name forKey:MPMediaItemPropertyAlbumTitle]; // 歌名
    [playingInfo setObject:music.singer forKey:MPMediaItemPropertyArtist]; // 歌手
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork]; // 歌词居中
    [playingInfo setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration]; // 歌曲总时间
    [playingInfo setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; // 当前时间
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 可以让应用程序接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
}


@end
