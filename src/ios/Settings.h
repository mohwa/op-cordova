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

// this non-persistent settings object used to pass settings from webview thread to the rest of the app

/*
 TODO: use it or remove it
@property (nonatomic) BOOL isMediaAECOn;
@property (nonatomic) BOOL isMediaAGCOn;
@property (nonatomic) BOOL isMediaNSOn;

@property (nonatomic) BOOL isRemoteSessionActivationModeOn;
@property (nonatomic) BOOL isFaceDetectionModeOn;
@property (nonatomic) BOOL isRedialModeOn;

@property (nonatomic) BOOL enabledStdLogger;

@property (strong, nonatomic) NSMutableDictionary* appModulesLoggerLevel;
@property (strong, nonatomic) NSMutableDictionary* telnetLoggerSettings;
@property (strong, nonatomic) NSMutableDictionary* outgoingTelnetLoggerSettings;
@property (strong, nonatomic) NSMutableDictionary* loginSettings;

@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *instanceId;
*/
@interface Settings : NSObject

@property (strong, nonatomic) NSString* outerFrameURL;
@property (strong, nonatomic) NSString* namespaceGrantServiceURL;
@property (strong, nonatomic) NSString* identityProviderDomain;
@property (strong, nonatomic) NSString* identityFederateBaseURI;
@property (strong, nonatomic) NSString* lockBoxServiceDomain;
@property (strong, nonatomic) NSString* defaultOutgoingTelnetServer;
@property (strong, nonatomic) NSString* redirectAfterLoginCompleteURL;

+ (id) sharedSettings;
- (id) init __attribute__((unavailable("HOPAccount is singleton class.")));

@end
