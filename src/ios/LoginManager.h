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
#import "OpenPeer.h"
#import "WebLoginViewController.h"
#import "StackDelegate.h"
#import "CDVOP.h"

//Managers
//#import "ContactsManager.h"
//#import "SessionManager.h"

//SDK
#import <OpenPeerSDK/HOPAccount.h>
#import <OpenPeerSDK/HOPIdentity.h>
#import <OpenPeerSDK/HOPTypes.h>
#import <OpenpeerSDK/HOPHomeUser.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPAssociatedIdentity.h>
#import <OpenpeerSDK/HOPIdentityContact.h>
#import <OpenpeerSDK/HOPRolodexContact.h>

@class WebLoginViewController;
@class HOPIdentity;

@interface LoginManager : NSObject

@property (nonatomic, strong) WebLoginViewController *preloadedWebLoginViewController;
@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAssociation;

+ (id) sharedLoginManager;

- (void) startLoginUsingIdentityURI:(NSString*) identityURI;
- (void) startAccount;
- (void) startLogin;
- (void) login;
- (void) logout:(NSString*) identityURI;
- (void) clearIdentities;
- (void) removeCookiesAndClearCredentials;

- (void) onIdentityAssociationFinished:(HOPIdentity*) identity;
- (void) attachDelegateForIdentity:(HOPIdentity*) identity forceAttach:(BOOL) forceAttach;

- (void) onUserLoggedIn;
- (void) onUserLogOut;

- (BOOL) isAssociatedIdentity:(NSString*) inBaseIdentityURI;

- (void) preloadLoginWebPage;
@end
