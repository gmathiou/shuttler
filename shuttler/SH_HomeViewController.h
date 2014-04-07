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

@interface SH_HomeViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>

- (IBAction)hopOnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *circularMap;
@property (weak, nonatomic) IBOutlet UIButton *hopOnButton;
@property (weak, nonatomic) IBOutlet UILabel *nearestStopLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedArrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *busExptectedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *busExptectedContainer;
@property (weak, nonatomic) IBOutlet UILabel *nearestStopDescriptionlabel;
@property (weak, nonatomic) IBOutlet UIImageView *busIcon;

@end