#import "CDVOP.h"
#import <Cordova/CDV.h>

@implementation CDVOP

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

// TODO: remove if not needed
- (void)getAccountState:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;

    //NSArray* arguments = command.arguments;

    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"So far so good"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

@end