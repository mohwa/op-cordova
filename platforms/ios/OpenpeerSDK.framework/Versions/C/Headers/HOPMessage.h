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

@class HOPContact;

@interface HOPMessage : NSObject

@property (nonatomic, copy) NSString* messageID;
@property (nonatomic, retain) HOPContact* contact;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, retain) NSDate* date;

/**
 Message init method
 @param inMessageId NSString Message uique identifier.
 @param messageText NSString Message text.
 @param inContact HOPContact Message recipient.
 @param inMessageType NSString Message mime type. It is on user to create mime types. Currently there are no specified mime types.
 @param inMessageDate NSDate Message date.
 @returns Ponter to the created contact object
 */
- (id) initWithMessageId:(NSString*) inMessageId andMessage:(NSString*) messageText andContact:(HOPContact*) inContact andMessageType:(NSString*) inMessageType andMessageDate:(NSDate*) inMessageDate;
@end
