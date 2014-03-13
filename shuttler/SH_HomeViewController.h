//
//  SH_HomeViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 14/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SH_BusLine.h"
#import "SH_Stop.h"
#import "SH_User.h"
#import "SH_Constants.h"

@interface SH_HomeViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, NSURLConnectionDelegate>
- (IBAction)hopOnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *circularMap;
@property CLLocationManager *locationManager;
@property NSMutableData *_responseData;

@property (weak, nonatomic) IBOutlet UIButton *_hopOnButton;
@property (weak, nonatomic) IBOutlet UILabel *nearestStopLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedArrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *busExptectedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *busExptectedContainer;
@property (weak, nonatomic) IBOutlet UILabel *nearestStopDescriptionlabel;
@property (weak, nonatomic) IBOutlet UIImageView *busIcon;

@property (strong, nonatomic) SH_User *user;
@property (strong, nonatomic) NSMutableDictionary *stops;
@property (strong, nonatomic) NSMutableArray *buses;
@property (strong, nonatomic) NSMutableDictionary *busLines;
@property (strong,nonatomic) SH_Stop *inriaStop;

@end