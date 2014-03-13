//
//  SH_Bus.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_Bus.h"

@implementation SH_Bus

-(id)initWithLocation:(CLLocation*) location withLine:(SH_BusLine*) line withLastSeenStop:(SH_Stop*)lastSeenStop
{
    self = [super init];
    if(self){
        [self setCurrentLocation:location];
        [self setLine:line];
        [self setLastSeenStop:lastSeenStop];
    }
    return self;
}
@end
