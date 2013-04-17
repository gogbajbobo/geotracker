//
//  STGTMainViewController.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/4/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTMainViewController.h"
#import "STGTRoundedCornerView.h"
#import "STSessionManager.h"
#import "STGTInfoViewController.h"
#import "STGTSettingsTableViewController.h"

@interface STGTMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *spotsButton;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIButton *logButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *geoIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *batteryIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *syncIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackInfo;
@property (weak, nonatomic) IBOutlet UILabel *currentTrackStartTime;
@property (weak, nonatomic) IBOutlet UILabel *todaySummary;
@property (weak, nonatomic) IBOutlet UILabel *todaySummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *syncLabel;
@property (weak, nonatomic) IBOutlet STGTRoundedCornerView *todaySummaryView;


@end

@implementation STGTMainViewController


- (STSession *)currentSession {
    if (!_currentSession) {
        NSString *currentSessionUID = [[STSessionManager sharedManager] currentSessionUID];
        _currentSession = [[[STSessionManager sharedManager] sessions] objectForKey:currentSessionUID];
    }
    return _currentSession;
}

#pragma mark - buttons

- (IBAction)startButtonPressed:(id)sender {
    if (self.currentSession.locationTracker.tracking) {
        [self.currentSession.locationTracker stopTracking];
    } else {
        [self.currentSession.locationTracker startTracking];
    }
}

- (IBAction)logButtonPressed:(id)sender {
    UITableViewController *logTVC = [[UITableViewController alloc] init];
    logTVC.tableView.delegate = self.currentSession.logger;
    logTVC.tableView.dataSource = self.currentSession.logger;
    [self.navigationController pushViewController:logTVC animated:YES];
}

- (IBAction)syncButtonPressed:(id)sender {
    [self.currentSession.syncer syncData];
}

- (IBAction)settingsButtonPressed:(id)sender {
    STGTSettingsTableViewController *settingsTVC = [[STGTSettingsTableViewController alloc] init];
    settingsTVC.session = self.currentSession;
    [self.navigationController pushViewController:settingsTVC animated:YES];
}


#pragma mark - view behavior

- (void)locationTrackingStart {
    [self.startButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [self startAnimationOfView:self.geoIndicatorView];
}

- (void)locationTrackingStop {
    [self.startButton setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [self stopAnimationOfView:self.geoIndicatorView];
}

- (void)batteryTrackingStart {
    [self startAnimationOfView:self.batteryIndicatorView];
}

- (void)batteryTrackingStop {
    [self stopAnimationOfView:self.batteryIndicatorView];
}

- (void)startAnimationOfView:(UIView *)view {
    [UIView animateWithDuration:1.0 delay:0.0 options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self stopAnimationOfView:view];
    }];
}

- (void)stopAnimationOfView:(UIView *)view {
    [UIView animateWithDuration:1.0 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {

    }];
}

- (void)startAnimationOfSyncer:(UIView *)view {
    [UIView animateWithDuration:2.0 delay:0.0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveLinear) animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        view.transform = transform;
    } completion:^(BOOL finished) {
        [self stopAnimationOfSyncer:view];
    }];
}

- (void)stopAnimationOfSyncer:(UIView *)view {
    [UIView animateWithDuration:2.0 delay:0.0 options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear) animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        view.transform = transform;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)numberOfUnsyncedChanged {
    self.syncLabel.text = [[self.currentSession.syncer numberOfUnsynced] stringValue];
}

- (void)trackControllerDidChangeContent {

    [self updateLabels];
    
}

- (void)updateLabels {
    
    NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
    [startDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [startDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    double overallDistance = [[self.trackController.currentTrackInfo valueForKey:@"overallDistance"] doubleValue];
    double averageSpeed = [[self.trackController.currentTrackInfo valueForKey:@"averageSpeed"] doubleValue];
    NSDate *startDate = [self.trackController.currentTrackInfo valueForKey:@"startTime"];
    
    if (!startDate) {
        self.currentTrackStartTime.text = @"";
    } else {
        self.currentTrackStartTime.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"START AT", @""), [startDateFormatter stringFromDate:startDate]];
    }
    self.currentTrackInfo.text = [NSString stringWithFormat:@"%.2f %@, %.1f %@", overallDistance/1000, NSLocalizedString(@"KM", @""), averageSpeed, NSLocalizedString(@"KM/H", @"")];

    overallDistance = [[self.trackController.todaySummaryInfo valueForKey:@"overallDistance"] doubleValue];
    averageSpeed = [[self.trackController.todaySummaryInfo valueForKey:@"averageSpeed"] doubleValue];
    int numberOfTracks = [[self.trackController.todaySummaryInfo valueForKey:@"numberOfTracks"] intValue];
    
    NSString *keyString;
    if (numberOfTracks >= 11 && numberOfTracks <= 19) {
        keyString = @"5TRACKS";
    } else {
        int switchNumber = numberOfTracks % 10;
        switch (switchNumber) {
            case 1:
                keyString = @"1TRACKS";
                break;
            case 2:
            case 3:
            case 4:
                keyString = @"2TRACKS";
                break;
            default:
                keyString = @"5TRACKS";
                break;
        }
    }

    self.todaySummary.text = [NSString stringWithFormat:@"%.2f %@, %.1f %@, %d %@", overallDistance/1000, NSLocalizedString(@"KM", @""), averageSpeed, NSLocalizedString(@"KM/H", @""), numberOfTracks, NSLocalizedString(keyString, @"")];
}

- (void)syncStatusChanged {
    NSLog(@"syncer.syncing %d", self.currentSession.syncer.syncing);
    self.syncButton.enabled = !self.currentSession.syncer.syncing;
    if (self.syncButton.enabled) {
        [self stopAnimationOfSyncer:self.syncButton.imageView];
    } else {
        [self startAnimationOfSyncer:self.syncButton.imageView];
    }
}

- (void)syncerErrorLogMessageRecieved {
    self.syncIndicatorView.alpha = 1;
    self.syncIndicatorView.image = [UIImage imageNamed:@"warning.png"];
}

- (void)syncerErrorLogMessageGone {
    self.syncIndicatorView.alpha = 1;
    self.syncIndicatorView.image = [UIImage imageNamed:@"ok.png"];    
}

- (void)todaySummaryTap {
    UITableViewController *trackTVC = [[UITableViewController alloc] init];
    self.trackController.tableView = trackTVC.tableView;
    trackTVC.tableView.delegate = self.trackController;
    trackTVC.tableView.dataSource = self.trackController;
    [self.navigationController pushViewController:trackTVC animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showInfoView"]) {
        if ([segue.destinationViewController isKindOfClass:[STGTInfoViewController class]]) {
            [(STGTInfoViewController *)segue.destinationViewController setCurrentSession:self.currentSession];
        }
    }

}


#pragma mark - init view

- (void)initView {
    
    [self addNotificationsObservers];
    
    self.title = NSLocalizedString(@"TRACKER", @"");
    
    [self initViews];
    [self initButtonsImage];
    [self initIndicators];
    [self checkSessionState];

}

- (void)initViews {
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todaySummaryTap)];
    [self.todaySummaryView addGestureRecognizer:tap];
}

- (void)initButtonsImage {

    [self.settingsButton setImage:[UIImage imageNamed:@"gear.png"] forState:UIControlStateNormal];
    [self.spotsButton setImage:[UIImage imageNamed:@"spot.png"] forState:UIControlStateNormal];
    [self.infoButton setImage:[UIImage imageNamed:@"info.png"] forState:UIControlStateNormal];
    [self.syncButton setImage:[UIImage imageNamed:@"sync.png"] forState:UIControlStateNormal];
    [self.startButton setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
    [self.logButton setImage:[UIImage imageNamed:@"log.png"] forState:UIControlStateNormal];

}

- (void)initIndicators {
    self.geoIndicatorView.alpha = 0;
    self.batteryIndicatorView.alpha = 0;
    self.syncIndicatorView.alpha = 0;
    self.syncLabel.text = @"";
    self.todaySummaryLabel.text = NSLocalizedString(@"TODAY SUMMARY", @"");
    self.todaySummary.text = @"";
    self.currentTrackInfo.text = @"";
    self.currentTrackStartTime.text = @"";
}

- (void)checkSessionState {
    
    if ([self.currentSession.status isEqualToString:@"running"]) {

        if (!self.trackController) {
            self.trackController = [[STGTTrackController alloc] init];
        }
        self.trackController.currentSession = self.currentSession;

        self.settingsButton.enabled = [[[self.currentSession.settingsController currentSettingsForGroup:@"general"] valueForKey:@"localAccessToSettings"] boolValue];
        self.spotsButton.enabled = YES;
        self.infoButton.enabled = YES;
        self.logButton.enabled = YES;
        self.syncButton.enabled = !self.currentSession.syncer.syncing;
        self.startButton.enabled = !self.currentSession.locationTracker.trackerAutoStart;
        if (self.currentSession.locationTracker.tracking) {
            [self locationTrackingStart];
        }
        if (self.currentSession.batteryTracker.tracking) {
            [self batteryTrackingStart];
        }
        [self updateLabels];
    } else {
        [self disableButtons];
    }
}

- (void)disableButtons {
    self.settingsButton.enabled = NO;
    self.spotsButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.syncButton.enabled = NO;
    self.startButton.enabled = NO;
    self.logButton.enabled = NO;    
}
     
- (void)currentSessionChanged:(NSNotification *)notification {
    NSString *currentSessionUID = [[STSessionManager sharedManager] currentSessionUID];
    if (currentSessionUID) {
        self.currentSession = [[[STSessionManager sharedManager] sessions] objectForKey:currentSessionUID];
        [self checkSessionState];
    } else {
        self.currentSession = nil;
        [self disableButtons];
    }
}

#pragma mark - view lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkSessionState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if ([self isViewLoaded] && [self.view window] == nil) {
        [self removeNotificationsObservers];
        [self releaseWeakProperties];
        self.view = nil;
    }
}

- (void)addNotificationsObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSessionChanged:) name:@"currentSessionChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSessionState) name:@"sessionStatusChanged" object:self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSessionState) name:@"settingsChanged" object:self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationTrackingStart) name:@"locationTrackingStart" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationTrackingStop) name:@"locationTrackingStop" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryTrackingStart) name:@"batteryTrackingStart" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryTrackingStop) name:@"batteryTrackingStop" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackControllerDidChangeContent) name:@"trackControllerDidChangeContent" object:self.trackController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberOfUnsyncedChanged) name:@"numberOfUnsyncedChanged" object:self.currentSession.syncer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStatusChanged) name:@"syncStatusChanged" object:self.currentSession.syncer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerErrorLogMessageRecieved) name:@"syncerErrorLogMessageRecieved" object:self.currentSession.logger];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncerErrorLogMessageGone) name:@"syncerErrorLogMessageGone" object:self.currentSession.logger];
}

- (void)removeNotificationsObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentSessionChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"settingsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationTrackingStart" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationTrackingStop" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"batteryTrackingStart" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"batteryTrackingStop" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackControllerDidChangeContent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"numberOfUnsyncedChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncStatusChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncerErrorLogMessageRecieved" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncerErrorLogMessageGone" object:nil];
}

- (void)releaseWeakProperties {
    self.startButton = nil;
    self.infoButton = nil;
    self.spotsButton = nil;
    self.syncButton = nil;
    self.logButton = nil;
    self.settingsButton = nil;
    self.geoIndicatorView = nil;
    self.batteryIndicatorView = nil;
    self.syncIndicatorView = nil;
    self.currentTrackInfo = nil;
    self.currentTrackStartTime = nil;
    self.todaySummary = nil;
    self.todaySummaryLabel = nil;
    self.syncLabel = nil;
    self.todaySummaryView = nil;
}

@end
