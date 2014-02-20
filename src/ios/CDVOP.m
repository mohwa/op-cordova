#import "CDVOP.h"

@implementation CDVOP

@synthesize webView, selfImageView, peerImageView, loginWebView, callbackId;

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
    [self configureLoginView];
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
    NSDate* expiry = [[NSDate date] dateByAddingTimeInterval:(30 * 24 * 60 * 60)];
    NSString* authorizedApplicationId = [HOPStack createAuthorizedApplicationID:arguments[0] applicationIDSharedSecret:arguments[1] expires:expiry];

    // TODO: check that authorization was successful and send error otherwise
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authorizedApplicationId];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)configureApp:(CDVInvokedUrlCommand*)command
{
    //CDVPluginResult* res = nil;
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
}

/**
 * Logout from the current account and associated identities
 */
- (void)logout:(CDVInvokedUrlCommand*)command
{
    //TODO
    NSLog(@"logging out [TODO]");
}

// TODO: remove if not needed
- (void)getAccountState:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;

    //NSArray* arguments = command.arguments;

    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"So far so good"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 Starts user login for specific identity URI.
 @param command.arguments[0] identity uri (e.g. identity://facebook.com/)
 @param command.arguments[1] outer frame url
 @param command.arguments[2] url to redirect after login is complete
 @param command.arguments[3] identity provider domain
 */
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSString* identityURI = command.arguments[0];
    NSString* outerFrameURL = command.arguments[1];
    NSString* redirectAfterLoginCompleteURL = command.arguments[2];
    NSString* identityProviderDomain = command.arguments[3];
    
    if (![[HOPAccount sharedAccount] isCoreAccountCreated] || [[HOPAccount sharedAccount] getState].state == HOPAccountStateShutdown) {
        [[HOPAccount sharedAccount] loginWithAccountDelegate:(id<HOPAccountDelegate>)[[OpenPeer sharedOpenPeer] accountDelegate] conversationThreadDelegate:(id<HOPConversationThreadDelegate>) [[OpenPeer sharedOpenPeer] conversationThreadDelegate] callDelegate:(id<HOPCallDelegate>) [[OpenPeer sharedOpenPeer] callDelegate]  namespaceGrantOuterFrameURLUponReload:outerFrameURL grantID:[[OpenPeer sharedOpenPeer] deviceId] lockboxServiceDomain:identityProviderDomain forceCreateNewLockboxAccount:NO];
        }
        
        //For identity login it is required to pass identity delegate, URL that will be requested upon successful login, identity URI and identity provider domain
        HOPIdentity* hopIdentity = [[HOPIdentity loginWithDelegate:(id<HOPIdentityDelegate>)[[OpenPeer sharedOpenPeer] identityDelegate] identityProviderDomain:identityProviderDomain] identityURIOridentityBaseURI:identityURI outerFrameURLUponReload:redirectAfterLoginCompleteURL];
        
    if (!hopIdentity) {
        NSString* error = [NSString stringWithFormat:@"Identity login has failed for uri: %@", identityURI];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    } else {
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:hopIdentity.identityId];
    }
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

@end