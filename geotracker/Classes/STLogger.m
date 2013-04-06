//
//  STLogger.m
//  geotracker
//
//  Created by Maxim Grigoriev on 4/6/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STLogger.h"
#import "STManagedDocument.h"
#import "STGTLogMessage.h"

@interface STLogger()

@property (strong, nonatomic) STManagedDocument *document;

@end


@implementation STLogger

- (void)setSession:(id<STSession>)session {
    _session = session;
    self.document = (STManagedDocument *)[(id <STSession>)session document];
}

- (void)saveLogMessageWithText:(NSString *)text type:(NSString *)type {
    STGTLogMessage *logMessage = (STGTLogMessage *)[NSEntityDescription insertNewObjectForEntityForName:@"STGTLogMessage" inManagedObjectContext:self.document.managedObjectContext];
    logMessage.text = text;
    logMessage.type = type;
    NSLog(@"%@", text);
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            NSLog(@"save logMessage success");
        }
    }];

}

@end
