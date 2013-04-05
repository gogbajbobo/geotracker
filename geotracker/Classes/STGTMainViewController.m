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
#import "STSession.h"

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

@property (nonatomic, strong) STSession *currentSession;


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

- (void)trackControllerDidChangeContent {
    NSLog(@"summaryInfo %@", self.trackController.summaryInfo);
    self.currentTrackStartTime.text = [NSString stringWithFormat:@"%@", [self.trackController.currentTrackInfo valueForKey:@"startTime"]];
    self.currentTrackInfo.text = [NSString stringWithFormat:@"%@ %@, %@ %@", [self.trackController.currentTrackInfo valueForKey:@"overallDistance"], NSLocalizedString(@"KM", @""), [self.trackController.currentTrackInfo valueForKey:@"averageSpeed"], NSLocalizedString(@"KM/H", @"")];
    NSLog(@"currentTrackInfo %@", self.trackController.currentTrackInfo);
}

#pragma mark - init view

- (void)initView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSessionChanged:) name:@"currentSessionChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSessionState) name:@"sessionStatusChanged" object:self.currentSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationTrackingStart) name:@"locationTrackingStart" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationTrackingStop) name:@"locationTrackingStop" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryTrackingStart) name:@"batteryTrackingStart" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryTrackingStop) name:@"batteryTrackingStop" object:self.currentSession.locationTracker];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackControllerDidChangeContent) name:@"trackControllerDidChangeContent" object:self.trackController];

    [self initButtonsImage];
    [self initIndicators];
    [self checkSessionState];
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
        self.trackController.document = self.currentSession.document;

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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentSessionChanged" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sessionStatusChanged" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationTrackingStart" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationTrackingStop" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"batteryTrackingStart" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"batteryTrackingStop" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackControllerDidChangeContent" object:nil];

        self.view = nil;
    }
}

@end
