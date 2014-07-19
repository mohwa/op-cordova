/**

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>

//OP SDK
#import <OpenpeerSDK/HOPStack.h>
#import <OpenpeerSDK/HOPLogger.h>
#import <OpenpeerSDK/HOPSettings.h>
#import <OpenpeerSDK/HOPMediaEngine.h>
#import <OpenpeerSDK/HOPCache.h>
#import <OpenpeerSDK/HOPAccount.h>
#import <OpenpeerSDK/HOPIdentity.h>
#import <OpenPeerSDK/HOPTypes.h>
#import <OpenpeerSDK/HOPAvatar.h>
#import <OpenpeerSDK/HOPImage.h>
#import <OpenpeerSDK/HOPHomeUser.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPAssociatedIdentity.h>
#import <OpenpeerSDK/HOPIdentityContact.h>
#import <OpenpeerSDK/HOPRolodexContact.h>


//OP delegates and helper classes
#import "OpenPeer.h"
#import "Delegates.h"
#import "AppLog.h"
#import "LoginManager.h"
#import "ContactsManager.h"
#import "SessionManager.h"
#import "WebLoginViewController.h"
#import "Settings.h"

@class Session;
@class LoginViewController;
@class WebLoginViewController;
@class HOPAvatar;
@class HOPImage;
@class HOPRolodexContact;

@interface CDVOP : CDVPlugin <UIWebViewDelegate,LoginEventsDelegate> {

}

@property (nonatomic, retain) NSMutableArray* videoViews;
@property (nonatomic, retain) WebLoginViewController* visibleWebloginViewController;

+ (id) sharedObject;

// cordova plugin functions
- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) initialize:(CDVInvokedUrlCommand*)command;
- (void) shutdown:(CDVInvokedUrlCommand*)command;
- (void) showCatPictures:(CDVInvokedUrlCommand*)command;
- (void) stopCatPictures:(CDVInvokedUrlCommand*)command;
- (void) switchCamera:(CDVInvokedUrlCommand*)command;
- (void) testEvent:(CDVInvokedUrlCommand*)command;
- (void) sendMessageToPeer:(CDVInvokedUrlCommand*)command;
- (void) sendMessageToSession:(CDVInvokedUrlCommand *)command;
- (void) placeCall:(CDVInvokedUrlCommand *)command;
- (void) hangupCall:(CDVInvokedUrlCommand *)command;
- (void) answerCall:(CDVInvokedUrlCommand *)command;
- (void) toggleSpeaker:(CDVInvokedUrlCommand*)command;
- (void) toggleMute:(CDVInvokedUrlCommand*)command;
- (void) toggleVideoVisibility:(CDVInvokedUrlCommand*)command;

- (void) onMessageReceived:(HOPMessageRecord*)msg forSession:(Session*)forSession;
- (void) onCallStateChange:(NSString*)eventData;
- (void) makeViewTransparent;
- (void) initVideoViews;
- (void) onFaceDetected;
- (void) connectVideoViews;
- (void) onStackShutdown;

// helpers and other internal functions
- (NSString*) getSetting:(NSString*)setting;
- (void) setSetting:(NSString*)key value:(NSString*)value;
- (BOOL) getSettingAsBool:(NSString*)setting;
- (NSString*) getAllSettingsJSON;
- (UIViewContentMode) getContentMode:(NSString*)mode;
- (void)fireEventWithData:(NSString*)event data:(NSString*)data;

//login relate methods
- (void) onStartLoginWithidentityURI;
- (void) onOpeningLoginPage;
- (void) onLoginWebViewVisible:(WebLoginViewController*) webLoginViewController;
- (void) onRelogin;
- (void) onLoginFinished;
- (void) onIdentityLoginShutdown;
- (void) onIdentityLoginWebViewClose:(WebLoginViewController*) webLoginViewController forIdentityURI:(NSString*) identityURI;
- (void) onIdentityLoginFinished;
- (void) onIdentityLoginError:(NSString*) error;
- (void) onAccountLoginError:(NSString*) error;
- (void) onAccountLoginWebViewClose:(WebLoginViewController*) webLoginViewController;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command;
- (void) showWebLoginView:(WebLoginViewController*) webLoginViewController;
- (void) closeWebLoginView:(WebLoginViewController*) webLoginViewController;

// contacts
- (void) getListOfContacts:(CDVInvokedUrlCommand*)command;
- (void) onContactsLoaded:(NSDictionary*)contacts;

// session
- (void) updateSessionViewControllerId:(NSString*) oldSessionId newSesionId:(NSString*) newSesionId;

@end


