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
    [HOPLogger setLogLevelbyName:moduleApplication level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServices level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServicesWire level:HOPLoggerLevelDebug];
    [HOPLogger setLogLevelbyName:moduleServicesIce level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServicesTurn level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServicesRudp level:HOPLoggerLevelDebug];
    [HOPLogger setLogLevelbyName:moduleServicesHttp level:HOPLoggerLevelDebug];
    [HOPLogger setLogLevelbyName:moduleServicesMls level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServicesTcp level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleServicesTransport level:HOPLoggerLevelDebug];
    [HOPLogger setLogLevelbyName:moduleCore level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleStackMessage level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleStack level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleWebRTC level:HOPLoggerLevelDetail];
    [HOPLogger setLogLevelbyName:moduleZsLib level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleSDK level:HOPLoggerLevelTrace];
    [HOPLogger setLogLevelbyName:moduleMedia level:HOPLoggerLevelDetail];
    [HOPLogger setLogLevelbyName:moduleJavaScript level:HOPLoggerLevelTrace];
}


+ (void) startStdLogger:(BOOL) start
{
    if (start)
    {
        [HOPLogger installStdOutLogger:NO];
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
        if ([port length] > 0)
            [HOPLogger installTelnetLogger:[port intValue] maxSecondsWaitForSocketToBeAvailable:60 colorizeOutput:colorized];
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
        NSString* appId = [[CDVOP sharedObject] getSetting:@"openpeer/calculated/authorizated-application-id"];
        if ([server length] > 0)
            [HOPLogger installOutgoingTelnetLogger:server colorizeOutput:colorized stringToSendUponConnection:appId];
    }
    else
    {
        [HOPLogger uninstallOutgoingTelnetLogger];
    }
}

+ (void) startAllSelectedLoggers
{
    [self setLogLevels];
    [self startStdLogger:[[[CDVOP sharedObject] getSetting:@"isStandardLoggerEnabled"] boolValue]];
    [self startTelnetLogger:[[[CDVOP sharedObject] getSetting:@"isTelnetLoggerEnabled"] boolValue]];
    [self startOutgoingTelnetLogger:[[[CDVOP sharedObject] getSetting:@"isOutgoingTelnetLoggerEnabled"] boolValue]];
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
