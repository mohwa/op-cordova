#import "CDVOP.h"

@interface CDVOP ()
@property NSString* loginCallbackId;
@property NSString* contactsCallbackId;
@property HOPCall* currentCall;
@end

@implementation CDVOP

@synthesize webView, videoViews;

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

/**
 *  initialize the SDK
 */
- (void) initialize:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* res;
    [self makeViewTransparent];
    [self initVideoViews];
    
    [[OpenPeer sharedOpenPeer] setup];

    if ([[OpenPeer sharedOpenPeer] isStackReady]) {
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    } else {
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error initializing the SDK! please check the logs"];
    }
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Shutdown the SDK
 */
- (void) shutdown:(CDVInvokedUrlCommand*)command {
    [[OpenPeer sharedOpenPeer] shutdown];
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

- (void) stopCatPictures:(CDVInvokedUrlCommand*)command {
    @try {
        UIImageView *selfImageView = [videoViews objectAtIndex: 0];
        UIImageView *peerImageView = [videoViews objectAtIndex: 1];
        [selfImageView removeFromSuperview];
        [peerImageView removeFromSuperview];
        [videoViews removeAllObjects];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to terminate the felines: %@", exception);
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

/*
 * this method is called as soon as client side is loaded
 * load settings and authorize app if necessary
 */
- (void) authorizeApp:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;
    
    // we need to load settings before we can get the authorizes app id
    [[OpenPeer sharedOpenPeer] preSetup];
    
    NSString* authorizedApplicationId = [[HOPSettings sharedSettings] getAuthorizedApplicationId];
    
    //If authorized application id is missing, generate it
    if ([authorizedApplicationId length] == 0) {
        NSDate* expiry = [[NSDate date] dateByAddingTimeInterval:(30 * 24 * 60 * 60)];
        authorizedApplicationId = [HOPStack createAuthorizedApplicationID:arguments[0] applicationIDSharedSecret:arguments[1] expires:expiry];
        [[HOPSettings sharedSettings] storeAuthorizedApplicationId:authorizedApplicationId];
    }
    
    // TODO: figure out where/if we need to send the authorized application id to client
    // we need to have this in the JSON settings since SDK expects it
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/authorizated-application-id" value:[[HOPSettings sharedSettings] getAuthorizedApplicationId]];
    
    // TODO: check that authorization was successful and send error otherwise
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:authorizedApplicationId];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/*
 * connect video views to their video streams comming from SDK
 * precondition: UIImageViews have been initialized and added to videoViews
 */
- (void) connectVideoViews
{
    HOPMediaEngine *mediaEngine = [HOPMediaEngine sharedInstance];
    //Set default video orientation to be portrait
    [mediaEngine setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Hook up UI images for self video preview and peer video
    [mediaEngine setCaptureRenderView:[videoViews objectAtIndex:0]];
    [mediaEngine setChannelRenderView:[videoViews objectAtIndex:1]];
    [mediaEngine startVideoCapture];
}

/*
 * argument[0] front or back. will toggle otherwise
 */
- (void) switchCamera:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSString *whichCam = command.arguments[0];
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        HOPMediaEngine *mediaEngine = [HOPMediaEngine sharedInstance];
        [mediaEngine stopVideoCapture];
        if([whichCam isEqualToString:@"front"]) {
            [mediaEngine setCameraType:HOPMediaEngineCameraTypeFront];
        } else if ([whichCam isEqualToString:@"back"]) {
            [mediaEngine setCameraType:HOPMediaEngineCameraTypeBack];
        } else {
            // toggle to the other camera
            HOPMediaEngineCameraType currentCameraType = [mediaEngine getCameraType];
            currentCameraType = currentCameraType == HOPMediaEngineCameraTypeFront ? HOPMediaEngineCameraTypeBack : HOPMediaEngineCameraTypeFront;
            [mediaEngine setCameraType:currentCameraType];
        }
        [mediaEngine startVideoCapture];
    }
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * Echo back an event to the JS side (for testing)
 *
 * @param command.arguments[0] event
 * @param command.arguments[1] data
 */
- (void) testEvent:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    NSString* event = command.arguments[0];
    NSString* data = command.arguments[1];
    [self fireEventWithData:event data:data];
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * @param command.arguments[0] the message to send
 * @param command.arguments[1] peerURI
 * Currently only one peer is expected, so first item will be used only
 */
- (void) sendMessageToPeer:(CDVInvokedUrlCommand *)command
{
    //TODO: update this with a loop when we support multiple peer chat
    NSString* msg = command.arguments[0];
    NSString* peerURI = command.arguments[1];

    //HOPRolodexContact* contact  = [[[HOPModelManager sharedModelManager] getRolodexContactsByPeerURI:peerURI] objectAtIndex:0];
    HOPRolodexContact* contact  = [[HOPModelManager sharedModelManager] getRolodexContactByIdentityURI:peerURI];
    Session* session = [[SessionManager sharedSessionManager] getSessionForContact:contact];
    if (session == nil) {
        session = [[SessionManager sharedSessionManager] createSessionForContact:contact];
    }
    [[MessageManager sharedMessageManager] sendMessage:msg forSession:session];
}

/**
 *  @param command.arguments[0] the message to send
 *  @param command.arguments[1] sessionId
 */
- (void) sendMessageToSession:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* res = nil;
    NSString* msg = command.arguments[0];
    NSString* sessionId = command.arguments[1];
    
    Session* session = [[SessionManager sharedSessionManager] getSessionForSessionId:sessionId];
    if (session == nil) {
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"session not found"];
    } else {
        [[MessageManager sharedMessageManager] sendMessage:msg forSession:session];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    }
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Tell JS that a new message has been received
 *  @param msg        HOPMessageRecord
 *  @param forSession Session that this message belongs to
 */
- (void) onMessageReceived:(HOPMessageRecord*)msg forSession:(Session*)forSession {
    // TODO: send message to client api to fire event
}

/**
 * place a call to a contact
 * @param command.arguments[0] identityURI of the contact to call
 * @param command.arguments[1] conversation thread id/session id
 */
- (void) placeCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = nil;
    
    //TODO: see if we need sessionId
    //NSString* sessionId = command.arguments[0];
    
    NSString* identityURI = command.arguments[1];
    
    HOPRolodexContact* contact = [[HOPModelManager sharedModelManager] getRolodexContactByIdentityURI:identityURI];
    Session* session = [[SessionManager sharedSessionManager] getSessionForContact:contact];
    if (session == nil) {
        session = [[SessionManager sharedSessionManager] createSessionForContact:contact];
    }

    //TODO get parameters from client
    [[SessionManager sharedSessionManager] makeCallForSession:session includeVideo:YES isRedial:NO];
    
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * hangup current call
 * TODO: see if we need to pass call closing reason from client side
 */
- (void) hangupCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = nil;
    
    //TODO get parameters from client
    [[SessionManager sharedSessionManager] hangup:HOPCallClosedReasonUser];
    
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Fire and event on JS side and pass along the data
 *
 *  @param event NSString* name of event to fire on JS side
 *  @param data  NSString* JSON data to pass along with event
 */
- (void) fireEventWithData:(NSString *)event data:(NSString *)data
{
    NSString *jsCall = [NSString stringWithFormat:@"__CDVOP_MESSAGE_HANDLER('%@', %@);", event, data];
    [self writeJavascript:jsCall];
}

/**
 * Tell JS about change in call state
 *
 * @param eventData json object containing additional information including callState and sessionId
 * eventData.callState can be one of: ['call-preparing', 'call-incoming', 'call-ringing', 'call-ringback'
 * 'call-open', 'call-onhold', 'call-closing', 'call-closed']
 */
- (void) onCallStateChange:(NSString*)eventData {
    [self fireEventWithData:@"callStateChange" data:eventData];
}

/**
 *  Give account state to JS side upon request
 */
- (void) getAccountState:(CDVInvokedUrlCommand*)command
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
    [self updateLoggingSettingsObjectFromJS];
    [self.commandDelegate runInBackground:^{
        NSLog(@"Starting the login process");
        [[LoginManager sharedLoginManager] login];
    }];
}

/**
 *  initiate loading of contacts if user is logged in. Contacts will be sent to user when ready via onContactsLoaded method
 *
 *  @param command.arguments[0] BOOL refresh to load latest contacts from server. If true will also rolodex to reload contacts
 */
- (void) getListOfContacts:(CDVInvokedUrlCommand*)command
{
    ContactsManager* contactsManager = [ContactsManager sharedContactsManager];
    contactsManager.avatarWidth = [NSNumber numberWithDouble:[command.arguments[0] doubleValue]];
    contactsManager.onlyOPContacts = [command.arguments[1] boolValue];

    BOOL refresh = [command.arguments[2] boolValue];
    self.contactsCallbackId = command.callbackId;
    [self.commandDelegate runInBackground:^{
        NSLog(@"Starting to load contacts");
        if (refresh) {
            // TODO: check why refresh does not pull new contacts from facebook
            [[ContactsManager sharedContactsManager] refreshRolodexContacts];
            // TODO: do we need also to refresh existing contacts here?
            //[[ContactsManager sharedContactsManager] refreshExisitngContacts];
        }
        [contactsManager loadContacts];
    }];
}

/**
 *  Pass along the contactsList, when it is ready, as a giant array to JS side
 *
 *  @param contacts array of contacts
 */
- (void) onContactsLoaded:(NSDictionary*)contacts {
    NSLog(@"Passing along the contacts list");
    CDVPluginResult* res = nil;
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:contacts];
    [self.commandDelegate sendPluginResult:res callbackId:self.contactsCallbackId];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    
    // TODO: use this to decide if we want to logout of only one identity or all of them
    NSString *identityUri = command.arguments[0];
    
    LoginManager *loginManager = [LoginManager sharedLoginManager];
    
    @try {
        [loginManager logout:identityUri];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    }
    @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"logout error: %@", exception];
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }

    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * read setting from JavaScript settings object and return it as NSString*
 */
- (NSString*) getSetting:(NSString*)setting
{
    NSString *jsCall = [NSString stringWithFormat:@"__CDVOP_GET_INSTANCE().getSettingForKey('%@');", setting];
    return [self writeJavascript:jsCall];
}

/*
 * set setting[key] to value
 */
- (void) setSetting:(NSString*)key value:(NSString*)value {
    NSString *jsCall = [NSString stringWithFormat:@"__CDVOP_GET_INSTANCE()._settings['%@'] = '%@';", key, value];
    [self writeJavascript:jsCall];
}

/**
 * read setting from JavaScript settings object and return it as BOOL
 */
- (BOOL) getSettingAsBool:(NSString*)setting {
    NSString *str = [self getSetting:setting];
    return [str boolValue];
}

/**
 *  Get all current settings from JS side
 *
 *  @return NSString* JSON object with "root" element as expected by core
 */
- (NSString*) getAllSettingsJSON
{
    NSString *settings = [self writeJavascript:@"JSON.stringify(__CDVOP_GET_INSTANCE().getAllSettings());"];
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
        
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Show WebLoginViewController <%p>",webLoginViewController);
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
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Close WebLoginViewController <%p>",webLoginViewController);
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

// send an object to JS containing identity info
- (void) onIdentityLoginFinished {
    CDVPluginResult* res = nil;
    HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
    
    NSArray* associatedIdentites = [[HOPAccount sharedAccount] getAssociatedIdentities];
    //NSSet *associatedIdentities = [homeUser associatedIdentities];
    
    // TODO: check to see what would be right index and get more info about user identity
    HOPIdentity* identity = [associatedIdentites objectAtIndex:0];
    
    NSString * identityURI = [identity getIdentityURI];
    //HOPAssociatedIdentity *hopId = [associatedIdentities ]
    //HOPRolodexContact *homeUserProfile = [identity]
    //HOPIdentityContact* homeIdentityContact = [identity getSelfIdentityContact];
    //HOPModelManager* modelManager = [HOPModelManager sharedModelManager];
    
    //TODO: get more home user info
    NSDictionary* message = [[NSDictionary alloc] initWithObjectsAndKeys:identityURI, @"uri", [homeUser getFullName], @"name", nil];
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
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
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Account login error: %@",error);
    //TODO: send error to client
}

- (void) updateSessionViewControllerId:(NSString*) oldSessionId newSesionId:(NSString*) newSesionId {
    //TODO 
}

/**
 * Handle face detected event
 */
- (void) onFaceDetected
{
    // TODO
    NSLog(@"face detected");
}

- (void) updateLoggingSettingsObjectFromJS
{
    Settings* settings = [Settings sharedSettings];
    settings.outerFrameURL = [self getSetting:@"outerFrameURL"];
    settings.namespaceGrantServiceURL = [self getSetting:@"namespaceGrantServiceURL"];
    settings.identityProviderDomain = [self getSetting:@"identityProviderDomain"];
    settings.identityFederateBaseURI = [self getSetting:@"identityFederateBaseURI"];
    settings.lockBoxServiceDomain = [self getSetting:@"lockBoxServiceDomain"];
    settings.defaultOutgoingTelnetServer = [self getSetting:@"defaultOutgoingTelnetServer"];
    settings.redirectAfterLoginCompleteURL = [self getSetting:@"redirectAfterLoginCompleteURL"];
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
