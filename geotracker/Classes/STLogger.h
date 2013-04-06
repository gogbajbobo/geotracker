//
//  STLogger.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/6/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STSessionManagement.h"

@interface STLogger : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) id <STSession> session;

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type;

@end
