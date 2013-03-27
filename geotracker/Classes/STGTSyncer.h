//
//  STGTSyncer.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STGTRequestAuthenticatable.h"
#import "STGTSessionManagement.h"
#import "STGTManagedDocument.h"

@interface STGTSyncer : NSObject

@property (nonatomic, strong) id <STGTRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) id <STGTSession> session;

@end
