//
//  STGTManagedDocument.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STGTManagedDocument.h"

@implementation STGTManagedDocument
@synthesize myManagedObjectModel = _myManagedObjectModel;

- (NSManagedObjectModel *)myManagedObjectModel {
    if (!_myManagedObjectModel) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"STGTDataModel" ofType:@"momd"];
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"STGTDataModel" ofType:@"mom"];
        }
//        NSLog(@"path %@", path);
        NSURL *url = [NSURL fileURLWithPath:path];
//        NSLog(@"url %@", url);
        _myManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    }
    return _myManagedObjectModel;
}

- (NSManagedObjectModel *)managedObjectModel {
    return self.myManagedObjectModel;
}

+ (STGTManagedDocument *)documentWithUID:(NSString *)uid {

    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"STGT_%@.%@", uid, @"sqlite"]];
    STGTManagedDocument *document = [[STGTManagedDocument alloc] initWithFileURL:url];
    document.persistentStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [document closeWithCompletionHandler:^(BOOL success) {
                [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"document UIDocumentSaveForCreating success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
            }
                }];
            }];
        }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"document openWithCompletionHandler success");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
        }];
    } else if (document.documentState == UIDocumentStateNormal) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
    }
    
    return document;
    
}



@end
