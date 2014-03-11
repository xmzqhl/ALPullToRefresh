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
    ALPullToRefreshView *_alRefreshView;
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
    return [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] integerValue];
}

#define iOS_7 (DeviceSystemVersion() >= 7)

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:YES];
	// Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    if (iOS_7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    [self.view addSubview:_tableView];
    
    
    _alRefreshView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, -_tableView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height) imageName:@"grayArrow.png" textColor:[UIColor blackColor]];
    _alRefreshView.delegate = self;
    [_tableView addSubview:_alRefreshView];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
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
        int num = _dataArray.count;
        for (int i = num; i < 10 + num; i ++) {
            NSString *str = [NSString stringWithFormat:@"这是第%drow", i];
            [_dataArray addObject:str];
        }
        [NSThread sleepForTimeInterval:3];
        dispatch_async(dispatch_get_main_queue(), ^{
            _isLoading = NO;
            [_alRefreshView ALPullToRefreshViewDidFinishLoading:_tableView];
            [_tableView reloadData];
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_alRefreshView ALPullToRefreshViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_alRefreshView ALPullToRefreshViewDidEndDrag:scrollView];
}


@end
