//
//  HZScrollView.m
//  CycleScrollView
//
//  Created by 郭凯 on 2017/2/28.
//  Copyright © 2017年 郭凯. All rights reserved.
//

#import "HZScrollView.h"
#import <UIImageView+WebCache.h>
#define kImageItemTag 101

@interface HZScrollView ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *images;  //传进来的原始数组
@property (nonatomic, strong) NSMutableArray *loadImages; //前后添加过图片的数组
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation HZScrollView

- (void)initialization {
    _currentPage = 0;
    _autoScroll = YES;
    _autoScrollTimeInterval = 3;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupScrollView];
    }
    return self;
}

////初始化加载本地图片
//- (instancetype) initWithFrame:(CGRect)frame localImages:(NSArray *)images {
//    if (self = [super initWithFrame:frame]) {
//        self.images = [NSMutableArray arrayWithArray:images];
//        [self initialization];
//        [self setupViewIsNetworkImage:NO];
//    }
//    return self;
//}
////初始化加载网络图片
//- (instancetype)initWithFrame:(CGRect)frame netWorkImages:(NSArray *)images {
//    if (self = [super initWithFrame:frame]) {
//        self.images = [NSMutableArray arrayWithArray:images];
//        [self initialization];
//        [self setupViewIsNetworkImage:YES];
//    }
//    return self;
//}
//循环滚动 前后各加一张图片
- (NSMutableArray *)loadImages {
    if (!_loadImages) {
        _loadImages = [NSMutableArray arrayWithArray:self.images];
        [_loadImages addObject:_images.firstObject];
        [_loadImages insertObject:_images.lastObject atIndex:0];
    }
    return _loadImages;
}

- (void)setImageUrlGroup:(NSArray *)imageUrlGroup {
    _imageUrlGroup = imageUrlGroup;
    self.images = [NSMutableArray arrayWithArray:_imageUrlGroup];
    [self setupViewIsNetworkImage:YES];
}

- (void)setImageLocalGroup:(NSArray *)imageLocalGroup {
    _imageLocalGroup = imageLocalGroup;
    self.images = [NSMutableArray arrayWithArray:_imageLocalGroup];
    [self setupViewIsNetworkImage:NO];
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    [_timer invalidate];
    _timer = nil;
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage%self.images.count;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval {
    _autoScrollTimeInterval = autoScrollTimeInterval;
    [self setAutoScroll:self.autoScroll];
}

- (void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)automaticScroll {
    if (self.images.count == 0) return;
    
    if (self.currentPage == 1) {
        [self.scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.scrollView.frame), 0)];
    }

    [UIView animateWithDuration:0.25 animations:^{
        if (self.currentPage == 0 && self.scrollView.contentOffset.x>CGRectGetWidth(self.scrollView.frame)) {
            [self.scrollView setContentOffset:CGPointMake((self.images.count+1)*CGRectGetWidth(self.scrollView.frame), 0)];
        }else {
            [self.scrollView setContentOffset:CGPointMake((self.currentPage+1)*CGRectGetWidth(self.scrollView.frame), 0)];
        }
        
        [self.pageControl setCurrentPage:self.currentPage++];
    }];
    
}

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    self.scrollView.delegate = self;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
    imageView.image = [UIImage imageNamed:@"AD_default.jpg"];
    [self.scrollView addSubview:imageView];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    [self addSubview:self.scrollView];
}

- (void)setupViewIsNetworkImage:(BOOL)isNetwork {
    
    for (NSInteger i = 0; i < self.loadImages.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame)*i, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
        if (isNetwork) {
            NSString *imagePath = self.loadImages[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:nil];
        }else {
            NSString *imageName = self.loadImages[i];
            imageView.image = [UIImage imageNamed:imageName];
        }
        imageView.tag = kImageItemTag+i;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)]];
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*self.loadImages.count, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-30, CGRectGetWidth(self.frame), 30)];
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.currentPage = 0;
    [self addSubview:self.pageControl];
    
}

- (void)imageTap:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    NSInteger index = (view.tag -kImageItemTag - 1)%4;
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:index];
    }
}

//拖拽滚动视图时暂停定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [_timer invalidate];
        _timer = nil;
    }
}
//启动定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //滑动到最后一张的时候改变滚动视图的偏移量
    if (scrollView.contentOffset.x == (self.loadImages.count - 1)*CGRectGetWidth(self.scrollView.frame)) {
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    }
    
    //根据偏移量计算当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    self.currentPage = (offset.x/bounds.size.width)-1;
    [self.pageControl setCurrentPage:self.currentPage];
}

//解决父视图释放 当前视图因为被定时器强引用而不能释放导致的内存泄漏问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
