//
//  STGTMapViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 5/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTMapViewController.h"
#import "STGTSettingsController.h"
#import "YMKMapView+custom.h"
#import "MKMapView+custom.h"
#import "Protocols/STMapViewControllable.h"
#import "STGTLocation.h"
#import "YMapKey.h"

@interface STGTMapViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) id <STMapViewControllable> mapView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STGTMapViewController

- (NSFetchedResultsController *)resultsController {
    if (!_resultsController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"STGTTrack"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO selector:@selector(compare:)]];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.currentSession.document.managedObjectContext sectionNameKeyPath:@"dayAsString" cacheName:nil];
        _resultsController.delegate = self;
    }
    return _resultsController;
}

- (NSMutableDictionary *)settings {
    if (!_settings) {
        _settings = [[(id <STSession>)self.currentSession settingsController] currentSettingsForGroup:@"map"];
        for (NSString *settingName in [_settings allKeys]) {
            [_settings addObserver:self forKeyPath:settingName options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
        }
    }
    return _settings;
}

- (void)setCurrentSession:(STSession *)currentSession {
    
    if (currentSession != _currentSession) {
        _currentSession = currentSession;
        self.resultsController = nil;
        NSError *error;
        if (![self.resultsController performFetch:&error]) {
            NSLog(@"performFetch error %@", error);
        } else {
            
        }
        
        NSString *mapProvider = [self.settings valueForKey:@"mapProvider"];
        UIView *mapView;
        if ([mapProvider isEqualToString:[NSString stringWithFormat:@"%d", mapYandex]]) {
            [[YMKConfiguration sharedInstance] setApiKey:YMAPKEY];
            mapView = [[YMKMapView alloc] init];
        } else if ([mapProvider isEqualToString:[NSString stringWithFormat:@"%d", mapApple]]) {
            mapView = [[MKMapView alloc] init];
        } else {
        }
        
        if ([mapView conformsToProtocol:@protocol(STMapViewControllable)]) {
            self.view = mapView;
            self.mapView = (id <STMapViewControllable>)self.view;
        }
    }

}

- (void)mapSettingsChanged:(NSNotification *)notification {
    [self.settings addEntriesFromDictionary:notification.userInfo];
}

- (void)drawAllPaths {
    NSMutableSet *allLocations = [NSMutableSet set];
    for (STGTTrack *track in self.resultsController.fetchedObjects) {
        [allLocations unionSet:track.locations];
        
        [self drawPathWithTitle:@"track" for:track.locations];
        
    }
    
    [self drawPathWithTitle:@"allTracks" for:allLocations];
    
}

- (void)drawSelectedPath {
    
    [self drawPathWithTitle:@"selectedTrack" for:self.selectedTrack.locations];

}

- (void)redrawSelectedPath {
    
    [self.mapView removePathWithTitle:@"selectedTrack"];
    [self drawSelectedPath];
    
}

- (void)drawPathWithTitle:(NSString *)pathTitle for:(NSSet *)locationsSet {

    NSArray *locationsArray = [locationsSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]]];
    int numberOfLocations = locationsArray.count;
    CLLocationCoordinate2D coordinates[numberOfLocations];
    if (numberOfLocations > 0) {
        int i = 0;
        for (STGTLocation *location in locationsArray) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([location.latitude doubleValue], [location.longitude doubleValue]);
            coordinates[i] = coordinate;
            i++;
        }
    }
    
    [self.mapView drawPathWithCoordinates:coordinates count:numberOfLocations title:pathTitle];
    
}



- (void)setMapViewRegion {
    
    CLLocationCoordinate2D center;
    MKCoordinateSpan span;

    if (self.selectedTrack && self.selectedTrack.locations.count > 0) {
        NSArray *locationsArray = [self.selectedTrack.locations sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]]];
        STGTLocation *location = (STGTLocation *)[locationsArray objectAtIndex:0];
        
        double maxLon = [location.longitude doubleValue];
        double minLon = [location.longitude doubleValue];
        double maxLat = [location.latitude doubleValue];
        double minLat = [location.latitude doubleValue];
        
        for (STGTLocation *location in locationsArray) {
            if ([location.longitude doubleValue] > maxLon) maxLon = [location.longitude doubleValue];
            if ([location.longitude doubleValue] < minLon) minLon = [location.longitude doubleValue];
            if ([location.latitude doubleValue] > maxLat) maxLat = [location.latitude doubleValue];
            if ([location.latitude doubleValue] < minLat) minLat = [location.latitude doubleValue];
        }
        
        center.longitude = (maxLon + minLon)/2;
        center.latitude = (maxLat + minLat)/2;
        double trackScale = [[self.settings objectForKey:@"trackScale"] doubleValue];
        span.longitudeDelta = trackScale * (maxLon - minLon);
        span.latitudeDelta = trackScale * (maxLat - minLat);
        if (span.longitudeDelta == 0) {
            span.longitudeDelta = 0.01;
        }
        if (span.latitudeDelta == 0) {
            span.latitudeDelta = 0.01;
        }

    } else {
        center = [self.mapView currentUserLocation];
        span.longitudeDelta = 0.01;
        span.latitudeDelta = 0.01;
    }
    
    [self.mapView scaleMapToRegion:MKCoordinateRegionMake(center, span)];

}

- (void)trackDeleted:(NSNotification *)notification {
    
}

- (void)trackInserted:(NSNotification *)notification {
    
}

- (void)trackUpdated:(NSNotification *)notification {
    
    STGTTrack *updatedTrack = [notification.userInfo objectForKey:@"track"];
    if (updatedTrack == self.selectedTrack) {
        [self redrawSelectedPath];
    }
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapSettingsChanged:) name:@"mapSettingsChanged" object:(id <STSession>)self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDeleted:) name:@"trackDeleted" object:(id <STSession>)self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackInserted:) name:@"trackInserted" object:(id <STSession>)self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackUpdated:) name:@"trackUpdated" object:(id <STSession>)self.currentSession];
    
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackDeleted" object:self userInfo:[NSDictionary dictionaryWithObject:anObject forKey:@"track"]];


}

- (void)removeObservers {

    for (NSString *settingName in [self.settings allKeys]) {
        [self.settings removeObserver:self forKeyPath:settingName context:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mapSettingsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackInserted" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackUpdated" object:nil];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addObservers];
    if (self.mapView) {
        [self.mapView showsUserLocation:YES];
        [self setMapViewRegion];
        [self drawAllPaths];
        if (self.selectedTrack) {
            [self drawSelectedPath];
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeObservers];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        [self removeObservers];
        self.view = nil;
    }
}

@end
