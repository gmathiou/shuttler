//
//  SH_Constants.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 9/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SH_Constants : NSObject
#define Server_URL @"http://localhost:8080/"
#define busAtStopThreshold 100 //100 meters radius
#define requestsTimeOut 50 //Seconds for request timeout
#define requestsFrequency 10.0 //Seconds for a request update
#define distanceThresholdLocationManager 20.0f //Meters
@end
