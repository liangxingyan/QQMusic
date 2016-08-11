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

@end
