#import "CDVOP.h"
//#import <Cordova/CDV.h>

@implementation CDVOP

@synthesize webView, selfImageView, peerImageView, callbackId;

-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (CDVOP*)[super initWithWebView:theWebView];
    NSLog(@">>> initializing with cordova webView <<<");
    
    // configure the cordova webview
    theWebView.opaque = NO;
    theWebView.backgroundColor = [UIColor clearColor];
    
    [self configureVideos];
    return self;
}

// stress test UIImageViews using a series of cat pictures
- (void)showCatPictures:(CDVInvokedUrlCommand*)command
{
    //CDVPluginResult* res = nil;
    //NSArray* arguments = command.arguments;
    
    //initialize and configure the image view
    CGRect selfRect = CGRectMake(0, 0, 100.0, 200.0);
    self.selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    [self.webView.superview addSubview:self.selfImageView];

    // load pictures and start animating
    NSLog(@"displaying cat pictures");
    selfImageView.animationImages = [NSArray arrayWithObjects:
      [UIImage imageNamed:@"1.JPG"], [UIImage imageNamed:@"2.JPG"], [UIImage imageNamed:@"3.JPG"],
      [UIImage imageNamed:@"4.JPG"], [UIImage imageNamed:@"5.JPG"], [UIImage imageNamed:@"6.JPG"],
      [UIImage imageNamed:@"7.JPG"], [UIImage imageNamed:@"8.JPG"], nil];

    selfImageView.animationDuration = 0.3;
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
    CGRect selfRect = CGRectMake(0, 0, 100.0, 200.0);

    self.selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    //self.selfImageView.layer.cornerRadius = 5;
    //self.selfImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:self.selfImageView];
    
    //Set default video orientation to be portrait
    [[HOPMediaEngine sharedInstance] setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Hook up UI images for self video preview and peer video
    [[HOPMediaEngine sharedInstance] setCaptureRenderView:self.selfImageView];
    [[HOPMediaEngine sharedInstance] setChannelRenderView:self.peerImageView];
    
    self.selfImageView.backgroundColor = [UIColor greenColor];
    self.selfImageView.hidden = NO;
    
    NSLog(@"video config done.");
}

- (void) startAccount
{
    //[[HOPAccount sharedAccount] loginWithAccountDelegate:(id<HOPAccountDelegate>)[[CDVOP sharedOpenPeer] accountDelegate] conversationThreadDelegate:(id<HOPConversationThreadDelegate>) [[CDVOP sharedOpenPeer] conversationThreadDelegate]  callDelegate:(id<HOPCallDelegate>) [[CDVOP sharedOpenPeer] callDelegate]  namespaceGrantOuterFrameURLUponReload:[[Settings sharedSettings] getOuterFrameURL] grantID:[[OpenPeer sharedOpenPeer] deviceId] lockboxServiceDomain:[[Settings sharedSettings] getIdentityProviderDomain] forceCreateNewLockboxAccount:NO];
}

// TODO: remove if not needed
- (void)getAccountState:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;

    //NSArray* arguments = command.arguments;

    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"So far so good"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)startLoginProcess:(CDVInvokedUrlCommand *)command
{
    //CDVPluginResult* res = nil;
    //NSArray* arguments = command.arguments;
    
    if (![[HOPAccount sharedAccount] isCoreAccountCreated] || [[HOPAccount sharedAccount] getState].state == HOPAccountStateShutdown)
        [self startAccount];
    
    //For identity login it is required to pass identity delegate, URL that will be requested upon successful login, identity URI and identity provider domain. This is
    //HOPIdentity* hopIdentity = [HOPIdentity loginWithDelegate:(id<HOPIdentityDelegate>)[[CDVOP sharedOpenPeer] identityDelegate] identityProviderDomain:arguments[0] identityURIOridentityBaseURI: arguments[1] outerFrameURLUponReload:arguments[2]];
}

/**
 @return Singleton object of the Open Peer.
 */
+ (id) sharedOpenPeer
{
    NSLog(@"creating shared static OpenPeer object");
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

@end
