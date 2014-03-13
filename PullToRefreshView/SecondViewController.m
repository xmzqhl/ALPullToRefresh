//
//  SecondViewController.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "SecondViewController.h"
#import "ALPullToRefreshView.h"

@interface SecondViewController ()<UITableViewDataSource, UITableViewDelegate, ALPullToRefreshViewDelegate>
{
    NSMutableArray *_dataArray;
    BOOL _isLoading;
    ALPullToRefreshView *_alPullDownView;
    ALPullToRefreshView *_alPullUpView;
    UITableView *_tableView;
}

@end

@implementation SecondViewController
- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < 10; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@"This is %d rows", i]];
        }
        _isLoading = NO;
    }
    return self;
}

NSInteger DeviceSystemVersion()
{
    static NSInteger version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
    });
    return version;
}
#define iOS_7 (DeviceSystemVersion() >= 7)

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (iOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    
    _alPullDownView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) imageName:@"grayArrow.png" textColor:[UIColor blackColor] viewStyle:ALPullViewStylePullDown];
    _alPullDownView.delegate = self;
    [_tableView addSubview:_alPullDownView];
    
    _alPullUpView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, _tableView.contentSize.height, CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame)) imageName:@"grayArrow.png" textColor:nil viewStyle:ALPullViewStylePullUp];
    _alPullUpView.delegate = self;
    [_tableView addSubview:_alPullUpView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - ALPullToRefreshViewDelegate
- (BOOL)ALPullToRefreshViewIsLoading:(ALPullToRefreshView *)view
{
    return _isLoading;
}

- (void)ALPullToRefreshViewDidRefresh:(ALPullToRefreshView *)view
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _isLoading = YES;
        for (NSUInteger i = _dataArray.count; i < 10 + _dataArray.count; i ++) {
            NSString *str = [NSString stringWithFormat:@"这是第%udrow", i];
            [_dataArray addObject:str];
        }
        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            _isLoading = NO;
            [_tableView reloadData];
            [_alPullDownView ALPullToRefreshViewDidFinishLoading:_tableView];
            [_alPullUpView ALPullToRefreshViewDidFinishLoading:_tableView];
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_alPullDownView ALPullToRefreshViewDidScroll:scrollView];
    
    [_alPullUpView ALPullToRefreshViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_alPullDownView ALPullToRefreshViewDidEndDrag:scrollView];
    
    [_alPullUpView ALPullToRefreshViewDidEndDrag:scrollView];
}

@end
