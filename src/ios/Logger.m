/*
 
 Copyright (c) 2013, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "Logger.h"

@implementation Logger

+ (void) setLogLevels
{
    //For each system you can choose log level from HOPClientLogLevelNone (turned off) to HOPClientLogLevelInsane (most detail).
    CDVOP* cop = [CDVOP sharedObject];
    [HOPLogger setLogLevelbyName:moduleApplication          level:[self getLogLevelFromString:[cop getSetting:@"logLevelForApplication"]]];
    [HOPLogger setLogLevelbyName:moduleServices             level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServices"]]];
    [HOPLogger setLogLevelbyName:moduleServicesWire         level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesWire"]]];
    [HOPLogger setLogLevelbyName:moduleServicesIce          level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesIce"]]];
    [HOPLogger setLogLevelbyName:moduleServicesTurn         level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesTurn"]]];
    [HOPLogger setLogLevelbyName:moduleServicesRudp         level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesRudp"]]];
    [HOPLogger setLogLevelbyName:moduleServicesHttp         level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesHttp"]]];
    [HOPLogger setLogLevelbyName:moduleServicesMls          level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesMls"]]];
    [HOPLogger setLogLevelbyName:moduleServicesTcp          level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesTcp"]]];
    [HOPLogger setLogLevelbyName:moduleServicesTransport    level:[self getLogLevelFromString:[cop getSetting:@"logLevelForServicesTransport"]]];
    [HOPLogger setLogLevelbyName:moduleCore                 level:[self getLogLevelFromString:[cop getSetting:@"logLevelForCore"]]];
    [HOPLogger setLogLevelbyName:moduleStackMessage         level:[self getLogLevelFromString:[cop getSetting:@"logLevelForStackMessage"]]];
    [HOPLogger setLogLevelbyName:moduleStack                level:[self getLogLevelFromString:[cop getSetting:@"logLevelForStack"]]];
    [HOPLogger setLogLevelbyName:moduleWebRTC               level:[self getLogLevelFromString:[cop getSetting:@"logLevelForWebRTC"]]];
    [HOPLogger setLogLevelbyName:moduleZsLib                level:[self getLogLevelFromString:[cop getSetting:@"logLevelForZsLib"]]];
    [HOPLogger setLogLevelbyName:moduleSDK                  level:[self getLogLevelFromString:[cop getSetting:@"logLevelForSDK"]]];
    [HOPLogger setLogLevelbyName:moduleZsLibSocket          level:[self getLogLevelFromString:[cop getSetting:@"logLevelForZsLibSocket"]]];
    [HOPLogger setLogLevelbyName:moduleSDK                  level:[self getLogLevelFromString:[cop getSetting:@"logLevelForSDK"]]];
    [HOPLogger setLogLevelbyName:moduleMedia                level:[self getLogLevelFromString:[cop getSetting:@"logLevelForMedia"]]];
    [HOPLogger setLogLevelbyName:moduleJavaScript           level:[self getLogLevelFromString:[cop getSetting:@"logLevelForJavaScript"]]];
    
    applicationLogerLevel = [self getLogLevelFromString:[cop getSetting:@"logLevelForApplication"]];
}

+ (HOPLoggerLevel) getLogLevelFromString:(NSString*) level
{
    if ([level isEqualToString:@"basic"]) {
        return HOPLoggerLevelBasic;
    } else if ([level isEqualToString:@"detail"]) {
        return HOPLoggerLevelDetail;
    } else if ([level isEqualToString:@"debug"]) {
        return HOPLoggerLevelDebug;
    } else if ([level isEqualToString:@"trace"]) {
        return HOPLoggerLevelTrace;
    } else if ([level isEqualToString:@"insane"]) {
        return HOPLoggerLevelInsane;
    } else {
        // by default set level to none
        return HOPLoggerLevelNone;
    }
}

+ (void) startStdLogger:(BOOL) start
{
    if (start)
    {
        [HOPLogger installStdOutLogger];
    }
    else
        [HOPLogger uninstallStdOutLogger];
}

/**
 Sets log levels and starts the logger.
 */
+ (void) startTelnetLogger:(BOOL) start
{
    if (start)
    {
        NSString* port = [[CDVOP sharedObject] getSetting:@"telnetPortForLogger"];
        BOOL colorized = [[[CDVOP sharedObject] getSetting:@"isLoggerColorized"] boolValue];
        if ([port length] > 0) {
            [HOPLogger installTelnetLogger:[port intValue] maxSecondsWaitForSocketToBeAvailable:60 colorizeOutput:colorized];
        } else {
            NSLog(@"Could not start the telnet logger, invalid port number %@", port);
        }
    }
    else
    {
        [HOPLogger uninstallTelnetLogger];
    }
}

+ (void) startOutgoingTelnetLogger:(BOOL) start
{
    if (start)
    {
        NSString* server = [[CDVOP sharedObject] getSetting:@"defaultOutgoingTelnetServer"];
        BOOL colorized = [[[CDVOP sharedObject] getSetting:@"isOutgoingTelnetColorized"] boolValue];
        
        NSString* deviceId = [[HOPSettings sharedSettings] deviceId];
        NSString* instanceId = [[HOPSettings sharedSettings] getInstanceId];
        NSString* connectionString = [[deviceId stringByAppendingString:@"-"] stringByAppendingString:instanceId];
        
        if ([server length] > 0) {
            [HOPLogger installOutgoingTelnetLogger:server colorizeOutput:colorized stringToSendUponConnection:connectionString];
        } else {
            NSLog(@"Could not start the outgoing telnet logger, invalid server address: %@", server);
        }
    }
    else
    {
        [HOPLogger uninstallOutgoingTelnetLogger];
    }
}

+ (void) setupAllSelectedLoggers
{
    [self setLogLevels];
    [self startStdLogger:[[[CDVOP sharedObject] getSetting:@"isStandardLoggerEnabled"] boolValue]];
    [self startTelnetLogger:[[[CDVOP sharedObject] getSetting:@"isTelnetLoggerEnabled"] boolValue]];
    [self startOutgoingTelnetLogger:[[[CDVOP sharedObject] getSetting:@"isOutgoingTelnetLoggerEnabled"] boolValue]];
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"selected logger have started");
}

+ (void) start:(BOOL) start logger:(LoggerTypes) type
{
    switch (type)
    {
        case LOGGER_STD_OUT:
            [self startStdLogger:start];
            break;
                    
        case LOGGER_TELNET:
            [self startTelnetLogger:start];
            break;
            
        case LOGGER_OUTGOING_TELNET:
            [self startOutgoingTelnetLogger:start];
            break;
            
        default:
            break;
    }
    
}

@end
