//
//  SH_BusAnnotation.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 25/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_BusAnnotation.h"

@implementation SH_BusAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        self.coordinate = coord;
    }
    return self;
}

@end
