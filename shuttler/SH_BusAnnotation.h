//
//  SH_BusAnnotation.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 25/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface SH_BusAnnotation : NSObject <MKAnnotation>


@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
