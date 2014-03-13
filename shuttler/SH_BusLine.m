//
//  SH_BusLine.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_BusLine.h"

@implementation SH_BusLine
-(id)initWithId:(int) lineId withName:(NSString*) lineName
{
    self = [super init];
    if(self){
        [self setName:lineName];
        [self setLineId:lineId];
    }
    return self;
}
@end
