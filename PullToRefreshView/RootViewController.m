//
//  RootViewController.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "RootViewController.h"
#import "SecondViewController.h"

CGFloat const kButtonWidth = 70.0f;
CGFloat const kButtonHeight = 40.0f;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake((CGRectGetWidth(self.view.frame) - kButtonWidth) / 2.0, (CGRectGetHeight(self.view.frame) - kButtonHeight) / 2.0, kButtonWidth, kButtonHeight);
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
