//
//  SH_DataHandler.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 26/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SH_User.h"
#import "SH_Stop.h"

@interface SH_DataHandler : NSObject
+ (SH_DataHandler*)sharedInstance;

@property (strong, nonatomic) SH_User *user;
@property (strong, nonatomic) NSMutableDictionary *stops;
@property (strong, nonatomic) NSMutableArray *buses;
@property (strong, nonatomic) NSMutableDictionary *busLines;
@property (strong, nonatomic) SH_Stop *inriaStop;
@property (strong, nonatomic) NSMutableArray *annotationsToRemove;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *busesRequestsTimer;

-(NSString*) sha1:(NSString*)input;
@end
