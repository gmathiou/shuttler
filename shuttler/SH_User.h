//
//  SH_User.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SH_Stop.h"
#import "SH_Bus.h"
#import "SH_BusLine.h"

@interface SH_User : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSData *image;
@property BOOL onBoard;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) SH_Bus *closestBus;
@property (strong, nonatomic) CLLocation *hopedOnLocation;
@property (strong, nonatomic) SH_Stop *closestStop;
@property double distanceTravelled;
@property (strong, nonatomic) SH_BusLine *busLine;
@property (strong, nonatomic) SH_Bus *onBoardBus;
@end
