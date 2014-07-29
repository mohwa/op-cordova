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
    self = (CDVOP*  )[super initWithWebView:theWebView];
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
    NSLog(@"Received shutdown command, attempting to shutdown and unload the SDK");
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"SDK is shutting down");
    [[OpenPeer sharedOpenPeer] shutdown];
    
    
    // eveyone needs to know about shutdown, so fire an event
    [self fireEventWithData:@"shutdown" data:@"{}"];
}

/**
 *  shutdown cleanup
 */
- (void) onStackShutdown {
    //[self.visibleWebloginViewController.view removeFromSuperview];
    if (self.visibleWebloginViewController) {
        self.visibleWebloginViewController.view.hidden = YES;
    }
    //[[[OpenPeer sharedOpenPeer] identityDelegate] removeAllWebViewControllers];
    // TODO: see if any other cleanup needed before shutdown
    /*
    NSArray *viewsToRemove = [self.webView.superview subviews];
    for (UIView *view in viewsToRemove) {
        if (![view isEqual:self.webView]) {
            [view removeFromSuperview];
        }
    }*/
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"onStackShutdown delegate fired");
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
    CGRect selfRect = CGRectMake(120, screenRect.size.height - 200, 160, 240);
    UIImageView *selfImageView = [[UIImageView alloc] initWithFrame:selfRect];
    selfImageView.layer.zPosition = 200;
    selfImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:selfImageView];
    [videoViews addObject:selfImageView]; // index 0 will be self video
    
    UIImageView *peerImageView = [[UIImageView alloc] initWithFrame:screenRect];
    peerImageView.layer.zPosition = 50;
    peerImageView.layer.masksToBounds = YES;
    [self.webView.superview addSubview:peerImageView ];
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
        
        /*** The following checks for '%' and applies x,y,width and height values accordingly ***/
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float x = 0;
        float y = 0;
        float w = 100;
        float h = 100;
        NSString *left = [arguments[1] stringByReplacingOccurrencesOfString:@"%" withString:@""];
        NSString *top = [arguments[2] stringByReplacingOccurrencesOfString:@"%" withString:@""];
        NSString *width = [arguments[3] stringByReplacingOccurrencesOfString:@"%" withString:@""];
        NSString *height = [arguments[4] stringByReplacingOccurrencesOfString:@"%" withString:@""];
        if (![arguments[1] isEqualToString:left]) {
            // this is a % left (x)
            x = ([left floatValue] / 100) * screenRect.size.width;
        } else {
            x = [left floatValue];
        }
        if (![arguments[2] isEqualToString:top]) {
            // this is a % height
            y = ([top floatValue] / 100) * screenRect.size.height;
        } else {
            y = [top floatValue];
        }
        if (![arguments[3] isEqualToString:width]) {
            // this is a % width
            w = ([width floatValue] / 100) * screenRect.size.width;
        } else {
            w = [width floatValue];
        }
        if (![arguments[4] isEqualToString:height]) {
            // this is a % height
            h = ([height floatValue] / 100) * screenRect.size.height;
        } else {
            h = [height floatValue];
        }
        CGRect rect = CGRectMake(x, y, w, h);
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

/**
 *  Update selected loggers and levels with settings from JS
 */
- (void) refreshLogger:(CDVInvokedUrlCommand *)command
{
    [Logger setupAllSelectedLoggers];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"] callbackId:command.callbackId];
}

/**
 * Toggle visibility of self or any of peer videos
 * index 0 is self, 1 or higher are for peer videos
 */
- (void) toggleVideoVisibility:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult* res = nil;
    float index = [command.arguments[0] floatValue];
    @try {
        UIImageView *videoView = [videoViews objectAtIndex: index];
        videoView.layer.hidden = !videoView.layer.hidden;
        res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    }
    @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"Error toggling video: %@", exception];
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
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"connecting video views");
    HOPMediaEngine *mediaEngine = [HOPMediaEngine sharedInstance];
    //Set default video orientation to be portrait
    [mediaEngine setDefaultVideoOrientation:HOPMediaEngineVideoOrientationPortrait];
    
    //Hook up UI images for self video preview and peer video
    [mediaEngine setCaptureRenderView:[videoViews objectAtIndex:0]];
    [mediaEngine setChannelRenderView:[videoViews objectAtIndex:1]];
}

/*
 * argument[0] front or back. will toggle otherwise
 * returns "front" or "back" depending on what camera type gets selected
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
            if (currentCameraType == HOPMediaEngineCameraTypeFront) {
                currentCameraType = HOPMediaEngineCameraTypeBack;
                whichCam = @"back";
            } else {
                currentCameraType = HOPMediaEngineCameraTypeFront;
                whichCam = @"front";
            }
            [mediaEngine setCameraType:currentCameraType];
        }
        [mediaEngine startVideoCapture];
    }
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:whichCam];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Toggle mute
 *
 *  passes mute state as bool back to JS land
 */
- (void) toggleMute:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    BOOL muteCall = ![[HOPMediaEngine sharedInstance] getMuteEnabled];
    [[HOPMediaEngine sharedInstance] setMuteEnabled:muteCall];
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:muteCall];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Toggle speaker
 *
 *  passes speaker state as bool back to JS land
 */
- (void) toggleSpeaker:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;
    BOOL speakersOn = ![[HOPMediaEngine sharedInstance] getLoudspeakerEnabled];
    [[HOPMediaEngine sharedInstance] setLoudspeakerEnabled:speakersOn];
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:speakersOn];
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
 * @param command.arguments[1] identityURI of peer
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
    //Currently group chat is not supported, so we can have only one message recipients
    HOPRolodexContact* contact = [[forSession participantsArray] objectAtIndex:0];
    NSString *stringDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                            dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterFullStyle];
    
    NSString* msgData = [NSString stringWithFormat:@"{text:'%@', senderIdentityURI:'%@', type:'%@', date:'%@'}",
                         msg.text, contact.identityURI, msg.type, stringDate];
    [self fireEventWithData:@"onMessageReceived" data:msgData];
}

/**
 * place a call to a contact
 * @param command.arguments[0] conversation thread id/session id
 * @param command.arguments[1] includeVideo boolean
 * @param command.arguments[2] identityURI of the contact to call
 */
- (void) placeCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = nil;
    
    //TODO: see if we need sessionId
    //NSString* sessionId = command.arguments[0];
    BOOL showVideo = [command.arguments[1] boolValue];
    NSString* identityURI = command.arguments[2];
    
    HOPRolodexContact* contact = [[HOPModelManager sharedModelManager] getRolodexContactByIdentityURI:identityURI];
    [[SessionManager sharedSessionManager] placeCall:contact includeVideo:showVideo includeAudio:YES];
    
    /*
    Session* session = [[SessionManager sharedSessionManager] getSessionForContact:contact];
    if (session == nil) {
        session = [[SessionManager sharedSessionManager] createSessionForContact:contact];
    }

    [[SessionManager sharedSessionManager] makeCallForSession:session includeVideo:showVideo isRedial:NO];
    */
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * hangup current call
 * TODO: see if we need to pass call closing reason from client side
 */
- (void) hangupCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = nil;
    NSString* sessionId = command.arguments[0];
    SessionManager* sessionManager = [SessionManager sharedSessionManager];
    
    //TODO get parameters from client
    [sessionManager endCallForSession:[sessionManager getSessionForSessionId:sessionId]];
    
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 * Answer call for given session
 * @param arguments[0] sessionId
 */
- (void) answerCall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult* res = nil;
    NSString* sessionId = command.arguments[0];
    SessionManager* sessionManager = [SessionManager sharedSessionManager];
    
    //TODO: handle/pass back any errors
    [sessionManager answerCallForSession:[sessionManager getSessionForSessionId:sessionId]];
    
    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

/**
 *  Fire an event on JS side and pass along the JSON data
 *
 *  @param event NSString* name of event to fire on JS side
 *  @param data  NSString* JSON data to pass along with event
 */
- (void) fireEventWithData:(NSString *)event data:(NSString *)data
{
    NSString *jsCall = [NSString stringWithFormat:@"__CDVOP_MESSAGE_HANDLER('%@', %@);", event, data];
    @try {
        //[self writeJavascript:jsCall];
        [self performSelectorOnMainThread:@selector(writeJavascript:) withObject:jsCall waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        NSString *error = [NSString stringWithFormat:@"Error sending %@ event to JS. %@ ", event, exception.description];
        OPLog(HOPLoggerSeverityError, HOPLoggerLevelTrace, error);
    }
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
 * Starts user login
 * @param command.arguments[0] padding top, [1] padding right, [2] padding bottom, [3] padding left
 */
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command
{
    int paddingTop = [command.arguments[0] intValue];
    int paddingRight = [command.arguments[1] intValue];
    int paddingBottom = [command.arguments[2] intValue];
    int paddingLeft = [command.arguments[3] intValue];
    self.loginCallbackId = command.callbackId;
    Settings* settings = [Settings sharedSettings];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    settings.loginRect = CGRectMake(paddingLeft, paddingTop, screenRect.size.width - (paddingLeft + paddingRight), screenRect.size.height - (paddingTop + paddingBottom));
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
        // XXX TODO: remove this hack when we can shutdown identities properly and close any open pending webviews
        if (self.visibleWebloginViewController) {
            self.visibleWebloginViewController.view.hidden = YES;
        }

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
        self.visibleWebloginViewController = webLoginViewController;
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Show WebLoginViewController <%p>",webLoginViewController);
        webLoginViewController.view.frame = [[Settings sharedSettings] loginRect];
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

- (void) onStartLoginWithidentityURI
{
    [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-start'}"];
}

- (void) onAccountLoginWebViewClose:(WebLoginViewController *)webLoginViewController {
    [self closeWebLoginView:webLoginViewController];
}

- (void) closeWebLoginView:(WebLoginViewController*) webLoginViewController
{
    if (webLoginViewController)
    {
        [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-webview-close'}"];
        
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
    [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-webview-visible'}"];
    if (!webLoginViewController.view.superview)
        [self showWebLoginView:webLoginViewController];
}

- (void) onOpeningLoginPage {
    //TODO: is this needed?
}

- (void) onRelogin {
    [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-relogin'}"];
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
    [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-finished'}"];
}

- (void) onIdentityLoginShutdown {
    [self fireEventWithData:@"loginStateChange" data:@"{state: 'login-shutdown'}"];
}

- (void) onIdentityLoginError:(NSString *)error {
    NSString* eventData = [NSString stringWithFormat:@"{state: 'login-error', error: '%@'}", error];
    [self fireEventWithData:@"loginStateChange" data:eventData];
}

- (void) onAccountLoginError:(NSString*) error {
    NSString* eventData = [NSString stringWithFormat:@"{state: 'login-error', error: '%@'}", error];
    [self fireEventWithData:@"loginStateChange" data:eventData];
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
    // NSLog(@"face detected");
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
