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

#include "ContactsManager.h"

@interface ContactsManager ()
{
    NSString* keyJSONContactFirstName;
    NSString* keyJSONContacLastName;
    NSString* keyJSONContactId;
    NSString* keyJSONContactProfession;
    NSString* keyJSONContactPictureURL;
    NSString* keyJSONContactFullName;
}
- (id) initSingleton;

@end
@implementation ContactsManager

/**
 Retrieves singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
+ (id) sharedContactsManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialize singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.identityLookupsArray = [[NSMutableArray alloc] init];
        self.setOfIdentitiesWhoseContactsDownloadInProgress = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void) loadAddressBookContacts
{
    NSMutableArray* contactsForIdentityLookup = [[NSMutableArray alloc] init];
    ABAddressBookRef addressBook = NULL;
    NSString* idFedBaseURI = [[Settings sharedSettings] identityFederateBaseURI];
    NSString* idProviderDomain = [[Settings sharedSettings] identityProviderDomain];
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    {
        // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    {
        // we're on iOS 5 or older
        accessGranted = YES;
    }

    // import local contacts
    if(accessGranted)
    {
        CFErrorRef error = nil;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        if (error)
        {
            OPLog(HOPLoggerSeverityError, HOPLoggerLevelDebug, @"Unable to read the contacts from the address book.");
            
            if (addressBookRef)
                CFRelease(addressBookRef);
            
            return;
        }
        
        if (addressBookRef)
        {
            CFArrayRef allPeopleRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            if (allPeopleRef)
            {
                CFIndex nPeople = ABAddressBookGetPersonCount(addressBookRef);
                
                for (int z = 0; z < nPeople; z++)
                {
                    ABRecordRef person =  CFArrayGetValueAtIndex(allPeopleRef, z);
                    
                    NSString* firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString* lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    NSString* fullNameTemp = @"";
                    
                                        
                    if (firstName)
                    {
                        fullNameTemp = [firstName stringByAppendingString:@" "];
                    }
                    
                    if (lastName)
                    {
                        fullNameTemp= [fullNameTemp stringByAppendingString:lastName];
                    }
                    
                    NSString* identityURI = nil;
                    ABMultiValueRef social = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
                    if (social)
                    {
                        int numberOfSocialNetworks = (int)ABMultiValueGetCount(social);
                        for (CFIndex i = 0; i < numberOfSocialNetworks; i++)
                        {
                            NSDictionary *socialItem = (__bridge_transfer NSDictionary*)ABMultiValueCopyValueAtIndex(social, i);
                            
                            NSString* service = [socialItem objectForKey:(NSString *)kABPersonSocialProfileServiceKey];
                            if ([[service lowercaseString] isEqualToString:@"openpeer"])
                            {
                                NSString* username = [socialItem objectForKey:(NSString *)kABPersonSocialProfileUsernameKey];
                                if ([username length] > 0)
                                    identityURI = [NSString stringWithFormat:@"%@%@", idFedBaseURI, [username lowercaseString]];
                            }
                        }
                        CFRelease(social);
                    }

                    if ([identityURI length] > 0)
                    {
                        //Execute core data manipulation on main thread to prevent app freezing. 
                        dispatch_sync(dispatch_get_main_queue(), ^
                        {
                            HOPRolodexContact* rolodexContact = [[HOPModelManager sharedModelManager] getRolodexContactByIdentityURI:identityURI];
                            if (!rolodexContact)
                            {
                                //Create a new menaged object for new rolodex contact
                                NSManagedObject* managedObject = [[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPRolodexContact"];
                                if ([managedObject isKindOfClass:[HOPRolodexContact class]])
                                {
                                    rolodexContact = (HOPRolodexContact*)managedObject;
                                    HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
                                    HOPAssociatedIdentity* associatedIdentity = [[HOPModelManager sharedModelManager] getAssociatedIdentityBaseIdentityURI:idFedBaseURI homeUserStableId:homeUser.stableId];
                                    rolodexContact.associatedIdentity = associatedIdentity;
                                    rolodexContact.identityURI = identityURI;
                                    rolodexContact.name = fullNameTemp;
                                    [[HOPModelManager sharedModelManager] saveContext];
                                }
                            }
                        
                            if (rolodexContact)
                                [contactsForIdentityLookup addObject:rolodexContact];
                        });
                    }
                }
                CFRelease(allPeopleRef);
            }
            CFRelease(addressBookRef);
        }
        OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelTrace, @"Finished loading contacts from the address book.");
    }
    
    HOPIdentityLookup* identityLookup = [[HOPIdentityLookup alloc] initWithDelegate:(id<HOPIdentityLookupDelegate>)[[OpenPeer sharedOpenPeer] identityLookupDelegate] identityLookupInfos:contactsForIdentityLookup identityServiceDomain:idProviderDomain];
    
    if (identityLookup)
        [self.identityLookupsArray addObject:identityLookup];
}

/**
 * Initiates contacts loading procedure. Once done [CDVOP onContactsLoaded] will be fired
 */
- (void) loadContacts
{
    OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelDebug, @"Init loading contacts");
    
    // For the first login and association, downloading contacts for the newly associated identity
    NSArray* associatedIdentities = [[HOPAccount sharedAccount] getAssociatedIdentities];
    
    for (HOPIdentity* identity in associatedIdentities)
    {
        if (![self.setOfIdentitiesWhoseContactsDownloadInProgress containsObject:[identity getIdentityURI]])
        {
            [self.setOfIdentitiesWhoseContactsDownloadInProgress addObject:[identity getIdentityURI]];
            if (![identity isDelegateAttached])
                [[LoginManager sharedLoginManager] attachDelegateForIdentity:identity forceAttach:NO];
            
            /*
            if ([[identity getBaseIdentityURI] isEqualToString:[[Settings sharedSettings] identityFederateBaseURI]])
            {
                dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(taskQ, ^{
                    [self loadAddressBookContacts];
                });
            }
            else if ([[identity getBaseIdentityURI] isEqualToString:identityFacebookBaseURI])
            {*/
                HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
                HOPAssociatedIdentity* associatedIdentity = [[HOPModelManager sharedModelManager] getAssociatedIdentityBaseIdentityURI:[identity getBaseIdentityURI] homeUserStableId:homeUser.stableId];
                [identity startRolodexDownload:associatedIdentity.downloadedVersion];
                OPLog(HOPLoggerSeverityInformational, HOPLoggerLevelDebug, @"Start rolodex contacts download - identity URI: - Version: %@",[identity getIdentityURI], associatedIdentity.downloadedVersion);
            //}
        }
    }
    
}

- (void) refreshExisitngContacts
{
    NSArray* associatedIdentities = [[HOPAccount sharedAccount] getAssociatedIdentities];
    
    for (HOPIdentity* identity in associatedIdentities)
    {
        NSArray* rolodexContactsForRefresh = [[HOPModelManager sharedModelManager] getRolodexContactsForRefreshByHomeUserIdentityURI:[identity getIdentityURI] lastRefreshTime:[NSDate date]];
        
        if ([rolodexContactsForRefresh count] > 0)
            [self identityLookupForContacts:rolodexContactsForRefresh identityServiceDomain:[identity getIdentityProviderDomain]];
    }
}

- (void) refreshRolodexContacts
{
    NSArray* associatedIdentities = [[HOPAccount sharedAccount] getAssociatedIdentities];
    
    for (HOPIdentity* identity in associatedIdentities)
    {
        if (![self.setOfIdentitiesWhoseContactsDownloadInProgress containsObject:[identity getIdentityURI]])
        {
            [self.setOfIdentitiesWhoseContactsDownloadInProgress addObject:[identity getIdentityURI]];
            [identity refreshRolodexContacts];
        }
    }
}

/**
 Check contact identites against openpeer database.
 @param contacts NSArray List of contacts.
 */
- (void) identityLookupForContacts:(NSArray *)contacts identityServiceDomain:(NSString*) identityServiceDomain
{
    HOPIdentityLookup* identityLookup = [[HOPIdentityLookup alloc] initWithDelegate:(id<HOPIdentityLookupDelegate>)[[OpenPeer sharedOpenPeer] identityLookupDelegate] identityLookupInfos:contacts identityServiceDomain:identityServiceDomain];
    
    if (identityLookup)
        [self.identityLookupsArray addObject:identityLookup];
}

/**
 * Handles response received from lookup server.
 */
-(void)updateContactsWithDataFromLookup:(HOPIdentityLookup *)identityLookup
{
    BOOL refreshContacts = NO;
    NSError* error;
    if ([identityLookup isComplete:&error])
    {
        HOPIdentityLookupResult* result = [identityLookup getLookupResult];
        if ([result wasSuccessful])
        {
            NSArray* identityContacts = [identityLookup getUpdatedIdentities];
            
            refreshContacts = [identityContacts count] > 0 ? YES : NO;
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (refreshContacts)
        {
            [[CDVOP sharedObject] fireEventWithData:@"onIdentityLookupComplete" data:@"{}"];
            //[[CDVOP sharedObject] onContactsLoaded:[self getContactsList:self.avatarWidth onlyOPContacts:self.onlyOPContacts]];
        }
     });

    [self.identityLookupsArray removeObject:identityLookup];
}

- (BOOL) checkIsContactValid:(HOPContact*) contact
{
    BOOL ret = NO;
    NSArray* rolodexContacts = [[HOPModelManager sharedModelManager] getRolodexContactsByPeerURI:[contact getPeerURI]];
    ret = [rolodexContacts count] > 0;
    return ret;
}

- (NSArray*) getBaseURIsForStableId:(NSString*) stableID
{
    NSMutableArray* ret = nil;
    
    NSArray* identityContacts = [[HOPModelManager sharedModelManager] getIdentityContactsByStableID:stableID];
    
    if ([identityContacts count] > 0)
    {
        ret = [[NSMutableArray alloc] init];
    }
    
    for (HOPIdentityContact* identityContact in identityContacts)
    {
        NSString* identityURI = identityContact.rolodexContact.identityURI;
        NSString* baseURI = [HOPUtility getBaseIdentityURIFromURI:identityURI];
        [ret addObject:baseURI];
    }
    
    return ret;
    
}
- (NSString*) createProfileBundleForCommunicationWithContact:(HOPRolodexContact*) targetContact
{
    HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
    
    NSString* ret = nil;
    NSDictionary* dictionaryProfile = nil;
    if (homeUser)
    {
        NSArray* homeUserIdentityContacts = [[HOPModelManager sharedModelManager] getIdentityContactsByStableID:homeUser.stableId];
        
        if ([homeUserIdentityContacts count] > 0)
        {
            HOPIdentityContact* identityContactWithHighestPriority = [homeUserIdentityContacts objectAtIndex:0];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            [dict setObject:identityContactWithHighestPriority.rolodexContact.name forKey:profileXmlTagName];
            
            NSMutableArray* arrayIdentities = [[NSMutableArray alloc] init];
            for (HOPIdentityContact* identityContact in homeUserIdentityContacts)
            {
                NSMutableDictionary *dictIdentitity = [[NSMutableDictionary alloc] init];
                [dictIdentitity setObject:identityContact.rolodexContact.identityURI forKey:profileXmlTagIdentity];
                [arrayIdentities addObject:dictIdentitity];
            }
            
            [dict setObject:arrayIdentities forKey:profileXmlTagIdentities];
            
            dictionaryProfile = [NSDictionary dictionaryWithObject:dict forKey:profileXmlTagProfile];}
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryProfile
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData)
    {
        OPLog(HOPLoggerSeverityWarning, HOPLoggerLevelDebug, @"JSON data serialization has failed with an error: %@", error);
    } else
    {
        ret = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    return ret;
}

/* TODO: check if we actually need this
- (HOPRolodexContact*) getRolodexContactByProfileBundle:(NSString*) profileBundle coreContact:(HOPContact*) coreContact
{
    HOPRolodexContact* ret = nil;
    NSString* name = nil;
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary* bundleDictionary = [parser objectWithString: profileBundle];
    NSDictionary* profileBundleDictionary = [bundleDictionary objectForKey:profileXmlTagProfile];
    
    if (profileBundleDictionary)
    {
        name = [profileBundleDictionary objectForKey:profileXmlTagName];
        
        //Hack because JSON doesn't pass array of one element
        NSArray* arrayIdentities = nil;
        id identities = [profileBundleDictionary objectForKey:profileXmlTagIdentities];
        if ([identities isKindOfClass:[NSArray class]])
            arrayIdentities = identities;
        else
            arrayIdentities = [NSArray arrayWithObject:identities];
        
        for (NSDictionary* dictionaryIdentity in arrayIdentities)
        {
            NSString* identityURI = [dictionaryIdentity objectForKey:profileXmlTagIdentity];
            
            HOPRolodexContact* contact = [[HOPModelManager sharedModelManager] getRolodexContactByIdentityURI:identityURI];
            if (!contact)
            {
                NSString* baseIdentityURI = [HOPUtility getBaseIdentityURIFromURI:identityURI];
                
                HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
                HOPAssociatedIdentity* associatedIdentity = [[HOPModelManager sharedModelManager] getAssociatedIdentityBaseIdentityURI:baseIdentityURI homeUserStableId:homeUser.stableId];
                
                if (!associatedIdentity)
                {
                    NSManagedObject* managedObject = [[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPAssociatedIdentity"];
                    
                    if ([managedObject isKindOfClass:[HOPAssociatedIdentity class]])
                    {
                        associatedIdentity = (HOPAssociatedIdentity*) managedObject;
                        associatedIdentity.baseIdentityURI = baseIdentityURI;
                        associatedIdentity.name = baseIdentityURI;
                        associatedIdentity.domain = [[Settings sharedSettings] getIdentityProviderDomain];
                        
                        [[HOPModelManager sharedModelManager] saveContext];
                    }
                }
                
                NSManagedObject* managedObject = [[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPRolodexContact"];
                if ([managedObject isKindOfClass:[HOPRolodexContact class]])
                {
                    contact = (HOPRolodexContact*)managedObject;
                    contact.name = name;
                    contact.identityURI = identityURI;
                    contact.associatedIdentity = associatedIdentity;
                    HOPRolodexContact* homeUserRolodexContact = [[[HOPModelManager sharedModelManager] getLastLoggedInHomeUser] getRolodexContactForIdentityBaseURI:[HOPUtility getBaseIdentityURIFromURI:identityURI]];
                    NSString* homeUserIdentityURI = homeUserRolodexContact ? homeUserRolodexContact.identityURI : nil;
                    [contact updateWithName:name identityURI:identityURI identityProviderDomain:[[Settings sharedSettings] getIdentityProviderDomain] homeUserIdentityURI:homeUserIdentityURI];
                    
                    [[HOPModelManager sharedModelManager] saveContext];
                }
            }
            
            if (!contact.identityContact)
            {
                NSManagedObject* managedObject = [[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPIdentityContact"];
                if ([managedObject isKindOfClass:[HOPIdentityContact class]])
                {
                    HOPIdentityContact* hopIdentityContact = (HOPIdentityContact*)managedObject;
                    
                    NSManagedObject* managedObject = [[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPPublicPeerFile"];
                    if ([managedObject isKindOfClass:[HOPPublicPeerFile class]])
                    {
                        HOPPublicPeerFile* hopPublicPeerFile = (HOPPublicPeerFile*)managedObject;
                        hopPublicPeerFile.peerURI = [coreContact getPeerURI];
                        hopPublicPeerFile.peerFile = [coreContact getPeerFilePublic];
                        hopIdentityContact.peerFile = hopPublicPeerFile;
                    }
                    contact.identityContact = hopIdentityContact;
                    [[HOPModelManager sharedModelManager] saveContext];
                }
            }
            
            //Return first rolodex contact with highest priority
            if (!ret)
                ret = contact;
        }

    }
    return ret;
}
*/

/**
 * Get a list of all contacts for currently logged in user, in a dictionary ready to pass to JS
 * @param identity the identity to get the contacts for
 * @precondition: loading contacts has already finished
 * @precondition avatarWidth and onlyOPContacts preferences are set
 */
- (NSMutableDictionary*) getContactsDictionaryForJS:(HOPIdentity*) identity {
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    HOPModelManager* modelManager = [HOPModelManager sharedModelManager];
    NSArray* rolodexContacts;

    NSString* identityURI = [identity getIdentityURI];
    NSString* identityDomain = [identity getIdentityProviderDomain];

    if (self.onlyOPContacts) {
        rolodexContacts = [modelManager getRolodexContactsForHomeUserIdentityURI:identityURI openPeerContacts:YES];
    } else {
        rolodexContacts = [modelManager getAllRolodexContactForHomeUserIdentityURI:identityURI];
    }

    [[ContactsManager sharedContactsManager] identityLookupForContacts:rolodexContacts identityServiceDomain:identityDomain];
    
    for (HOPRolodexContact* contact in rolodexContacts) {

        // TODO: fix this when avatar path can be obtained by size
        HOPAvatar* hopAvatar = [contact getAvatarForWidth:self.avatarWidth height:self.avatarWidth];

        NSString* isRegistered = ([contact identityContact] != nil) ? @"true" : @"false";
        
        NSDictionary* cDict = [[NSDictionary alloc] initWithObjectsAndKeys:contact.name, @"name", hopAvatar.url, @"avatarUrl", isRegistered, @"isRegistered", nil];
        [ret setObject:cDict forKey:contact.identityURI];
    }
    
    return ret;
}

- (NSArray*) getIdentityContactsForHomeUser
{
    NSMutableArray* ret = nil;
    NSArray* identities = [[HOPAccount sharedAccount] getAssociatedIdentities];
    
    if ([identities count] > 0)
        ret = [[NSMutableArray alloc] init];
    
    for (HOPIdentity* identity in identities)
    {
        HOPIdentityContact* identityContact = [identity getSelfIdentityContact];
        if (identityContact)
            [ret addObject:identityContact];
    }
    
    return ret;
}

- (void) removeAllContacts
{
    
}
@end
