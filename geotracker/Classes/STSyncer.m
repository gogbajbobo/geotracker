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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChange:) name:[NSString stringWithFormat:@"%@SettingsChange", @"syncer"] object:[(id <STSession>)self.session settingsController]];
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

- (void)syncerSettingsChange:(NSNotification *)notification {
    
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
    [[NSRunLoop currentRunLoop] addTimer:self.syncTimer forMode:NSDefaultRunLoopMode];
}

- (void)releaseTimer {
    [self.syncTimer invalidate];
    self.syncTimer = nil;
}

- (void)onTimerTick:(NSTimer *)timer {
//    NSLog(@"timer tick at %@", [NSDate date]);
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
            [self sendData:[self xmlFrom:dataForSyncing] toServer:self.syncServerURI];
        }
    }

}

- (NSData *)xmlFrom:(NSArray *)dataForSyncing {
    return nil;
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
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    }
    
    request = [[self.authDelegate authenticateRequest:(NSURLRequest *) request] mutableCopy];
    if ([request valueForHTTPHeaderField:@"Authorization"]) {
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (!connection) {
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no connection" type:@"error"];
            self.syncing = NO;
        }
    } else {
        [[(STSession *)self.session logger] saveLogMessageWithText:@"Syncer no authorization header" type:@"error"];
        self.syncing = NO;
    }
}

@end
