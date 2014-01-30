//
//  ViewController.m
//  OPiOSCordovaSample
//
//  Created by Aras Balali Moghaddam on 1/30/2014.
//  Copyright (c) 2014 Hookflash. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface ViewController ()
{

}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Use a normal webView
    [self useWebView];

}

- (void)useWebView
{
    // init, configure and add a webView to fill our view
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"www/index" ofType:@"html"]]]];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
