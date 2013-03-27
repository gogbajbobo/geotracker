//
//  STGTManagedDocument.h
//  geotracker
//
//  Created by Maxim Grigoriev on 3/11/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface STGTManagedDocument : UIManagedDocument

@property(nonatomic, strong, readonly) NSManagedObjectModel *myManagedObjectModel;

+ (STGTManagedDocument *)documentWithUID:(NSString *)uid;

@end
