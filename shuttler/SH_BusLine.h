//
//  SH_BusLine.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 12/3/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SH_BusLine : NSObject
-(id)initWithId:(int) lineId withName:(NSString*) lineName;
@property int lineId;
@property (strong, nonatomic) NSString *name;
@end
