//
//  SH_Bus.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SH_Stop.h"
#import "SH_BusLine.h"

@interface SH_Bus : NSObject
-(id)initWithLocation:(CLLocation*) location withLine:(SH_BusLine*) line withLastSeenStop:(SH_Stop*)lastSeenStop;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) SH_Stop *lastSeenStop;
@property (strong, nonatomic) SH_BusLine *line;
@end
