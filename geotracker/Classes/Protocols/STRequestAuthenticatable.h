//
//  STGTRequestAuthenticatable.h
//  geotracking
//
//  Created by Maxim Grigoriev on 1/24/13.
//  Copyright (c) 2013 Maxim V. Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STRequestAuthenticatable <NSObject>

- (NSURLRequest *) authenticateRequest:(NSURLRequest *)request;


@end