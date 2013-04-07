//
//  STGTSyncer.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STSyncer.h"
#import "STManagedDocument.h"

@interface STSyncer() <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STManagedDocument *document;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic) int fetchLimit;
@property (nonatomic) double syncInterval;
@property (nonatomic, strong) NSString *syncServerURI;
@property (nonatomic, strong) NSString *xmlNamespace;
@property (nonatomic, strong) NSTimer *syncTimer;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STSyncer

@synthesize syncInterval = _syncInterval;

- (id)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStatusChanged:) name:@"sessionStatusChanged" object:self.session];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerSettingsChange:) name:[NSString stringWithFormat:@"%@SettingsChange", @"syncer"] object:[(id <STSession>)self.session settingsController]];
}

- (void)setSession:(id<STSession>)session {
    _session = session;
    self.resultsController = nil;
    self.document = (STManagedDocument *)[(id <STSession>)session document];
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
    } else {
        
    }

}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(id <STSession>)self.session settingsController] currentSettingsForGroup:@"syncer"];
    }
    return _settings;
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
}

- (void)onTimerTick:(NSTimer *)timer {
    //    NSLog(@"timer tick at %@", [NSDate date]);
    [self dataSyncing];
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


- (void)dataSyncing {
    
}

@end
