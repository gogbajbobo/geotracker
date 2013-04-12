//
//  STGTLocationTracker.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/3/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTTracker.h"
#import "STGTTrack.h"

@interface STGTLocationTracker : STGTTracker

- (void)startNewTrack;
- (void)deleteTrack:(STGTTrack *)track;
- (void)splitTrack;

@end
