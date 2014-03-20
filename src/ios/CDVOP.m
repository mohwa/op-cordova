#import "CDVOP.h"

@interface CDVOP ()
@property NSString* loginCallbackId;
@end

@implementation CDVOP

@synthesize webView, videoViews, callbackId;

static CDVOP *shared;

+ (CDVOP*)sharedObject
{
    return shared;
}

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
    self = (CDVOP*)[super initWithWebView:theWebView];
    shared = self;
    return self;
}

// called from js when webview is loaded
- (void) initialize:(CDVInvokedUrlCommand*)command {
    [self makeViewTransparent];
    [self initVideoViews];
    CDVPluginResult* res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

// make the main webview transparent
- (void) makeViewTransparent {
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.bounces = NO;
    self.webView.layer.zPosition = 100;
}

// initialize UIImageViews for self and peer video
- (void) initVideoViews {
    videoViews = [NSMutableArray array];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect selfRect = CGRectMake(120, screenRect.size.height - 200, 180, 160);
    UIImageView *selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    selfImageView.layer.zPosition = 20;
    selfImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:selfImageView];
    [videoViews addObject:selfImageView];
    
    UIImageView *peerImageView = [[UIImageView alloc] initWithFrame:screenRect];
    peerImageView.layer.zPosition = 10;
    peerImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:peerImageView];
    [videoViews addObject:peerImageView];
    NSLog(@"what have we got %@", [videoViews objectAtIndex:0]);
}

// stress test UIImageViews using a series of cat pictures
- (void) showCatPictures:(CDVInvokedUrlCommand*)command {
    UIImageView *peerImageView = [videoViews objectAtIndex:1];
    NSTimeInterval interval = [command.arguments[0] doubleValue];
    peerImageView.animationImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"www/img/cats/peer1.jpg"], [UIImage imageNamed:@"www/img/cats/peer2.jpg"], [UIImage imageNamed:@"www/img/cats/peer3.jpg"],
     [UIImage imageNamed:@"www/img/cats/peer4.jpg"], [UIImage imageNamed:@"www/img/cats/peer5.jpg"], [UIImage imageNamed:@"www/img/cats/peer6.jpg"],
     [UIImage imageNamed:@"www/img/cats/peer7.jpg"], [UIImage imageNamed:@"www/img/cats/peer8.jpg"], [UIImage imageNamed:@"www/img/cats/peer9.jpg"],
     [UIImage imageNamed:@"www/img/cats/peer10.jpg"], nil];
    peerImageView.animationDuration = interval;
    [peerImageView startAnimating];

    // load pictures and start animating
    NSLog(@"displaying cat pictures");
    UIImageView *selfImageView = [videoViews objectAtIndex:0];
    selfImageView.animationImages = [NSArray arrayWithObjects:
      [UIImage imageNamed:@"www/img/cats/self1.jpg"], [UIImage imageNamed:@"www/img/cats/self2.jpg"], [UIImage imageNamed:@"www/img/cats/self3.jpg"],
      [UIImage imageNamed:@"www/img/cats/self4.jpg"], [UIImage imageNamed:@"www/img/cats/self5.jpg"], [UIImage imageNamed:@"www/img/cats/self6.jpg"], [UIImage imageNamed:@"www/img/cats/self7.jpg"], [UIImage imageNamed:@"www/img/cats/self8.jpg"],
      [UIImage imageNamed:@"www/img/cats/self9.jpg"], [UIImage imageNamed:@"www/img/cats/self10.jpg"], nil];
    selfImageView.animationDuration = interval;
    [selfImageView startAnimating];
}

- (void)stopCatPictures:(CDVInvokedUrlCommand*)command {
    for (NSUInteger index = 0; index < videoViews.count; index++) {
        [[videoViews objectAtIndex:index] stopAnimating];
    }
    [self initVideoViews];
    [self connectVideoViews];
}

/**
 * configure video imageview
 * [0:index, // 0 is self video 1 (and up) are for peer video(s)
 *  1:left, 2:top, 3:width, 4:height, 5:zindex,
 *  6:contentMode, 7:scale, 8:opacity, 9:cornerRadius, 10:angle]
 */
- (void) configureVideo:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;

    @try {
        UIImageView *videoView = [videoViews objectAtIndex:[arguments[0] floatValue]];
        CGRect rect = CGRectMake([arguments[1] floatValue], [arguments[2] floatValue],
                                 [arguments[3] floatValue], [arguments[4] floatValue]);
        videoView.frame = rect;
        
        videoView.layer.zPosition = [arguments[5] floatValue];
        
        videoView.contentMode = [self getContentMode:arguments[6]];
        
        videoView.contentScaleFactor = [arguments[7] floatValue];
        
        videoView.layer.opacity = [arguments[8] floatValue];
        
        videoView.layer.cornerRadius = [arguments[9] floatValue];
        
        videoView.transform = CGAffineTransformMakeRotation([arguments[10] floatValue]);
        
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    } @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"Error updating self video properties: %@", exception];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void) authorizeApp:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;
    NSString* authorizedApplicationId = [[HOPSettings sharedSettings] getAuthorizedApplicationId];
    
    //If authorized application id is missing, generate it
    if ([authorizedApplicationId length] == 0) {
        NSDate* expiry = [[NSDate date] dateByAddingTimeInterval:(30 * 24 * 60 * 60)];
        authorizedApplicationId = [HOPStack createAuthorizedApplicationID:arguments[0] applicationIDSharedSecret:arguments[1] expires:expiry];
        [[HOPSettings sharedSettings] storeAuthorizedApplicationId:authorizedApplicationId];
    }
    
    // send the authorized application id to client
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/authorizated-application-id" value:[[HOPSettings sharedSettings] getAuthorizedApplicationId]];

    // TODO: check that authorization was successful and send error otherwise
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authorizedApplicationId];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
    
    // initialize and setup HOP Stack
    [[OpenPeer sharedOpenPeer] setup];
}

/*
 * connect video views to their video streams comming from SDK
 * precondition: UIImageViews have been initialized and added to videoViews
 */
- (void) connectVideoViews
{
    //Set default video orientation to be portrait
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Hook up UI images for self video preview and peer video
    [[HOPMediaEngine sharedInstance] setCaptureRenderView:[videoViews objectAtIndex:0]];
    [[HOPMediaEngine sharedInstance] setChannelRenderView:[videoViews objectAtIndex:1]];
}

// TODO: remove if not needed
- (void)getAccountState:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSString* state;

    if([[HOPAccount sharedAccount] isCoreAccountCreated]) {
        state = [HOPAccount stringForAccountState:[[HOPAccount sharedAccount] getState].state];
    } else {
        state = @"NotCreated";
    }
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:state];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * Starts user login for specific identity URI.
 */
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command
{
    self.loginCallbackId = command.callbackId;
    //[self.commandDelegate runInBackground:^{
        NSLog(@"Starting the login process");
        [[LoginManager sharedLoginManager] login];
    //}];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    NSLog(@"logging out");
    CDVPluginResult* res = nil;
    
    //TODO
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * read setting from JavaScript settings object and return it as NSString*
 */
- (NSString*) getSetting:(NSString*)setting
{
    NSString *jsCall = [NSString stringWithFormat:@"OP.settings['%@'];", setting];
    return [self.webView stringByEvaluatingJavaScriptFromString:jsCall];
}

/*
 * set setting[key] to value
 */
- (void) setSetting:(NSString*)key value:(NSString*)value {
    NSString *jsCall = [NSString stringWithFormat:@"OP.settings['%@'] = '%@';", key, value];
    [self.webView stringByEvaluatingJavaScriptFromString:jsCall];
}

/**
 * read setting from JavaScript settings object and return it as BOOL
 */
- (BOOL) getSettingAsBool:(NSString*)setting {
    NSString *str = [self getSetting:setting];
    return [str boolValue];
}

- (NSString*) getAllSettingsJSON
{
    NSString *settings = [self.webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(OP.settings);"];
    return [NSString stringWithFormat:@"{\"root\":%@}", settings];
}

/**
 Show web view with opened login page.
 @param url NSString Login page url.
 */
- (void) showWebLoginView:(WebLoginViewController*) webLoginViewController
{
    if (webLoginViewController)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        //testing, TODO: remove or extract out the padding
        CGRect rect = CGRectMake(50, 50, screenRect.size.width - 100, screenRect.size.height - 100);
        
        //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Show WebLoginViewController <%p>",webLoginViewController);
        NSLog(@"Show WebLoginViewController <%p>",webLoginViewController);
        webLoginViewController.view.frame = rect;
        webLoginViewController.view.hidden = NO;
        webLoginViewController.view.layer.zPosition = 500;
        webLoginViewController.view.backgroundColor = [UIColor clearColor];
        [webLoginViewController.view setAlpha:0];
        
        [UIView animateWithDuration:1 animations:^
         {
             [webLoginViewController.view setAlpha:1];
             [self.webView.superview addSubview:webLoginViewController.view];
         }
                         completion:nil];
    }
}

- (void) onIdentityLoginWebViewClose:(WebLoginViewController*) webLoginViewController forIdentityURI:(NSString*) identityURI
{
    //TODO: tell JS login that we receive identity for identity URI
    NSLog(@"Got Login identity: %@",identityURI);

    [self closeWebLoginView:webLoginViewController];
}

- (void) onAccountLoginWebViewClose:(WebLoginViewController *)webLoginViewController {
    [self closeWebLoginView:webLoginViewController];
}

- (void) closeWebLoginView:(WebLoginViewController*) webLoginViewController
{
    if (webLoginViewController)
    {
        //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Close WebLoginViewController <%p>",webLoginViewController);
        NSLog(@"Close WebLoginViewController <%p>",webLoginViewController);
        
        [UIView animateWithDuration:1 animations:^
         {
             [webLoginViewController.view setAlpha:0];
         }
                         completion:^(BOOL finished)
         {
             [webLoginViewController.view removeFromSuperview];
         }];
    }
}

- (void) onLoginWebViewVisible:(WebLoginViewController*) webLoginViewController {
    //TODO: tell client login webview is about to show
    
    if (!webLoginViewController.view.superview)
        [self showWebLoginView:webLoginViewController];
}

- (void) onStartLoginWithidentityURI {
    //TODO update client
}

- (void) onOpeningLoginPage {
    //TODO
}

- (void) onRelogin {
    //TODO update client
}

- (void) onIdentityLoginFinished {
    NSLog(@"*********** Identity Login finished ************");
    CDVPluginResult* res = nil;
    NSString* message = @"Login finished successfully";
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:res callbackId:self.loginCallbackId];
}

- (void) onLoginFinished {
    //TODO
    NSLog(@"*********** Login finished ************");
}

- (void) onIdentityLoginShutdown {
    //TODO
    NSLog(@"Login shutdown");
}

- (void) onIdentityLoginError:(NSString *)error {
    //TODO
    NSLog(@"Account login error: %@",error);
}

- (void) onAccountLoginError:(NSString*) error {
    //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Account login error: %@",error);
    NSLog(@"Account login error: %@", error);
    //TODO: send error to client
}

- (UIViewContentMode) getContentMode:(NSString*)mode {
    UIViewContentMode retMode = UIViewContentModeScaleAspectFill;
    if ([mode isEqualToString:@"bottom"]) {
        retMode = UIViewContentModeBottom;
    } else if ([mode isEqualToString:@"bottomLeft"]) {
        retMode = UIViewContentModeBottomLeft;
    } else if ([mode isEqualToString:@"bottomRight"]) {
        retMode = UIViewContentModeBottomRight;
    } else if ([mode isEqualToString:@"center"]) {
        retMode = UIViewContentModeCenter;
    } else if ([mode isEqualToString:@"left"]) {
        retMode = UIViewContentModeLeft;
    } else if ([mode isEqualToString:@"redraw"]) {
        retMode = UIViewContentModeRedraw;
    } else if ([mode isEqualToString:@"right"]) {
        retMode = UIViewContentModeRight;
    } else if ([mode isEqualToString:@"scaleAspectFill"]) {
        retMode = UIViewContentModeScaleAspectFill;
    } else if ([mode isEqualToString:@"scaleAspectFit"]) {
        retMode = UIViewContentModeScaleAspectFit;
    } else if ([mode isEqualToString:@"scaleToFill"]) {
        retMode = UIViewContentModeScaleToFill;
    } else if ([mode isEqualToString:@"top"]) {
        retMode = UIViewContentModeTop;
    } else if ([mode isEqualToString:@"topLeft"]) {
        retMode = UIViewContentModeTopLeft;
    } else if ([mode isEqualToString:@"topRight"]) {
        retMode = UIViewContentModeTopRight;
    }
    return retMode;
}

@end
