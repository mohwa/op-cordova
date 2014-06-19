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

#import <Foundation/Foundation.h>
#import <OpenpeerSDK/HOPRolodexContact.h>
#import <OpenpeerSDK/HOPConversationThread.h>

#import "AppLog.h"

@class HOPContact;
@class HOPCall;
@class HOPConversationThread;
@class HOPRolodexContact;
@class HOPSessionRecord;

@interface Session : NSObject

@property (strong) NSMutableArray* participantsArray;
@property (weak, nonatomic) HOPConversationThread* conversationThread;
@property (weak, nonatomic) HOPSessionRecord* sessionRecord;
@property (strong) HOPCall* currentCall;
@property (assign) BOOL isRedial;
@property (strong) NSMutableArray* messageArray;
@property (strong) NSMutableArray* unreadMessageArray;
@property (strong) NSMutableSet* sessionIdsHistory;
@property (strong) NSMutableArray* arrayMergedConversationThreads;
@property (strong) NSMutableSet* setOfNotSentMessages;

- (id) initWithContact:(HOPRolodexContact*) inContact conversationThread:(HOPConversationThread*) inConverationThread;
- (id) initWithContacts:(NSArray*) inContacts conversationThread:(HOPConversationThread*) inConverationThread;
@end
