ALPullToRefresh
==============


###下拉刷新和上提更多

此版本是和demo在一起写的，可以看看demo，支持iOS5以上，用的时候只需要使用ALPullToRefreshView和相应的图片资源即可。
初始化时候需要注意参数的使用，初始化的位置可以参见demo，如果是上拉更多，需要再加入前reloadData，有关在iOS7下需要注意的地方，
在demo中已经演示了，详情可以参见demo中的SecondViewController。

###Usage:
```Objective-C:n
	_ALPullDownView = [[ALPullToRefreshView alloc] initWithFrame:CGRectMake(0, -CGRectGetHeight(_tableView.frame), CGRectGetWidth(_tableView.frame), CGRectGetHeight(_tableView.frame)) 
	  												   imageName:@"grayArrow.png" 
	  												   textColor:[UIColor blackColor] 
	  												   viewStyle:ALViewStylePullDown];
    _ALPullDownView.delegate = self;
    [_tableView addSubview:_ALPullDownView];
    
- (BOOL)ALPullToRefreshViewIsLoading:(ALPullToRefreshView *)view
{
    return _isLoading;
}

- (void)ALPullToRefreshViewDidRefresh:(ALPullToRefreshView *)view
{
    dispatch_queue_t myqueue = dispatch_queue_create("com.companyname.userqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myqueue, ^{
        _isLoading = YES;
        NSUInteger num = _dataArray.count;
        for (NSUInteger i = num; i < 10 + num; i++) {
            NSString *str = [NSString stringWithFormat:@"这是第%urow", i];
            [_dataArray addObject:str];
        }
        [NSThread sleepForTimeInterval:5];
        dispatch_async(dispatch_get_main_queue(), ^{
            _isLoading = NO;
            [_tableView reloadData];
            [_ALPullDownView ALPullToRefreshViewDidFinishLoading:_tableView];
        });
    });
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_ALPullDownView ALPullToRefreshViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_ALPullDownView ALPullToRefreshViewDidEndDrag:scrollView];
}
```
