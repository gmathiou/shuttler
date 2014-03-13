//
//  SH_Stop.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SH_BusLine.h"

@interface SH_Stop : NSObject
-(id)initWithId:(int) stopId withName:(NSString*) name withLocation:(CLLocation*) location inLine:(SH_BusLine*) line;
@property int stopId;
@property (strong, nonatomic) NSString *stopName;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) SH_BusLine *line;
@end
