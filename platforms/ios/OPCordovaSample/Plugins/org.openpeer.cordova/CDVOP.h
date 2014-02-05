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

@interface CDVOP : CDVPlugin

- (void) authorizeApp:(CDVInvokedUrlCommand*)command;
- (void) getAccountState:(CDVInvokedUrlCommand*)command;

@end


