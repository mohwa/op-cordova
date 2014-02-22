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
#import "WebLoginViewController.h"

@interface CDVOP : CDVPlugin <UIWebViewDelegate> {
    NSString* callbackId;
    UIImageView* peerImageView;
    UIImageView* selfImageView;
}

@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, retain) UIImageView *peerImageView;
@property (nonatomic, retain) UIImageView *selfImageView;
@property (nonatomic, weak) WebLoginViewController *webLoginViewController;

+ (id) sharedObject;

// cordova plugin functions
- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) configureApp:(CDVInvokedUrlCommand*)command;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command;
- (void) showCatPictures:(CDVInvokedUrlCommand*)command;

// helpers and other internal functions
- (NSString*) getSetting:(NSString*)setting;
- (void) showWebLoginView:(UIWebView*) webLoginView;
- (void) closeWebLoginView:(UIWebView*) webLoginView;

@end


