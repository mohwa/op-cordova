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

#import "OpenPeer.h"

//Private methods
@interface OpenPeer ()
- (void) createDelegates;
@end


@implementation OpenPeer

/**
 Retrieves singleton object of the Open Peer.
 @return Singleton object of the Open Peer.
 */
+ (id) sharedOpenPeer
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (NSString*) deviceId
{
    if (!_deviceId)
    {
        _deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:keyOpenPeerUser];
        if ([_deviceId length] == 0)
        {
            _deviceId = [OpenPeer getGUIDstring];
            [[NSUserDefaults standardUserDefaults] setObject:_deviceId forKey:keyOpenPeerUser];
        }
    }
    return _deviceId;
}


/*
 * If default settings have never been persisted (first run of the app) or if reset flag
 * is set to true, this method will store app settings
 */
- (void) storeDefaultSettings:(BOOL)reset
{
    //TODO: reset
    
    //[[HOPSettings sharedSettings] applyDefaults]; //todo: only apply if no setting has been persisted before
    
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/user-agent" value:[OpenPeer getUserAgentName]];
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/device-id" value:[OpenPeer getGUIDstring]];
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/os" value:[OpenPeer getDeviceOs]];
    [[CDVOP sharedObject] setSetting:@"openpeer/calculated/system" value:[OpenPeer getPlatform]];
}

- (void) preSetup {
    if ([[[CDVOP sharedObject] getSetting:@"isLoggerEnabled"] boolValue]) {
        [OpenPeer startLogging];
    }

    //Create all delegates required for communication with core
    [self createDelegates];
    
    //Set persistent stores
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPathDirectory = [libraryPath stringByAppendingPathComponent:@"db"];
    [[HOPModelManager sharedModelManager] setDataPath:dataPathDirectory backupData:NO];
    [[HOPModelManager sharedModelManager] clearSessionRecords];
    
    //Cleare expired cookies and set delegate
    [[HOPCache sharedCache] removeExpiredCookies];
    [[HOPCache sharedCache] setup];
    
    //Set settigns delegate
    [[HOPSettings sharedSettings] setup];
    [[HOPSettings sharedSettings] applyDefaults];

    [self updateDefaultSettingsFromPath:[[NSBundle mainBundle] pathForResource:@"DefaultSettings" ofType:@"plist"] notToUpdateKeys:nil];
    [self storeDefaultSettings:YES];
}

/**
 * Initializes the open peer stack
 */
- (void) setup {
    // get all final JSON settings from JS
    NSString* settings = [[CDVOP sharedObject] getAllSettingsJSON];
    [[HOPSettings sharedSettings] applySettings:settings];

    if (![[HOPStack sharedStack] isStackReady])
    {
        //Init openpeer stack and set created delegates
        [[HOPStack sharedStack] setupWithStackDelegate:self.stackDelegate mediaEngineDelegate:self.mediaEngineDelegate];
    }

    [[HOPMediaEngine sharedInstance] setEcEnabled:[[CDVOP sharedObject] getSettingAsBool:@"isMediaAECOn"]];
    [[HOPMediaEngine sharedInstance] setAgcEnabled:[[CDVOP sharedObject] getSettingAsBool:@"isMediaAGCOn"]];
    [[HOPMediaEngine sharedInstance] setNsEnabled:[[CDVOP sharedObject] getSettingAsBool:@"isMediaNSOn"]];
}

/**
 *  Return true only if stack is initialized and ready
 */
- (BOOL) isStackReady {
    return [[HOPStack sharedStack] isStackReady];
}

- (void) shutdown {
    @try {
        [[HOPStack sharedStack] shutdown];
    }
    @catch (NSException *exception) {
        OPLog(HOPLoggerSeverityError, HOPLoggerLevelTrace, @"there was an error shutting down: %@", exception.description);
    }

    self.stackDelegate = nil;
    self.mediaEngineDelegate = nil;
    self.conversationThreadDelegate = nil;
    self.callDelegate = nil;
    self.accountDelegate = nil;
    self.identityDelegate = nil;
    self.identityLookupDelegate = nil;
    //self.cacheDelegate = nil;
}
/**
 Method used for all delegates creation. Delegates will catch events from the Open Peer SDK and handle them properly.
 */
- (void) createDelegates
{
    self.stackDelegate = [[StackDelegate alloc] init];
    self.mediaEngineDelegate = [[MediaEngineDelegate alloc] init];
    self.conversationThreadDelegate = [[ConversationThreadDelegate alloc] init];
    self.callDelegate = [[CallDelegate alloc] init];
    self.accountDelegate = [[AccountDelegate alloc] init];
    self.identityDelegate = [[IdentityDelegate alloc] init];
    self.identityDelegate.loginDelegate = [CDVOP sharedObject];
    self.identityLookupDelegate = [[IdentityLookupDelegate alloc] init];
    //self.cacheDelegate = [[CacheDelegate alloc] init];
}

- (void)updateDefaultSettingsFromPath:(NSString *)filePath notToUpdateKeys:(NSMutableArray *)notToUpdateKeys
{
    if ([filePath length] > 0)
    {
        //Clean disctionary from invalid entries
        NSDictionary* filteredDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        if ([filteredDictionary count] > 0)
        {
            for (NSString* key in [filteredDictionary allKeys])
            {
                //Check if value for specific key should be updated
                if (![notToUpdateKeys containsObject:key])
                {
                    id value = [filteredDictionary objectForKey:key];
                    [[HOPSettings sharedSettings] storeSettingsObject:value key:[[HOPSettings sharedSettings]getCoreKeyForAppKey:key]];
                    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelInsane, @"Updated value: %@ for key: %@",value,key);
                }
            }
        }
        
        //Save new default settings
        NSMutableDictionary* defaultSettings = nil;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:settingsKeyDefaultSettingsSnapshot])
            defaultSettings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:settingsKeyDefaultSettingsSnapshot]];
        else
            defaultSettings = [[NSMutableDictionary alloc] init];
        [defaultSettings addEntriesFromDictionary:filteredDictionary];
        [[NSUserDefaults standardUserDefaults] setObject:defaultSettings forKey:settingsKeyDefaultSettingsSnapshot];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

// Utility functions

+ (NSString *)getGUIDstring
{
    CFUUIDRef guid = CFUUIDCreate(nil);
    NSString *strGuid = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, guid));
    CFRelease(guid);
    return strGuid;
}

+ (NSString*) getDeviceOs
{
    NSString* deviceOs = [NSString stringWithFormat:@"%@ %@,",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice]  systemVersion]];
    return deviceOs;
}

+ (NSString*) getPlatform
{
    size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    //sysctlbyname("hw.model", NULL, &size, NULL, 0);
	char *machine = (char*)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
    //sysctlbyname("hw.model", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
	free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
	if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
	if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform hasPrefix:@"iPhone3"]) return @"iPhone 4";
    if ([platform hasPrefix:@"iPhone4"]) return @"iPhone 4S";
    
	if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
	if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform hasPrefix:@"iPod3"])   return @"iPod Touch 3G";
    if ([platform hasPrefix:@"iPod4"])   return @"iPod Touch 4G";
    
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1";
	if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform hasPrefix:@"iPad3"])    return @"iPad 3";
    
	if ([platform isEqualToString:@"i386"])   return @"iPhone Simulator";
	return platform;
}

+ (NSString*) getUserAgentName
{
    NSString* developerId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Hookflash Developer ID"];
    
    NSString* appName = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"];
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString* appOs = [[UIDevice currentDevice] systemName];
    NSString* appVersionOs = [[UIDevice currentDevice] systemVersion];
    NSString* deviceModel = [[UIDevice currentDevice] model];
    
    NSString* model = nil;
    
    if ([deviceModel hasPrefix:@"iPhone"] || [deviceModel hasPrefix:@"iPod"])
        model = @"iPhone";
    else if ([deviceModel hasPrefix:@"iPad"])
        model = @"iPad";
    
    NSString* userAgent = [NSString stringWithFormat:@"%@/%@ (%@ %@;%@) HOPID/1.0 (%@)",appName,appVersion,appOs,appVersionOs,model,developerId];
    
    return userAgent;
}

+ (void) startLogging {
    [Logger startAllSelectedLoggers];
}

@end
