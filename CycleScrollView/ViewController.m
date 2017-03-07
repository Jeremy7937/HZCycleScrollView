//
//  ViewController.m
//  CycleScrollView
//
//  Created by 郭凯 on 2017/2/14.
//  Copyright © 2017年 郭凯. All rights reserved.
//

#import "ViewController.h"
#import "HZScrollView.h"
#define kScreenSize [UIScreen mainScreen].bounds.size

@interface ViewController ()<UIScrollViewDelegate,HZScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    NSArray *imageArr = @[@"h1.jpg",@"h2.jpg",@"h3.jpg",@"h4"];
    NSArray *imageArr = @[@"h1.jpg"];
//    NSArray *imageArr = nil;
    HZScrollView *scrollView = [[HZScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, 200)];
    scrollView.delegate = self;
    scrollView.autoScrollTimeInterval = 3;
    scrollView.autoScroll = YES;
    scrollView.imageLocalGroup = imageArr;
    [self.view addSubview:scrollView];
}

- (void)cycleScrollView:(HZScrollView *)scrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"点击了第%ld张",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
