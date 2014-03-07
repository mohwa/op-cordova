#import "CDVOP.h"

@interface CDVOP ()
@property NSString* loginCallbackId;
@end

@implementation CDVOP

@synthesize webView, selfImageView, peerImageView, callbackId;

static CDVOP *shared;

+ (CDVOP*)sharedObject
{
    return shared;
}

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (CDVOP*)[super initWithWebView:theWebView];
    NSLog(@">>> initializing with cordova webView <<<");
    
    // configure the cordova webview
    theWebView.opaque = NO;
    theWebView.backgroundColor = [UIColor clearColor];
    theWebView.scrollView.bounces = NO;
    theWebView.layer.zPosition = 100;
    
    [self configureVideos];
    //[self configureLoginView];
    
    shared = self;
    return self;
}

// stress test UIImageViews using a series of cat pictures
- (void)showCatPictures:(CDVInvokedUrlCommand*)command
{
    NSTimeInterval interval = [command.arguments[0] doubleValue];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    peerImageView = [[UIImageView alloc] initWithFrame:screenRect];
    peerImageView.layer.zPosition = 10;
    [webView.superview addSubview:peerImageView];
    peerImageView.animationImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"11.JPG"], [UIImage imageNamed:@"22.JPG"], [UIImage imageNamed:@"33.JPG"],
     [UIImage imageNamed:@"44.JPG"], [UIImage imageNamed:@"55.JPG"], [UIImage imageNamed:@"66.JPG"],
     [UIImage imageNamed:@"77.JPG"], [UIImage imageNamed:@"88.JPG"], [UIImage imageNamed:@"99.JPG"],
     [UIImage imageNamed:@"1010.JPG"], [UIImage imageNamed:@"1111.JPG"], nil];
    peerImageView.animationDuration = interval;
    [peerImageView startAnimating];
    
    //initialize and configure self image view which normally would come from front facing cam1
    CGRect selfRect = CGRectMake(120, screenRect.size.height - 200, 180, 160);
    selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    selfImageView.layer.zPosition = 20;
    [webView.superview addSubview:selfImageView];
    // load pictures and start animating
    NSLog(@"displaying cat pictures");
    selfImageView.animationImages = [NSArray arrayWithObjects:
      [UIImage imageNamed:@"1.JPG"], [UIImage imageNamed:@"2.JPG"], [UIImage imageNamed:@"3.JPG"],
      [UIImage imageNamed:@"4.JPG"], [UIImage imageNamed:@"5.JPG"], [UIImage imageNamed:@"6.JPG"], nil];
    selfImageView.animationDuration = interval;
    [selfImageView startAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"web view did start to load...");
}

- (void)authorizeApp:(CDVInvokedUrlCommand*)command
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

- (void)configureApp:(CDVInvokedUrlCommand*)command
{
    //CDVPluginResult* res = nil;w
    //NSArray* arguments = command.arguments;
    //TODO
}

// Connect video streams to their native UI elements
- (void)configureVideos
{
    CGRect rect = CGRectMake(0, 0, 100.0, 200.0);

    self.selfImageView = [[UIImageView alloc] initWithFrame:rect];
    //self.selfImageView.layer.cornerRadius = 5;
    //self.selfImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:self.selfImageView];
    
    //Set default video orientation to be portrait
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Hook up UI images for self video preview and peer video
    [[HOPMediaEngine sharedInstance] setCaptureRenderView:self.selfImageView];
    [[HOPMediaEngine sharedInstance] setChannelRenderView:self.peerImageView];
    
    self.selfImageView.hidden = NO;
    NSLog(@"video config done.");
}

/*
- (void)configureLoginView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect rect = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.loginWebView = [[UIWebView alloc] initWithFrame:rect];
    [self.webView.superview addSubview:self.loginWebView];
    loginWebView.opaque = NO;
    loginWebView.backgroundColor = [UIColor clearColor];
    loginWebView.layer.zPosition = 1000;
    NSLog(@"login view config done.");
}*/

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
    NSLog(@"Starting the login process");
    //CDVPluginResult* res = nil;
    [[LoginManager sharedLoginManager] login];
     
    // TODO: figure out a way to asynchronously update client when login finished
    self.loginCallbackId = command.callbackId;
    //[self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
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
        //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Show WebLoginViewController <%p>",webLoginViewController);
        NSLog(@"Show WebLoginViewController <%p>",webLoginViewController);
        webLoginViewController.view.frame = self.webView.superview.bounds;
        webLoginViewController.view.hidden = NO;
        webLoginViewController.view.layer.zPosition = 500;
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

- (void) onAccountLoginError:(NSString*) error {
    //OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Account login error: %@",error);
    NSLog(@"Account login error: %@", error);
    //TODO: send error to client
}

@end
