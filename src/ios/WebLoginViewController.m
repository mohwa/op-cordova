/*
 
 Copyright (c) 2012, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "WebLoginViewController.h"

@interface WebLoginViewController()
@property (nonatomic) BOOL outerFrameInitialised;
@end

@implementation WebLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.outerFrameInitialised = NO;
    }
    return self;
}

- (id)init
{
    self = [self initWithCoreObject:nil];
    return self;
}

- (id) initWithCoreObject:(id) inCoreObject
{
    self = [self initWithNibName:@"WebLoginViewController" bundle:nil];
    if (self)
    {
        self.coreObject = inCoreObject;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) openLoginUrl:(NSString*) url
{
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController - web request initiated by sample app. URL: %@",self,url);
    self.outerFrameInitialised = NO;
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void) passMessageToJS:(NSString*) message
{
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController \n\n Message to JS: \n %@ \n\n",self,message);
    [self.loginWebView stringByEvaluatingJavaScriptFromString:message];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    
    if ([self.coreObject isKindOfClass:[HOPIdentity class]])
    {
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\n Identity web request for URI: %@", self,[((HOPIdentity*) self.coreObject) getIdentityURI]);
    }
    else
    {
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\n Account web request: %@", self,requestString);
    }
    
    //Check if request contains JSON message for core
    if ([requestString hasPrefix:@"https://datapass.hookflash.me/?method="] || [requestString hasPrefix:@"http://datapass.hookflash.me/?method="])
    {
        
        // TODO: substitute these functions
        NSString *function = [WebLoginViewController getFunctionNameForRequest:requestString];
        NSString *params = [WebLoginViewController getParametersNameForRequest:requestString];
        
        params = [params stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if ([function length] > 0 && [params length] > 0)
        {
            NSString *functionNameSelector = [NSString stringWithFormat:@"%@:", function];
            //Execute JSON parsing in function read from requestString.
            if ([self respondsToSelector:NSSelectorFromString(functionNameSelector)])
                [self performSelector:NSSelectorFromString(functionNameSelector) withObject:params];
        }
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSString *requestString = [[[webView request] URL] absoluteString];
    
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelInsane, @"<%p> WebLoginViewController\nSTART LOADING - web request: %@", self, requestString);
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *requestString = [[[webView request] URL] absoluteString];
    NSString *namespaceGrantServiceURL = [[CDVOP sharedObject] getSetting:@"namespaceGrantServiceURL"];

    if (!self.outerFrameInitialised && [requestString isEqualToString:[[CDVOP sharedObject] getSetting:@"outerFrameURL"]])
    {
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\nFINISH LOADING - outerFrameURL: %@", self,[[CDVOP sharedObject] getSetting:@"outerFrameURL"]);
        self.outerFrameInitialised = YES;
        [self onOuterFrameLoaded];
    }
    else if (!self.outerFrameInitialised && [requestString isEqualToString:namespaceGrantServiceURL])
    {
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\nFINISH LOADING - namespaceGrantServiceURL: %@", self, namespaceGrantServiceURL);
        self.outerFrameInitialised = YES;
        [self onOuterFrameLoaded];
    }
    else
    {
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\nFINISH LOADING - NOTHING",self);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    OPLog(HOPLoggerSeverityWarning, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\nUIWebView _ERROR_ : %@",self,[error localizedDescription]);

}

- (void)notifyClient:(NSString *)message
{
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"<%p> WebLoginViewController\n\n\n Message from JS: \n %@ \n\n",self,message);
    
    if ([self.coreObject isKindOfClass:[HOPIdentity class]])
    {
        [(HOPIdentity*)self.coreObject handleMessageFromInnerBrowserWindowFrame:message];
    }
    else if ([self.coreObject isKindOfClass:[HOPAccount class]])
    {
        [(HOPAccount*)self.coreObject handleMessageFromInnerBrowserWindowFrame:message];
    }
}

- (void)onOuterFrameLoaded
{
    NSString* jsMethod = nil;
    
    if ([self.coreObject isKindOfClass:[HOPIdentity class]])
    {
        jsMethod = [NSString stringWithFormat:@"initInnerFrame(\'%@\')",[(HOPIdentity*)self.coreObject getInnerBrowserWindowFrameURL]];
    }
    else if ([self.coreObject isKindOfClass:[HOPAccount class]])
    {
        jsMethod = [NSString stringWithFormat:@"initInnerFrame(\'%@\')",[(HOPAccount*)self.coreObject getInnerBrowserWindowFrameURL]];
    }
    
    if (jsMethod)
        [self passMessageToJS:jsMethod];
}

+ (NSString*) getFunctionNameForRequest:(NSString*) requestString
{
    NSString* ret = @"";
    
    if ([requestString hasPrefix:@"https://datapass.hookflash.me/?method="])
        ret = [requestString substringFromIndex:[@"https://datapass.hookflash.me/?method=" length]];
    else if ([requestString hasPrefix:@"http://datapass.hookflash.me/?method="])
        ret = [requestString substringFromIndex:[@"http://datapass.hookflash.me/?method=" length]];
    
    NSArray *components = [ret componentsSeparatedByString:@";"];
    
    if ([components count] > 0)
        ret = [components objectAtIndex:0];
    return ret;
}

+ (NSString*) getParametersNameForRequest:(NSString*) requestString
{
    NSString* ret = @"";
    
    NSArray *components = [requestString componentsSeparatedByString:@";"];
    
    if ([components count] == 2)
    {
        
        NSString *params = (NSString*)[components objectAtIndex:1];
        if ([params hasPrefix:@"data="])
        {
            ret = [params substringFromIndex:[@"data=" length]];
        }
    }
    
    return ret;
}

@end
