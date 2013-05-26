//
//  STGTSyncer.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSyncer.h"
#import "STManagedDocument.h"
#import "STSession.h"

@interface STSyncer() <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STManagedDocument *document;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) int fetchLimit;
@property (nonatomic) double syncInterval;
@property (nonatomic, strong) NSString *syncServerURI;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic) BOOL running;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSManagedObject *syncObject;

@end

@implementation STSyncer

@synthesize syncInterval = _syncInterval;

- (id)init {
    self = [super init];
    if (self) {
//        [self startSyncer];
    }
    return self;
}

- (void)startSyncer {
    [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer start" type:@""];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChanged:) name:[NSString stringWithFormat:@"%@SettingsChanged", @"syncer"] object:[(id <STSession>)self.session settingsController]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenReceived:) name:@"tokenReceived" object: self.authDelegate];
    [self initTimer];
    self.running = YES;
}

- (void)stopSyncer {
    [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer stop" type:@""];
    self.running = NO;
    self.syncing = NO;
    [self releaseTimer];
    self.resultsController = nil;
    self.settings = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tokenReceived" object:self.authDelegate];
}

- (void)tokenReceived:(NSNotification *)notification {
    [[(STSession *)self.session logger] saveLogMessageWithText:@"Token received" type:@""];
    [self.syncTimer fire];
}

- (void) setAuthDelegate:(id <STRequestAuthenticatable>)newAuthDelegate {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tokenReceived" object: _authDelegate];
    _authDelegate = newAuthDelegate;
}

- (void)setSession:(id<STSession>)session {
    if (self.running) {
        [self stopSyncer];
    }
    _session = session;
    self.document = (STManagedDocument *)[(id <STSession>)session document];
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
    } else {
        
    }
    [self startSyncer];
}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(id <STSession>)self.session settingsController] currentSettingsForGroup:@"syncer"];
    }
    return _settings;
}

- (int)fetchLimit {
    if (!_fetchLimit) {
        _fetchLimit = [[self.settings valueForKey:@"fetchLimit"] intValue];
    }
    return _fetchLimit;
}

- (double)syncInterval {
    if (!_syncInterval) {
        _syncInterval = [[self.settings valueForKey:@"syncInterval"] doubleValue];
    }
    return _syncInterval;
}

- (void)setSyncInterval:(double)syncInterval {
    if (_syncInterval != syncInterval) {
        [self releaseTimer];
        _syncInterval = syncInterval;
        [self initTimer];
    }
}

- (NSString *)syncServerURI {
    if (!_syncServerURI) {
        _syncServerURI = [self.settings valueForKey:@"syncServerURI"];
    }
    return _syncServerURI;
}

- (NSString *)xmlNamespace {
    if (!_xmlNamespace) {
        _xmlNamespace = [self.settings valueForKey:@"xmlNamespace"];
    }
    return _xmlNamespace;
}

- (void)setSyncing:(BOOL)syncing {
    if (_syncing != syncing) {
        _syncing = syncing;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"syncStatusChanged" object:self];
//        NSString *status = _syncing ? @"start" : @"stop";
//        [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Syncer %@ syncing", status] type:@""];
    }
}

- (void)syncerSettingsChanged:(NSNotification *)notification {
    
    [self.settings addEntriesFromDictionary:notification.userInfo];
    NSString *key = [[notification.userInfo allKeys] lastObject];
    
    //    NSLog(@"%@ %@", [notification.userInfo valueForKey:key], key);
    if ([key isEqualToString:@"fetchLimit"]) {
        self.fetchLimit = [[notification.userInfo valueForKey:key] intValue];
        
    } else if ([key isEqualToString:@"syncInterval"]) {
        self.syncInterval = [[notification.userInfo valueForKey:key] doubleValue];
        
    } else if ([key isEqualToString:@"syncServerURI"]) {
        self.syncServerURI = [notification.userInfo valueForKey:key];
        
    } else if ([key isEqualToString:@"xmlNamespace"]) {
        self.xmlNamespace = [notification.userInfo valueForKey:key];
        
    }
    
}

#pragma mark - timer

- (NSTimer *)syncTimer {
    if (!_syncTimer) {
        if (!self.syncInterval) {
            _syncTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:self.syncInterval target:self selector:@selector(onTimerTick:) userInfo:nil repeats:NO];;
        } else {
            _syncTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:self.syncInterval target:self selector:@selector(onTimerTick:) userInfo:nil repeats:YES];
        }
    }
    return _syncTimer;
}

- (void)initTimer {
    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication  *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.syncTimer forMode:NSRunLoopCommonModes];
}

- (void)releaseTimer {
    [self.syncTimer invalidate];
    self.syncTimer = nil;
}

- (void)onTimerTick:(NSTimer *)timer {
//    NSLog(@"syncTimer tick at %@", [NSDate date]);
    [self syncData];
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTDatum"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sqts" ascending:YES selector:@selector(compare:)]];
        [request setIncludesSubentities:YES];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF.lts == %@ || SELF.ts > SELF.lts", nil];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"numberOfUnsyncedChanged" object:self];
    if (controller.fetchedObjects.count % self.fetchLimit == 0) {
        if (!self.syncing) {
            [self.syncTimer fire];
        }
    }
}

- (NSNumber *)numberOfUnsynced {
    return [NSNumber numberWithInt:self.resultsController.fetchedObjects.count];
}


#pragma mark - syncing

- (void)syncData {

    if (!self.syncing) {

        self.syncing = YES;

        NSUInteger count = self.resultsController.fetchedObjects.count;
        
        if (count == 0) {
            [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no data to sync" type:@""];
            [self sendData:nil toServer:self.syncServerURI];
        } else {
            
//            for (NSManagedObject *object in self.resultsController.fetchedObjects) {
//                NSLog(@"object.entity.name %@", object.entity.name);
//            }
            
            NSUInteger len = count < self.fetchLimit ? count : self.fetchLimit;
            NSRange range = NSMakeRange(0, len);
            NSArray *dataForSyncing = [self.resultsController.fetchedObjects subarrayWithRange:range];
            NSData *JSONData = [self JSONFrom:dataForSyncing];
            [self sendData:JSONData toServer:self.syncServerURI];
        }
    }

}

- (NSData *)xmlFrom:(NSArray *)dataForSyncing {
    return nil;
}

- (NSData *)JSONFrom:(NSArray *)dataForSyncing {
    
    NSMutableArray *syncDataArray = [NSMutableArray array];
    
    for (NSManagedObject *object in dataForSyncing) {
        [object setPrimitiveValue:[NSDate date] forKey:@"sts"];
        NSMutableDictionary *objectDictionary = [self dictionaryForObject:object];
        NSMutableDictionary *propertiesDictionary = [self propertiesDictionaryForObject:object];
        
        [objectDictionary setObject:propertiesDictionary forKey:@"properties"];
        [syncDataArray addObject:objectDictionary];
    }
    
    NSDictionary *dataDictionary = [NSDictionary dictionaryWithObject:syncDataArray forKey:@"data"];
    
    NSError *error;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&error];
//    NSLog(@"JSONData %@", JSONData);

    return JSONData;
}

- (NSMutableDictionary *)dictionaryForObject:(NSManagedObject *)object {
    
    NSString *name = [[object entity] name];
    NSString *xid = [NSString stringWithFormat:@"%@", [object valueForKey:@"xid"]];
    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
    xid = [[xid stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:name, @"name", xid, @"xid", nil];

}

- (NSMutableDictionary *)propertiesDictionaryForObject:(NSManagedObject *)object {
    
    NSMutableDictionary *propertiesDictionary = [NSMutableDictionary dictionary];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:object.entity.name inManagedObjectContext:self.document.managedObjectContext];
    NSArray *entityProperties = [entityDescription.propertiesByName allKeys];
    for (NSString *propertyName in entityProperties) {
        
        if (!([propertyName isEqualToString:@"xid"]||[propertyName isEqualToString:@"sqts"]||[propertyName isEqualToString:@"lts"])) {
            id value = [object valueForKey:propertyName];
            if (value) {
                if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
                    //                        value = value;
                    
                } else if ([value isKindOfClass:[NSDate class]] || [value isKindOfClass:[NSData class]]) {
                    value = [NSString stringWithFormat:@"%@", value];
                    
                } else if ([value isKindOfClass:[NSManagedObject class]]) {
                    if ([value valueForKey:@"xid"]) {
                        value = [self dictionaryForObject:value];
                    }
                    
                } else if ([value isKindOfClass:[NSSet class]]) {
                    NSRelationshipDescription *inverseRelationship = [[entityDescription.relationshipsByName objectForKey:propertyName] inverseRelationship];
                    
                    if ([inverseRelationship isToMany]) {
                        NSMutableArray *childrenArray = [NSMutableArray array];
                        for (NSManagedObject *childObject in value) {
                            [childrenArray addObject:[self dictionaryForObject:childObject]];
                        }
                        value = childrenArray;
                    }
                } else {
                    value = [NSNull null];
                }
                [propertiesDictionary setObject:value forKey:propertyName];
            }
        }
    }
    return propertiesDictionary;
    
}

- (void)sendData:(NSData *)requestData toServer:(NSString *)serverUrlString {
    NSURL *requestURL = [NSURL URLWithString:serverUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    if (!requestData) {
        [request setHTTPMethod:@"GET"];
        //        NSLog(@"GET");
    } else {
        //        NSLog(@"POST");
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:requestData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    }
    
//    request = [[self.authDelegate authenticateRequest:(NSURLRequest *) request] mutableCopy];
    [request setValue:@"393763d6-c20b-46ad-be8a-1d911eb8ddbe" forHTTPHeaderField:@"Authorization"];
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!connection) {
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
            self.syncing = NO;
        } else {

        }
    } else {
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no authorization header" type:@"error"];
        self.syncing = NO;
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.syncing = NO;
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    [[(STSession *)self.session logger] saveLogMessageWithText:errorMessage type:@"error"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}



- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"connectionDidFinishLoading responseData %@", responseString);
    
    NSError *error;
    id responseJSON = [NSJSONSerialization JSONObjectWithData:self.responseData options:nil error:&error];

    if (![responseJSON isKindOfClass:[NSDictionary class]]) {
        
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Response is not dictionary" type:@"error"];
        self.syncing = NO;
        
    } else {
        
        NSString *errorString = [(NSDictionary *)responseJSON valueForKey:@"error"];
        
        if (![errorString isEqualToString:@"ok"]) {
            
            [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"Response error: %@", errorString] type:@"error"];
            self.syncing = NO;
            
        } else {
            
            id objectsArray = [(NSDictionary *)responseJSON valueForKey:@"data"];
            
            if ([objectsArray isKindOfClass:[NSArray class]]) {
                
                for (id object in (NSArray *)objectsArray) {
                    
                    NSLog(@"object %@", object);
                    if (![object isKindOfClass:[NSDictionary class]]) {
                        
                        [[(STSession *)self.session logger] saveLogMessageWithText:@"Object is not dictionary" type:@"error"];
                        self.syncing = NO;
                        break;
                        
                    } else {
                        
                        [self syncObject:(NSDictionary *)object];
                        
                    }
                    
                }
                
            }
            
        }
        
    }

    
    

//            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
//                //                NSLog(@"setSynced UIDocumentSaveForOverwriting success");
//                if ([self.session isKindOfClass:[STGTSession class]]) {
//                    [[(STGTSession *)self.session tracker] setTrackerStatus:@""];
//                }
//                //                self.tracker.trackerStatus = @"";
                self.syncing = NO;
//
//                if (![[[connection currentRequest] HTTPMethod] isEqualToString:@"GET"]) {
//                    if (self.resultsController.fetchedObjects.count > 0) {
//                        //                        NSLog(@"fetchedObjects.count > 0");
//                        [self dataSyncing];
//                    } else {
//                        //                        NSLog(@"fetchedObjects.count <= 0");
//                        self.syncing = YES;
//                        [self sendData:nil toServer:self.settings.syncServerURI];
//                    }
//                } else {
//                    if ([[(STGTSession *)self.session status] isEqualToString:@"finishing"]) {
//                        if (self.resultsController.fetchedObjects.count == 0) {
//                            [self stopSyncer];
//                            [[STGTSessionManager sharedManager] sessionCompletionFinished:self.session];
//                        } else {
//                            [self dataSyncing];
//                        }
//                    }
//                }
//                
//            }];
//            
//        }
//        
//    }
//    
//    
    
}

- (void)syncObject:(NSDictionary *)object {
    
    NSString *result = [(NSDictionary *)object valueForKey:@"result"];
    NSString *name = [(NSDictionary *)object valueForKey:@"name"];
    NSString *xid = [(NSDictionary *)object valueForKey:@"xid"];
    
    if (![result isEqualToString:@"ok"]) {
        
        [[(STSession *)self.session logger] saveLogMessageWithText:[NSString stringWithFormat:@"result not ok xid: %@", xid] type:@"error"];
        
    } else {
        
        NSString *xidString = [xid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSMutableData *xidData = [NSMutableData data];
        int i;
        for (i = 0; i+2 <= xidString.length; i+=2) {
            NSRange range = NSMakeRange(i, 2);
            NSString* hexString = [xidString substringWithRange:range];
            NSScanner* scanner = [NSScanner scannerWithString:hexString];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            [xidData appendBytes:&intValue length:1];
        }

        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        if ([name isEqualToString:@"STSettings"]) {
            request.predicate = nil;
        } else {
            request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", xidData];
        }
        
        NSError *error;
        NSArray *fetchResult = [self.document.managedObjectContext executeFetchRequest:request error:&error];
        
        if ([fetchResult lastObject]) {
            
            self.syncObject = [fetchResult lastObject];
            [self.syncObject setValue:[self.syncObject valueForKey:@"sts"] forKey:@"lts"];
            NSLog(@"xid %@", xid);
            
        } else {
            
            self.syncObject = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.document.managedObjectContext];
            [self.syncObject setValue:xid forKey:@"xid"];
            [self.syncObject setValue:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"lts"];
            NSLog(@"insertNewObjectForEntity");
            
        }
        
        
    }
    
}


//
//                    if ([entityName isEqualToString:@"STGTSpot"]) {
//                        STGTSpot *spot = (STGTSpot *)self.syncObject;
//                        NSArray *itemProperties = [entityItem nodesForXPath:@"./ns:d" namespaces:namespaces error:nil];
//
//                        for (GDataXMLElement *itemProperty in itemProperties) {
//                            //                    NSLog(@"itemProperty %@", itemProperty);
//                            NSString *propertyName = [[[itemProperty nodesForXPath:@"./@name" error:nil] lastObject] stringValue];
//                            NSString *propertyXid = [[[itemProperty nodesForXPath:@"./@xid" error:nil] lastObject] stringValue];
//
//                            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:propertyName];
//                            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
//                            request.predicate = [NSPredicate predicateWithFormat:@"SELF.xid == %@", propertyXid];
//                            NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:&error];
//                            NSManagedObject *property;
//
//                            if ([result lastObject]) {
//                                property = [result lastObject];
//                                //                        NSLog(@"result lastObject");
//                            } else {
//                                property = [NSEntityDescription insertNewObjectForEntityForName:propertyName inManagedObjectContext:self.document.managedObjectContext];
//                                [property setValue:propertyXid forKey:@"xid"];
//                                [property setValue:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"lts"];
//                                //                        NSLog(@"insertNewObjectForEntity");
//                            }
//
//                            if ([propertyName isEqualToString:@"STGTInterest"]) {
//                                [spot addInterestsObject:(STGTInterest *)property];
//                            } else if ([propertyName isEqualToString:@"STGTNetwork"]) {
//                                [spot addNetworksObject:(STGTNetwork *)property];
//                            }
//
//                        }
//                    }
//
//
//                    //                    NSString *timestamp = [[[entityItem nodesForXPath:@"./ns:date[@name='ts']" namespaces:namespaces error:nil] lastObject] stringValue];
//                    //
//                    //                    if (timestamp) {
//
//                    //                        NSLog(@"server.timestamp %@", timestamp);
//
//                    //                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    //                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
//                    //                        NSDate *serverDate = [dateFormatter dateFromString:timestamp];
//                    //                        NSDate *localDate = [self.syncObject valueForKey:@"lts"];
//                    NSDate *lts = [self.syncObject valueForKey:@"lts"];
//                    NSDate *ts = [self.syncObject valueForKey:@"ts"];
//
//                    //                    NSLog(@"lts %@, ts %@", lts, ts);
//
//                    //            NSLog(@"serverDate %@", serverDate);
//                    //            NSLog(@"localDate %@", localDate);
//
//                    if (!lts || [lts compare:ts] == NSOrderedDescending) {
//
//                        //                        NSLog(@"lts > ts");
//
//                        NSArray *entityItemProperties = [entityItem nodesForXPath:@"./ns:*" namespaces:namespaces error:nil];
//                        for (GDataXMLElement *entityItemProperty in entityItemProperties) {
//                            //                    NSLog(@"entityItemProperty %@", [entityItemProperty name]);
//
//                            NSString *type = [entityItemProperty name];
//                            NSString *name = [[[entityItemProperty nodesForXPath:@"./@name" error:nil] lastObject] stringValue];
//                            NSString *value = entityItemProperty.stringValue;
//
//                            if ([[self.syncObject.entity.propertiesByName allKeys] containsObject:name]) {
//
//                                if ([type isEqualToString:@"string"]) {
//                                    [self.syncObject setValue:value forKey:name];
//                                } else if ([type isEqualToString:@"double"]) {
//                                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//                                    [numberFormatter setDecimalSeparator:@"."];
//                                    NSNumber *number = [numberFormatter numberFromString:value];
//                                    [self.syncObject setValue:number forKey:name];
//                                } else if ([type isEqualToString:@"png"] && ![value isEqualToString:@"text too large"]) {
//                                    NSCharacterSet *charsToRemove = [NSCharacterSet characterSetWithCharactersInString:@"< >"];
//                                    NSString *dataString = [[value stringByTrimmingCharactersInSet:charsToRemove] stringByReplacingOccurrencesOfString:@" " withString:@""];
//                                    //                        NSLog(@"dataString %@", dataString);
//                                    NSMutableData *data = [NSMutableData data];
//                                    int i;
//                                    for (i = 0; i+2 <= dataString.length; i+=2) {
//                                        NSRange range = NSMakeRange(i, 2);
//                                        NSString* hexString = [dataString substringWithRange:range];
//                                        NSScanner* scanner = [NSScanner scannerWithString:hexString];
//                                        unsigned int intValue;
//                                        [scanner scanHexInt:&intValue];
//                                        [data appendBytes:&intValue length:1];
//                                    }
//                                    [self.syncObject setValue:data forKey:name];
//                                }
//
//                            }
//
//                        }
//                        //                        [self.syncObject setValue:[NSDate date] forKey:@"ts"];
//                        [self.syncObject setValue:[NSDate date] forKey:@"lts"];
//
//                    } else {
//                        //                        NSLog(@"lts <= ts");
//                    }
//
//                    //                    }
//
//
//                    //                    [self.syncObject setValue:[NSDate date] forKey:@"lts"];
//
//
//                    //                    NSLog(@"self.syncObject after %@", self.syncObject);
//
//                }
//            }


@end
