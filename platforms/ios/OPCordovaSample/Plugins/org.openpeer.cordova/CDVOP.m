#import "CDVOP.h"
#import <Cordova/CDV.h>

@implementation CDVOP

- (void)getAccountState:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* res = nil;

    //NSArray* arguments = command.arguments;

    res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"So far so good"];
    
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

@end