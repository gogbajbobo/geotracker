//
//  STGTLogMessage.h
//  geotracker
//
//  Created by Maxim Grigoriev on 4/6/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STGTDatum.h"


@interface STGTLogMessage : STGTDatum

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * text;

@end
