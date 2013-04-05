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
@property (weak, nonatomic) IBOutlet UILabel *syncLabel;


@end

@implementation STGTMainViewController




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


#pragma mark - init view

- (void)initView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSessionState) name:@"sessionStatusChanged" object:nil];
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
    
//    [self startAnimationOfView:self.geoIndicatorView];
//    [self startAnimationOfView:self.batteryIndicatorView];

}

- (void)initIndicators {
    self.geoIndicatorView.alpha = 0;
    self.batteryIndicatorView.alpha = 0;
    self.syncIndicatorView.alpha = 0;
    self.syncLabel.text = @"";
}

- (void)checkSessionState {
    NSString *currentSessionUID = [[STSessionManager sharedManager] currentSessionUID];
    if (currentSessionUID) {
        STSession *currentSession = [[[STSessionManager sharedManager] sessions] objectForKey:currentSessionUID];
        if ([currentSession.status isEqualToString:@"running"]) {
            self.settingsButton.enabled = [[[currentSession.settingsController currentSettingsForGroup:@"general"] valueForKey:@"localAccessToSettings"] boolValue];
            self.spotsButton.enabled = YES;
            self.infoButton.enabled = YES;
            self.syncButton.enabled = !currentSession.syncer.syncing;
            self.startButton.enabled = !currentSession.locationTracker.trackerAutoStart;
            self.logButton.enabled = YES;
        } else {
            [self disableButtons];
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
        self.view = nil;
    }
}

@end
