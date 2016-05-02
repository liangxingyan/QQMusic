//
//  YCSlideView.h
//  youzer
//
//  Created by 王禹丞 on 15/12/16.
//  Copyright © 2015年 QXSX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCSlideView : UIView

@property (nonatomic,strong)NSArray * vcArray;

@property (nonatomic,strong) UIScrollView * bottomScrollView;

@property (nonatomic,strong) UIView * topView;

@property (nonatomic,strong) UIScrollView * topScrollView;

@property (nonatomic,strong) UIView * slideView;

@property (nonatomic,strong) NSMutableArray * btnArray;

- (instancetype)initWithFrame:(CGRect)frame WithViewControllers:(NSArray *)viewControllers;



@end
