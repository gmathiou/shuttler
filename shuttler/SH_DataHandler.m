//
//  SH_DataHandler.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 26/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_DataHandler.h"

@implementation SH_DataHandler

+ (SH_DataHandler*)sharedInstance
{
    //Singleton
    static SH_DataHandler *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SH_DataHandler alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        _user                   = [[SH_User alloc] init];//This is the current user
        _buses                  = [NSMutableArray array]; //All available buses
        _busLines               = [NSMutableDictionary dictionary]; //All available bus lines
        _stops                  = [NSMutableDictionary dictionary]; //All available stops
        _annotationsToRemove    = [NSMutableArray array];
        _locationManager        = [[CLLocationManager alloc] init];
    }
    return self;
}

@end
