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

- (void) makeViewTransparent {
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.bounces = NO;
    self.webView.layer.zPosition = 100;
}

// initialize UIImageView for self and peer video
- (void) initVideoViews {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    peerImageView = [[UIImageView alloc] initWithFrame:screenRect];
    peerImageView.layer.zPosition = 10;
    [self.webView.superview addSubview:peerImageView];

    CGRect selfRect = CGRectMake(120, screenRect.size.height - 200, 180, 160);
    selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    selfImageView.layer.zPosition = 20;
    [self.webView.superview addSubview:selfImageView];
}

// stress test UIImageViews using a series of cat pictures
- (void) showCatPictures:(CDVInvokedUrlCommand*)command {
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
    selfImageView.animationImages = [NSArray arrayWithObjects:
      [UIImage imageNamed:@"www/img/cats/self1.jpg"], [UIImage imageNamed:@"www/img/cats/self2.jpg"], [UIImage imageNamed:@"www/img/cats/self3.jpg"],
      [UIImage imageNamed:@"www/img/cats/self4.jpg"], [UIImage imageNamed:@"www/img/cats/self5.jpg"], [UIImage imageNamed:@"www/img/cats/self6.jpg"], [UIImage imageNamed:@"www/img/cats/self7.jpg"], [UIImage imageNamed:@"www/img/cats/self8.jpg"],
      [UIImage imageNamed:@"www/img/cats/self9.jpg"], [UIImage imageNamed:@"www/img/cats/self10.jpg"], nil];
    selfImageView.animationDuration = interval;
    [selfImageView startAnimating];

    //[self makeViewTransparent];
}

- (void)stopCatPictures:(CDVInvokedUrlCommand*)command {
    [selfImageView stopAnimating];
    [peerImageView stopAnimating];
}

/* configure self video image view with the following:
 * [top, left, width, height, zindex, scale, opacity, cornerRadius, angle]
 */
- (void)configureSelfVideo:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;
    CGRect rect = CGRectMake([arguments[0] floatValue], [arguments[1] floatValue],
                             [arguments[2] floatValue], [arguments[3] floatValue]);
    @try {
        selfImageView.frame = rect;
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    }
    @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"Error updating self video properties: %@", exception];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
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

@end
