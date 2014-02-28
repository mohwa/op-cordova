/**

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>

//OP SDK
#import <OpenpeerSDK/HOPStack.h>
#import <OpenpeerSDK/HOPLogger.h>
#import <OpenpeerSDK/HOPMediaEngine.h>
#import <OpenpeerSDK/HOPCache.h>
#import <OpenpeerSDK/HOPAccount.h>
#import <OpenpeerSDK/HOPIdentity.h>
#import <OpenPeerSDK/HOPTypes.h>
#import <OpenpeerSDK/HOPHomeUser.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPAssociatedIdentity.h>
#import <OpenpeerSDK/HOPIdentityContact.h>
#import <OpenpeerSDK/HOPRolodexContact.h>


//OP delegates
#import "OpenPeer.h"
#import "Delegates.h"
#import "LoginManager.h"
#import "WebLoginViewController.h"

//@class Session;
@class LoginViewController;
@class WebLoginViewController;
//@class ContactsViewController;

@interface CDVOP : CDVPlugin <UIWebViewDelegate,LoginEventsDelegate> {
    NSString* callbackId;
    UIImageView* peerImageView;
    UIImageView* selfImageView;
}

@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, retain) UIImageView *peerImageView;
@property (nonatomic, retain) UIImageView *selfImageView;

// login properties
/*
@property (nonatomic, weak) WebLoginViewController *webLoginViewController;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAssociation;
 */
@property (nonatomic, strong) LoginViewController *loginViewController;
//@property (nonatomic, strong) ContactsViewController *contactsTableViewController;

+ (id) sharedObject;

// cordova plugin functions
- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) configureApp:(CDVInvokedUrlCommand*)command;
- (void) showCatPictures:(CDVInvokedUrlCommand*)command;

// helpers and other internal functions
- (NSString*) getSetting:(NSString*)setting;

//login relate methods
- (void) onStartLoginWithidentityURI;
- (void) onRelogin;
- (void) onLoginFinished;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command;
- (void) onAccountLoginError:(NSString*) error;
- (void) showWebLoginView:(UIWebView*) webLoginView;
- (void) closeWebLoginView:(UIWebView*) webLoginView;
//- (void) onAccountLoginWebViewClose:(UIWebView*) webLoginView;
@end


