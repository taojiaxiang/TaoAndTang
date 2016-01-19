//
//  ViewController.m
//  TaoAndTang
//
//  Created by qianfeng on 16/1/18.
//  Copyright © 2016年 TAO. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#define HeaderScrollUrl @"http://v2.ysjk.189read.com/api/V1/audio/getbannerv2.json?pno=20000001&sign=C633F9A33367C0B7787BA3337EFAE033&ztype=99&tabclass=3&userkey=ts_iphonev2&Ruid=210000205822583&UserName=61B3179BF33E5747A4B0B4D8A46AF59A&ver=TYYDYSB_I2.3.9.8&dateTime=20160118104151&Uid=69170253&ScreenHeight=1136&ScreenWidth=640"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate>
{
    NSMutableArray *_HeadSvdataArray;
}
@property (nonatomic,strong)UIScrollView *mainView;
@property (nonatomic,strong)AFHTTPRequestOperationManager *manager;
@property (nonatomic,strong)UIScrollView *sv;
@property (nonatomic,strong)UITableView *tv;
@property (nonatomic,strong)UIPageControl *pageControl;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createBtn];
    [self createMainScrollView];
    [self createHeaderScroll];

    [self requestHeaderScroll];
    [self createPageControl];
}

- (void)createAudioPlayer
{
    
}

- (void)createHeaderScroll
{
    _sv = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 150)];
    _sv.contentSize = CGSizeMake(WIDTH*6, 150);
    _sv.directionalLockEnabled = YES;
    _sv.backgroundColor = [UIColor greenColor];
    _sv.delegate = self;
    _sv.pagingEnabled = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _sv.userInteractionEnabled = YES;
    _sv.bounces = NO;
    
    [_mainView addSubview:_sv];
}

//
- (void)requestHeaderScroll
{
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:HeaderScrollUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *dic2 = [dic objectForKey:@"topicList"];
        _HeadSvdataArray = [dic2 objectForKey:@"topics"];
        for (int i =0; i<_HeadSvdataArray.count; i++) {
            
            UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(i *WIDTH, 0, WIDTH, 150)];
        
            NSDictionary *dictionary = [_HeadSvdataArray objectAtIndex:i];
            NSURL *url = [NSURL URLWithString:[dictionary objectForKey:@"cover"]];
            [imgV sd_setImageWithURL:url];
            [_sv addSubview:imgV];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
}
//头Button
- (void)createBtn
{
    for (int i = 0; i<4; i++) {
        NSArray * titles = @[@"发现",@"榜单",@"分类",@"专题"];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/4 *i, 64, WIDTH/4, 40)];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor redColor];
        [self.view addSubview:btn];
        [btn setTitleColor:[UIColor purpleColor] forState:UIControlStateSelected];
        if (btn.tag == 100) {
            
            btn.selected = YES;
        }
    }
}
//Button 点击方法
- (void)btnClick:(UIButton *)sender
{
    //NSInteger btnTag = (NSInteger)(_mainView.contentOffset.x/[UIScreen mainScreen].bounds.size.width);
    
    UIButton * btn = (UIButton *)sender;
    for (int i = 0; i < 4; i++) {
        
        if (100+i == btn.tag) {
            
            btn.selected ^= 1;
            
            //_mainView.contentOffset.x = [UIScreen mainScreen].bounds.size.width
            CGPoint point = CGPointMake(i * [UIScreen mainScreen].bounds.size.width, 0);
            
            [_mainView setContentOffset:point animated:YES];
            
            
        }else {
            
            UIButton * btn1 = (UIButton *)[self.view viewWithTag:100 + i];
            btn1.selected = NO;
        }
    }
}
//主ScrollView
- (void)createMainScrollView
{
    _mainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40+64, WIDTH, HEIGHT-40-64-49)];
    _mainView.contentSize = CGSizeMake(WIDTH*4, HEIGHT-40-64-49);
    _mainView.delegate = self;
    _mainView.bounces = NO;
    _mainView.pagingEnabled = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    _mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mainView];
}
//_sv 上部ScrollView PageControl
- (void)createPageControl
{
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 150, WIDTH, 20)];
    
    _pageControl.numberOfPages = 6;
    
    _pageControl.backgroundColor = [UIColor grayColor];
    
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    [_pageControl addTarget:self action:@selector(changeCurrentPage:) forControlEvents:UIControlEventValueChanged];
    
    [self.mainView addSubview:_pageControl];
}
//PageControl 点
- (void)changeCurrentPage:(UIPageControl *)pageControl
{
    CGPoint point = CGPointMake(pageControl.currentPage * [UIScreen mainScreen].bounds.size.width, 0);
    
    [_sv setContentOffset:point animated:YES];
}

#pragma mark -- scrollView 代理方法

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
 
    //通过scrollView当前显示的位置 可以得出滑动了几个屏幕宽 一个屏幕宽就是一页
    if ([scrollView isKindOfClass:[UITableView class]]) {
        NSLog(@"------是列表---");
    }
    else {
        NSLog(@"------是滚动试图----");
    }
    //头ScrollView 滚动
    if (scrollView == _sv) {
        
        _pageControl.currentPage = (NSInteger)(_sv.contentOffset.x/[UIScreen mainScreen].bounds.size.width);
        NSLog(@"%ld",_pageControl.currentPage);
        //_pageControl.center = CGPointMake(SCREEN_W/2, SCREEN_H/2.5-10-scrollView.contentOffset.y);
        
        NSLog(@"%f---%f",_pageControl.currentPage * WIDTH/2, HEIGHT/2.5-10);
    }
    //主ScrollView 滚动
    if (scrollView == _mainView) {
        
        NSInteger btnTag = (NSInteger)(_mainView.contentOffset.x/[UIScreen mainScreen].bounds.size.width);
        
        for (int i = 0; i<4; i++) {
            
            UIButton *btn = (UIButton *)[self.view viewWithTag:100 + i];
        
            if (btn.tag - 100 == btnTag) {
                
                btn.selected = YES;
            }
            else
            {
                btn.selected = NO;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
