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

#ifndef openpeer_ios_sdk_OpenPeerTypes_h
#define openpeer_ios_sdk_OpenPeerTypes_h

#pragma mark - HOPCall enums
typedef enum 
{
    HOPCallStateNone,       // call has no state yet
    HOPCallStatePreparing,  // call is negotiating in the background - do not present this call to a user yet...
    HOPCallStateIncoming,   // call is incoming from a remote party
    HOPCallStatePlaced,     // call has been placed to the remote party
    HOPCallStateEarly,      // call is outgoing to a remote party and is receiving early media (media before being answered)
    HOPCallStateRinging,    // call is incoming from a remote party and is ringing
    HOPCallStateRingback,   // call is outgoing to a remote party and remote party is ringing
    HOPCallStateOpen,       // call is open
    HOPCallStateActive,     // call is open, and participant is actively communicating
    HOPCallStateInactive,   // call is open, and participant is inactive
    HOPCallStateHold,       // call is open but on hold
    HOPCallStateClosing,    // call is hanging up
    HOPCallStateClosed,     // call has ended
} HOPCallStates;

typedef enum
{
    HOPCallClosedReasonNone                     = 0,
    
    HOPCallClosedReasonUser                     = 200,
    
    HOPCallClosedReasonRequestTimeout           = 408,
    HOPCallClosedReasonTemporarilyUnavailable   = 480,
    HOPCallClosedReasonBusy                     = 486,
    HOPCallClosedReasonRequestTerminated        = 487,
    HOPCallClosedReasonNotAcceptableHere        = 488,
    
    CallClosedReasonServerInternalError      = 500,
    
    CallClosedReasonDecline                  = 603,
} HOPCallClosedReasons;

#pragma mark - HOPConversationThread enums
typedef enum 
{
    HOPConversationThreadMessageDeliveryStateDiscovering      = 0,
    HOPConversationThreadMessageDeliveryStateUserNotAvailable = 1,
    HOPConversationThreadMessageDeliveryStateDelivered        = 2,
} HOPConversationThreadMessageDeliveryStates;

typedef enum 
{
    HOPConversationThreadContactStateNotApplicable,
    HOPConversationThreadContactStateFinding,
    HOPConversationThreadContactStateConnected,
    HOPConversationThreadContactStateDisconnected
} HOPConversationThreadContactStates;

#pragma mark - Provisioning account for future use enum
/**
 Enumerator to represent the openpeer account states.
 */
typedef enum 
{
    HOPAccountStatePending,
    HOPAccountPendingPeerFilesGeneration,
    HOPAccountWaitingForAssociationToIdentity,
    HOPAccountWaitingForBrowserWindowToBeLoaded,
    HOPAccountWaitingForBrowserWindowToBeMadeVisible,
    HOPAccountWaitingForBrowserWindowToClose,
    HOPAccountStateReady,
    HOPAccountStateShuttingDown,
    HOPAccountStateShutdown,
} HOPAccountStates;

#pragma mark - HOPIdentity enums
typedef enum
{
    HOPIdentityStatePending,
    HOPIdentityStatePendingAssociation,
    HOPIdentityStateWaitingAttachmentOfDelegate,
    HOPIdentityStateWaitingForBrowserWindowToBeLoaded,
    HOPIdentityStateWaitingForBrowserWindowToBeMadeVisible,
    HOPIdentityStateWaitingForBrowserWindowToClose,
    HOPIdentityStateReady,
    HOPIdentityStateShutdown
} HOPIdentityStates;


#pragma mark - HOPClientLog enums
typedef enum
{
    HOPLoggerSeverityInformational,
    HOPLoggerSeverityWarning,
    HOPLoggerSeverityError,
    HOPLoggerSeverityFatal
} HOPLoggerSeverities; //Replacing HOPClientLogSeverities

typedef enum
{
    HOPLoggerLevelNone,
    HOPLoggerLevelBasic,
    HOPLoggerLevelDetail,
    HOPLoggerLevelDebug,
    HOPLoggerLevelTrace,
    HOPLoggerLevelInsane,

    HOPLoggerTotalNumberOfLevels
} HOPLoggerLevels; //Replacing HOPClientLogSeverities

#pragma mark - Client enums
typedef enum 
{
    HOPContactTypeOpenPeer,
    HOPContactTypeExternal
} HOPContactTypes;

#pragma mark - HOPMediaEngine enums
typedef enum 
{
    HOPMediaEngineCameraTypeNone,
    HOPMediaEngineCameraTypeFront,
    HOPMediaEngineCameraTypeBack
} HOPMediaEngineCameraTypes;

typedef enum
{
    HOPMediaEngineVideoOrientationLandscapeLeft,
    HOPMediaEngineVideoOrientationPortraitUpsideDown,
    HOPMediaEngineVideoOrientationLandscapeRight,
    HOPMediaEngineVideoOrientationPortrait
} HOPMediaEngineVideoOrientations;

typedef enum
{
    HOPMediaEngineOutputAudioRouteHeadphone,
    HOPMediaEngineOutputAudioRouteBuiltInReceiver,
    HOPMediaEngineOutputAudioRouteBuiltInSpeaker
} HOPMediaEngineOutputAudioRoutes;
#endif
