/**

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>

//OP SDK
#import "OpenpeerSDK/HOPStack.h"
#import "OpenpeerSDK/HOPLogger.h"
#import "OpenpeerSDK/HOPMediaEngine.h"
#import "OpenpeerSDK/HOPCache.h"
#import "OpenpeerSDK/HOPAccount.h"
#import "OpenpeerSDK/HOPIdentity.h"

//OP delegates
#import "OpenPeer.h"


@interface CDVOP : CDVPlugin <UIWebViewDelegate> {
    NSString* callbackId;
    UIImageView* peerImageView;
    UIImageView* selfImageView;
}

@property (nonatomic, copy) NSString* callbackId;
@property (nonatomic, retain) UIImageView *peerImageView;
@property (nonatomic, retain) UIImageView *selfImageView;
@property (nonatomic, weak) UIWebView *loginWebView;
@property (nonatomic, weak) id coreObject;

// cordova plugin functions
- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) configureApp:(CDVInvokedUrlCommand*)command;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;
- (void) logout:(CDVInvokedUrlCommand*)command;
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command;
- (void) showCatPictures:(CDVInvokedUrlCommand*)command;

// helpers and other internal functions
- (void) openLoginUrl:(NSString*)url;
- (void) passMessageToJS:(NSString*)message;
@end


