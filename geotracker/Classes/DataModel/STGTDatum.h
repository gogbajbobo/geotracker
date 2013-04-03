//
//  STGTDatum.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/2/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface STGTDatum : NSManagedObject

@property (nonatomic, retain) NSDate * cts;
@property (nonatomic, retain) NSDate * lts;
@property (nonatomic, retain) NSDate * sqts;
@property (nonatomic, retain) NSDate * sts;
@property (nonatomic, retain) NSDate * ts;
@property (nonatomic, retain) NSData * xid;
@property (nonatomic, retain) NSNumber * id;

@end
