//
//  ViewController.m
//  OPiOSCordovaSample
//
//  Created by Aras Balali Moghaddam on 1/29/2014.
//  Copyright (c) 2014 Hookflash. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //TODO: fix this when linking to cordova works
        //self.webController = [CDVViewController new];
        //self.webController.wwwFolderName = @"www";
        //
        NSError *error;
        self.webController = [[UIWebView alloc] init];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        NSString *htmlContent = [[NSString alloc] initWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:&error];
        [self.webController loadHTMLString:htmlContent
                             baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.view addSubview:self.webController.view];
    [self.view addSubview:self.webController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
