/**

*/

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>

//OP SDK
#import "OpenpeerSDK/HOPStack.h"
#import "OpenpeerSDK/HOPLogger.h"
#import "OpenpeerSDK/HOPMediaEngine.h"
#import "OpenpeerSDK/HOPCache.h"
#import "OpenpeerSDK/HOPAccount.h"
#import "OpenpeerSDK/HOPIdentity.h"

@interface CDVOP : CDVPlugin

@property (weak, nonatomic) UIImageView *peerImageView;
@property (weak, nonatomic) UIImageView *selfImageView;

- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) configureApp:(CDVInvokedUrlCommand*)command;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;
- (void) startLoginProcess:(CDVInvokedUrlCommand*)command;

@end


