//
//  LrcTableViewCell.h
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXYLrcLabel;

@interface LrcTableViewCell : UITableViewCell

@property (nonatomic, weak) LXYLrcLabel *lrcLabel;

+ (instancetype)lrcCellWithTableView:(UITableView *)talbeView;

@end
