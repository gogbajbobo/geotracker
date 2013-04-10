//
//  STAuthBasic.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UDPushAuth/UDOAuthBasicAbstract.h>
#import "STRequestAuthenticatable.h"

@interface STAuthBasic : UDOAuthBasicAbstract <STRequestAuthenticatable>

- (NSString *) reachabilityServer;
+ (id) tokenRetrieverMaker;


@end
