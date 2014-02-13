#import "CDVOP.h"
#import <Cordova/CDV.h>

@implementation CDVOP

/**
 Retrieves singleton object of the Open Peer.
 @return Singleton object of the Open Peer.
 */
+ (id) sharedOpenPeer
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
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
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;
    //TODO
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
    CDVPluginResult* res = nil;
    NSArray* arguments = command.arguments;
    
    if (![[HOPAccount sharedAccount] isCoreAccountCreated] || [[HOPAccount sharedAccount] getState].state == HOPAccountStateShutdown)
        [self startAccount];
    
    //For identity login it is required to pass identity delegate, URL that will be requested upon successful login, identity URI and identity provider domain. This is
    HOPIdentity* hopIdentity = [HOPIdentity loginWithDelegate:(id<HOPIdentityDelegate>)[[CDVOP sharedOpenPeer] identityDelegate] identityProviderDomain:arguments[0] identityURIOridentityBaseURI: arguments[1] outerFrameURLUponReload:arguments[2]];
}

@end
