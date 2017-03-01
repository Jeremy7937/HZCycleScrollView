//
//  HZScrollView.h
//  CycleScrollView
//
//  Created by 郭凯 on 2017/2/28.
//  Copyright © 2017年 郭凯. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HZScrollView;
@protocol HZScrollViewDelegate <NSObject>

@optional
//点击图片的回调
- (void)cycleScrollView:(HZScrollView *)scrollView didSelectItemAtIndex:(NSInteger)index;

@end

@interface HZScrollView : UIView

@property (nonatomic, weak)id<HZScrollViewDelegate> delegate;
//是否自动滚动 默认YES
@property (nonatomic, assign) BOOL autoScroll;
//自动滚动间隔时间 默认3秒
@property (nonatomic, assign) CGFloat autoScrollTimeInterval;
//加载网络图片
@property (nonatomic, strong) NSArray *imageUrlGroup;
//加载本地图片
@property (nonatomic, strong) NSArray *imageLocalGroup;

////初始化加载本地图片
//- (instancetype) initWithFrame:(CGRect)frame localImages:(NSArray *)images;
////初始化加载网络图片
//- (instancetype)initWithFrame:(CGRect)frame netWorkImages:(NSArray *)images;

@end
