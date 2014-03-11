//
//  RootViewController.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "RootViewController.h"
#import "SecondViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setLastLoadingTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setAMSymbol:@"上午"];
//    [formatter setPMSymbol:@"下午"];
    //[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'.000Z'"];
//    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    NSString *loadingDate = [formatter stringFromDate:[NSDate date]];
    NSLog(@"时间：%@", loadingDate);
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ALLastUpdatedTime"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setLastLoadingTime];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(50, 100, 70, 40);
    [button setTitle:@"push" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTaped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonTaped
{
    SecondViewController *_sec = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:_sec animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
