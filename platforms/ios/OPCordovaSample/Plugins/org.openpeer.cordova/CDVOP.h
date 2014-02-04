/**

*/

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDV.h>


@interface CDVOP : CDVPlugin
    /* Account */
    - (void) getAccountState:(CDVInvokedUrlCommand*)command;

@end


