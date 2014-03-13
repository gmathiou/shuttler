//
//  SH_Stop.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_Stop.h"

@implementation SH_Stop

-(id)initWithId:(int) stopId withName:(NSString*) name withLocation:(CLLocation*) location inLine:(SH_BusLine*) line
{
    self = [super init];
    if(self){
        [self setStopId:stopId];
        [self setStopName:name];
        [self setLocation:location];
        [self setLine:line];
    }
    return self;
}

@end
