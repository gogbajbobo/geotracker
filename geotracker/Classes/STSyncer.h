//
//  STGTSyncer.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STRequestAuthenticatable.h"
#import "STSessionManagement.h"
#import "STManagedDocument.h"

@interface STSyncer : NSObject

@property (nonatomic, strong) id <STRequestAuthenticatable> authDelegate;
@property (nonatomic, strong) id <STSession> session;

@end
