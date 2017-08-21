//
//  ViewController.m
//  RHLANClient
//
//  Created by zhuruhong on 2017/8/21.
//  Copyright © 2017年 zhuruhong. All rights reserved.
//

#import "ViewController.h"
#import "RHLANClient.h"

@interface ViewController ()

@property (nonatomic, strong, retain) UIButton *serviceTestButton;

@property (nonatomic, strong) RHLANClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _serviceTestButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _serviceTestButton.frame = CGRectMake(20, 120, 250, 40);
    _serviceTestButton.layer.borderColor = [UIColor blackColor].CGColor;
    _serviceTestButton.layer.borderWidth = 0.5;
    _serviceTestButton.layer.masksToBounds = YES;
    [_serviceTestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_serviceTestButton setTitle:@"Test udp socket" forState:UIControlStateNormal];
    [_serviceTestButton addTarget:self action:@selector(doTestServiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_serviceTestButton];
    
    //
    _client = [[RHLANClient alloc] init];
    [_client startUdpClient];
    
}

- (void)doTestServiceButtonAction
{
    NSString *msg = @"1234";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [_client sendData:data];
}

@end
