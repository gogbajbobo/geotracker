//
//  STGTManagedDocument.m
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STManagedDocument.h"

@interface STManagedDocument()

@property (nonatomic) BOOL saving;

@end

@implementation STManagedDocument
@synthesize myManagedObjectModel = _myManagedObjectModel;

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


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

- (void)saveDocument:(void (^)(BOOL success))completionHandler {
    
    if (!self.saving) {
        if (self.documentState == UIDocumentStateNormal) {
            self.saving = YES;
            //        NSLog(@"fileURL %@", self.fileURL);
            [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                self.saving = NO;
                if (success) {
                    //                NSLog(@"UIDocumentSaveForOverwriting success");
                    completionHandler(YES);
                } else {
                    NSLog(@"UIDocumentSaveForOverwriting not success");
                    NSLog(@"self %@", self);
                }
            }];
        } else {
            NSLog(@"documentState != UIDocumentStateNormal for document: %@", self);
        }
    }
}

+ (STManagedDocument *)documentWithUID:(NSString *)uid {

    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"STGT_%@.%@", uid, @"sqlite"]];
    STManagedDocument *document = [[STManagedDocument alloc] initWithFileURL:url];
    document.persistentStoreOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//            [document closeWithCompletionHandler:^(BOOL success) {
//                [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"document UIDocumentSaveForCreating success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
            }
//                }];
//            }];
        }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"document openWithCompletionHandler success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
            }
        }];
    } else if (document.documentState == UIDocumentStateNormal) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"documentReady" object:document userInfo:[NSDictionary dictionaryWithObject:uid forKey:@"uid"]];
    }
    
    return document;
    
}

@end
