/*
 
 Copyright (c) 2012, SMB Phone Inc.
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

#import "CallDelegate.h"

@implementation CallDelegate

- (NSString*) getCallStateAsString:(HOPCallStates) callState
{
    NSString *res = nil;
    
    switch (callState)
    {
        case HOPCallStateNone:
            //res = NSLocalizedString(@"none", @"");
            break;
        case HOPCallStatePreparing:
            res = NSLocalizedString(@"preparing", @"");
            break;
        case HOPCallStateIncoming:
            res = NSLocalizedString(@"incoming", @"");
            break;
        case HOPCallStatePlaced:
            res = NSLocalizedString(@"placed", @"");
            break;
        case HOPCallStateEarly:
            res = NSLocalizedString(@"early", @"");
            break;
        case HOPCallStateRinging:
            res = NSLocalizedString(@"ringing", @"");
            break;
        case HOPCallStateRingback:
            res = NSLocalizedString(@"ringback", @"");
            break;
        case HOPCallStateOpen:
            res = NSLocalizedString(@"open", @"");
            break;
        case HOPCallStateActive:
            res = NSLocalizedString(@"active", @"");
            break;
        case HOPCallStateInactive:
            res = NSLocalizedString(@"inactive", @"");
            break;
        case HOPCallStateHold:
            res = NSLocalizedString(@"hold", @"");
            break;
        case HOPCallStateClosing:
            res = NSLocalizedString(@"closing", @"");
            break;
        case HOPCallStateClosed:
            res = NSLocalizedString(@"closed", @"");
            break;
        default:
            return nil;
    }
    return res;
}

- (void) onCallStateChanged:(HOPCall*) call callState:(HOPCallStates) callState
{
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelDebug, @"Call state: %@", [self getCallStateAsString:[call getState]]);
    
    NSString* sessionId = [[call getConversationThread] getThreadId];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // TODO: inform client about call state
        //[sessionViewController updateCallState];
        
        switch (callState)
        {
            case HOPCallStatePreparing:             //Receives both parties, caller and callee.
                //TODO
                //[[SessionManager sharedSessionManager] onCallPreparing:call];
                break;
                
            case HOPCallStateIncoming:              //Receives just callee
                //TODO: tell client about incomming call
                break;
                
            case HOPCallStatePlaced:                //Receives just calller
                break;
                
            case HOPCallStateEarly:                 //Currently is not in use
                break;
                
            case HOPCallStateRinging:               //Receives just callee side. Now should play ringing sound
                // TODO
                //[[SoundManager sharedSoundsManager] playRingingSound];
                break;
                
            case HOPCallStateRingback:              //Receives just caller side
                // TODO
                //[[SoundManager sharedSoundsManager] playCallingSound];
                break;
                
            case HOPCallStateOpen:                  //Receives both parties. Call is established
                /* TODO
                [[SessionManager sharedSessionManager] onCallOpened:call];
                [[SoundManager sharedSoundsManager] stopCallingSound];
                [[SoundManager sharedSoundsManager] stopRingingSound];
                [sessionViewController startTimer];
                 */
                break;
                
            case HOPCallStateActive:                //Currently not in use
                break;
                
            case HOPCallStateInactive:              //Currently not in use
                break;
                
            case HOPCallStateHold:                  //Receives both parties
                break;
                
            case HOPCallStateClosing:               //Receives both parties
                /*
                [[SessionManager sharedSessionManager] onCallClosing:call];
                [[SoundManager sharedSoundsManager] stopCallingSound];
                [[SoundManager sharedSoundsManager] stopRingingSound];
                [sessionViewController stopTimer];
                 */
                break;
                
            case HOPCallStateClosed:                //Receives both parties
                // TODO: tell client that call ended
                break;
                
            case HOPCallStateNone:
            default:
                break;
        }
    });

}
@end
