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

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)loadImages {
    if (!_loadImages) {
        _loadImages = [NSMutableArray array];
    }
    return _loadImages;
}

- (void)initDataWithData:(NSArray *)arr {
    if (_images) {
        [_images removeAllObjects];
    }
    [self.images addObjectsFromArray:arr];
    
    if (_loadImages) {
        [_loadImages removeAllObjects];
        _loadImages = nil;
    }
    [self.loadImages addObjectsFromArray:arr];
    if (arr.count > 1) {
        [self.loadImages addObject:arr.firstObject];
        [self.loadImages insertObject:arr.lastObject atIndex:0];
    }else {
        self.autoScroll = NO;
    }
 
}

- (void)setImageUrlGroup:(NSArray *)imageUrlGroup {
    _imageUrlGroup = imageUrlGroup;
//    if (_images) {
//        [_images removeAllObjects];
//    }
//    [self.images addObjectsFromArray:imageUrlGroup];
// 
//    if (_loadImages) {
//        [_loadImages removeAllObjects];
//        _loadImages = nil;
//    }
//    [self.loadImages addObjectsFromArray:_images];
//    if (self.images.count > 1) {
//        [self.loadImages addObject:_images.firstObject];
//        [self.loadImages insertObject:_images.lastObject atIndex:0];
//    }else {
//        self.autoScroll = NO;
//    }
    [self initDataWithData:imageUrlGroup];
    
    [self setupViewIsNetworkImage:YES];
}

- (void)setImageLocalGroup:(NSArray *)imageLocalGroup {
    _imageLocalGroup = imageLocalGroup;
    
    [self initDataWithData:imageLocalGroup];
//    if (_images) {
//        [_images removeAllObjects];
//    }
//    [self.images addObjectsFromArray:_imageLocalGroup];
//    
//    if (_loadImages) {
//        [_loadImages removeAllObjects];
//        _loadImages = nil;
//    }
//    [self.loadImages addObjectsFromArray:_images];
//    if (self.images.count > 1) {
//        [self.loadImages addObject:_images.firstObject];
//        [self.loadImages insertObject:_images.lastObject atIndex:0];
//    }else {
//        self.autoScroll = NO;
//    }
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
    
    NSLog(@"_____%ld",self.currentPage);
//    
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
    
    if (self.images.count == 0 || self.images == nil) return;
    
    if (self.images.count == 1) {
        //如果只有一张图片
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        NSString *imagePath = _loadImages[0];
        if (isNetwork) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"AD_default.jpg"]];
        }else {
            imageView.image = [UIImage imageNamed:imagePath];
        }
        imageView.tag = kImageItemTag;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)]];
        [self.scrollView addSubview:imageView];
        return;
    }
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    for (NSInteger i = 0; i < _loadImages.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame)*i, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
        if (isNetwork) {
            NSString *imagePath = _loadImages[i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:@"AD_default.jpg"]];
        }else {
            NSString *imageName = _loadImages[i];
            imageView.image = [UIImage imageNamed:imageName];
        }
        imageView.tag = kImageItemTag+i;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)]];
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame)*_loadImages.count, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-30, CGRectGetWidth(self.frame), 30)];
    self.pageControl.numberOfPages = self.images.count;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self addSubview:self.pageControl];
    
}

- (void)imageTap:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    NSInteger index = (view.tag-kImageItemTag-1)%self.images.count;
    
    if ([self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)]) {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:index];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll && self.images.count >1) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x == (_loadImages.count - 1)*CGRectGetWidth(self.scrollView.frame)) {
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
    }
    
    if (scrollView.contentOffset.x == 0) {
        scrollView.contentOffset = CGPointMake((_loadImages.count - 2)*CGRectGetWidth(self.scrollView.frame), 0);
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    self.currentPage = (offset.x/bounds.size.width)-1;
    [self.pageControl setCurrentPage:self.currentPage];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
