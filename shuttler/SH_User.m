//
//  SH_User.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_User.h"

@implementation SH_User
-(id)init
{
    self = [super init];
    if(self){
        _busLine = [[SH_BusLine alloc] init];
    }
    return self;
}
@end
