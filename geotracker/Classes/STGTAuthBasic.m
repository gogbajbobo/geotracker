//
//  STAuthBasic.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/10/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTAuthBasic.h"
#import <UDPushAuth/UDAuthTokenRetriever.h>
#import <UDPushAuth/UDPushAuthCodeRetriever.h>
#import <UDPushAuth/UDPushAuthRequestBasic.h>

#define TOKEN_SERVER_URL @"system.unact.ru"
//#define AUTH_SERVICE_URI @"https://uoauth.unact.ru/a/UPushAuth/"
//#define AUTH_SERVICE_PARAMETERS @"app_id=geotracking-dev"
#define AUTH_SERVICE_URI @"https://system.unact.ru/asa/"
#define AUTH_SERVICE_PARAMETERS @"_host=uoauth&app_id=geotracking-dev&_svc=a/upushauth/"

@implementation STGTAuthBasic

- (NSString *) reachabilityServer{
    return TOKEN_SERVER_URL;
}

- (void) tokenReceived:(UDAuthToken *) token{
    [super tokenReceived:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenReceived" object:self];
}

+ (id) tokenRetrieverMaker{
    
    UDAuthTokenRetriever *tokenRetriever = [[UDAuthTokenRetriever alloc] init];
    tokenRetriever.authServiceURI = [NSURL URLWithString:AUTH_SERVICE_URI];
    
    UDPushAuthCodeRetriever *codeRetriever = [UDPushAuthCodeRetriever codeRetriever];
    codeRetriever.requestDelegate.uPushAuthServiceURI = [NSURL URLWithString:AUTH_SERVICE_URI];
    
#if DEBUG
    [(UDPushAuthRequestBasic *)[codeRetriever requestDelegate] setConstantGetParameters:AUTH_SERVICE_PARAMETERS];
    
#else
    [(UDPushAuthRequestBasic *)[codeRetriever requestDelegate] setConstantGetParameters:[AUTH_SERVICE_PARAMETERS stringByReplacingOccurrencesOfString:@"-dev" withString:@""]];

#endif
    tokenRetriever.codeDelegate = codeRetriever;
    
    return tokenRetriever;
}

- (NSURLRequest *) authenticateRequest:(NSURLRequest *)request{
    NSMutableURLRequest *resultingRequest = nil;
    
    if (self.tokenValue != nil) {
        resultingRequest = [request mutableCopy];
        [resultingRequest addValue:[NSString stringWithFormat:@"Bearer %@",self.tokenValue] forHTTPHeaderField:@"Authorization"];
    }
    
    return resultingRequest;
}


@end
