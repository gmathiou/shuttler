//
//  SH_HomeViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 14/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_HomeViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "SH_ProfileViewController.h"
#import "SH_StopAnnotation.h"
#import "SH_BusAnnotation.h"

@interface SH_HomeViewController ()
@property NSMutableArray * annotationsToRemove; //Used for clearing the map markers
@property NSTimer *busesRequests;
@end

@implementation SH_HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _user                   = [[SH_User alloc] init];//This is the current user
    _buses                  = [NSMutableArray array]; //All available buses
    _busLines               = [NSMutableDictionary dictionary]; //All available bus lines
    _stops                  = [NSMutableDictionary dictionary]; //All available stops
    _annotationsToRemove    = [NSMutableArray array]; //Annotation to be removed from map at each loop
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    [_user setEmail:signIn.authentication.userEmail];
    
    [self locationTrackingInit];
    [self mapInit];
    
    [self requestBusLines];
    [self requestStops];
    [self requestBusesForLine];
    
    //Frequent update of available buses. Default time set to 10s.
    _busesRequests = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestBusesForLine) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * Google plus method for disconnection
 */
- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        NSLog(@"Received error. Google+ disconnection %@", error);
    } else {
        // The user is signed out and disconnected.
        // Clean up user data as specified by the Google+ terms.
    }
}

#pragma mark - Location specific methods
/**
 * Initializes location tracking
 */
-(void)locationTrackingInit
{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:10.0f];
    [self.locationManager startUpdatingLocation];
}

/**
 * Initializes Map and map functions
 */
-(void)mapInit
{
    //Stylize map
    [self.circularMap.layer setMasksToBounds:YES];
    [self.circularMap.layer setCornerRadius:140.0];
    [self.circularMap.layer setBorderColor:[[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.25f] CGColor]];
    [self.circularMap.layer setBorderWidth:10.0];
    [self.circularMap setZoomEnabled:true];
    self.circularMap.delegate = self;
    
    //Dummy center to map, and zoom
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.020;
    span.longitudeDelta = 0.020;
    CLLocationCoordinate2D location;
    location.latitude = 48.873934;
    location.longitude = 2.2949;
    region.span = span;
    region.center = location;
    [self.circularMap setRegion:region animated:YES];
}

/**
 * Called when the location on the Map is updated. 
 * Note that it is different from the location API didUpdateLocations which is called by the location manager
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.015;
    span.longitudeDelta = 0.015;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.circularMap setRegion:region animated:YES];
}

/**
 * Called when the location on the Map is updated. Location Manager overriden function
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [_user setCurrentLocation:[locations lastObject]]; //Set the current location to the user Object
    
    //Do the update location requests only if user is On board the bus
    if(_user.onBoard == YES){
        
        if([_user.currentLocation distanceFromLocation:_inriaStop.location] < busAtStopThreshold && _user.onBoard == YES) { //Show a message when bus arrives at Inria
            [self hopOff];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"arrived_msg", nil)]
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"stop_updating_msg", nil)]
                                                           delegate:nil
                                                  cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"all_right", nil)]
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/updatelocation/",Server_URL];
        
        //Construct the JSON here. Like string for now
        NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"lat\":\"%f\",\"lon\":\"%f\",\"line\":\"%d\",\"lastSeenStopID\":\"%d\"}",
                          _user.email,
                          _user.currentLocation.coordinate.latitude,
                          _user.currentLocation.coordinate.longitude,
                          _user.busLine.lineId,
                          _user.onBoardBus.lastSeenStop.stopId];
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:requestURL]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        [request setTimeoutInterval:requestsTimeOut];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    [self findNearestStop];
    [self findNearestBus];
    [self updateBusLastSeenStop];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Error while getting core location : %@",[error localizedFailureReason]);
}

/**
 * Handles annotation on top of the map
 */
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *stopAnnotationIdentifier=@"StopsAnnotationIdentifier";
    static NSString *busAnnotationIdentifier=@"BusAnnotationIdentifier";
    
    if([annotation isKindOfClass:[SH_StopAnnotation class]]){
        //Try to get an unused annotation, similar to uitableviewcells
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:stopAnnotationIdentifier];
        //If one isn't available, create a new one
        if(!annotationView){
            annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stopAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.image=[UIImage imageNamed:@"stop_pin.png"];
        }
        return annotationView;
    } else if([annotation isKindOfClass:[SH_BusAnnotation class]]){
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:busAnnotationIdentifier];
        //If one isn't available, create a new one
        if(!annotationView){
            annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:busAnnotationIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.calloutOffset = CGPointMake(0, 0);
            annotationView.image=[UIImage imageNamed:@"bus_pin.png"];
        }
        return annotationView;
    }
    return nil;
}

#pragma mark - Asynchronous requests & responses
/**
 * Makes a request to the server in order to get the available buses for a specific line
 */
- (void)requestBusesForLine
{
    NSString *URL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/busesforline/%@/%d",Server_URL,_user.email, _user.closestStop.line.lineId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 * Gets the available stops from the server
 */
- (void)requestStops
{
    NSString *URL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/stops",Server_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

/**
 * Gets the available Bus Lines from the server
 */
- (void)requestBusLines
{
    NSString *URL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/lines",Server_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self._responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self._responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self._responseData options:NSJSONReadingMutableLeaves error:&myError]; // convert to JSON

    [_circularMap removeAnnotations:_annotationsToRemove];//Remove old markers
    [_annotationsToRemove removeAllObjects];

    if ([res objectForKey:@"buses"]!=nil) {
        [_buses removeAllObjects]; //Remove old entries
        
        // Iterate buses
        for (NSDictionary *result in [res objectForKey:@"buses"]) {
            NSString *latitude = [result objectForKey:@"latitude"];
            NSString *longitude = [result objectForKey:@"longitude"];
            NSString *lineId = [result objectForKey:@"lineid"];
            NSString *lastSeenStopId = [result objectForKey:@"lastSeenStopID"];
            
            CLLocation *newBusLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            if([_busLines objectForKey:lineId] == nil) //No such line exists. Something bad happened
                return;
            
            SH_Bus *newBus = [[SH_Bus alloc] initWithLocation:newBusLocation withLine:[_busLines objectForKey:lineId] withLastSeenStop:[_stops objectForKey:lastSeenStopId]];
            [_buses addObject:newBus];
            
            CLLocationCoordinate2D annotationCoord;
            annotationCoord.latitude = [latitude doubleValue];
            annotationCoord.longitude = [longitude doubleValue];
            
            SH_BusAnnotation *annotationPoint = [[SH_BusAnnotation alloc] init];
            annotationPoint.coordinate = annotationCoord;
            annotationPoint.title = ((SH_BusLine *) [_busLines objectForKey:lineId]).name;
            [self.circularMap addAnnotation:annotationPoint];
            [self.annotationsToRemove addObject:annotationPoint];
        }
        [self findNearestBus];
    }
    else if([res objectForKey:@"lines"]!=nil)
    {
        // Iterate stops
        for (NSDictionary *result in [res objectForKey:@"lines"]) {
            NSString *lineId = [result objectForKey:@"id"];
            NSString *lineName = [result objectForKey:@"name"];
            
            SH_BusLine *newLine = [[SH_BusLine alloc] initWithId:[lineId intValue] withName:lineName];
            [_busLines setObject:newLine forKey:lineId];
        }
    }
    else if([res objectForKey:@"stops"]!=nil)
    {
        [_stops removeAllObjects]; //Remove old entries
        
        // Iterate stops
        for (NSDictionary *result in [res objectForKey:@"stops"]) {
            NSString *stopId = [result objectForKey:@"id"];
            NSString *name = [result objectForKey:@"name"];
            NSString *latitude = [result objectForKey:@"latitude"];
            NSString *longitude = [result objectForKey:@"longitude"];
            NSString *lineId = [result objectForKey:@"lineId"];
            
            CLLocation *newStopLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
            SH_Stop *newStop = [[SH_Stop alloc] initWithId:[stopId intValue]
                                                withName:name
                                                withLocation:newStopLocation
                                                inLine:[_busLines objectForKey:lineId]];
            [_stops setObject:newStop forKey: stopId];
        
            CLLocationCoordinate2D annotationCoord;
            annotationCoord.latitude = [latitude doubleValue];
            annotationCoord.longitude = [longitude doubleValue];

            SH_StopAnnotation *annotationPoint = [[SH_StopAnnotation alloc] init];
            annotationPoint.coordinate = annotationCoord;
            annotationPoint.title = newStop.stopName;
            annotationPoint.subtitle = [NSString stringWithFormat:NSLocalizedString(@"stop_subtitle", nil)];
            [self.circularMap addAnnotation:annotationPoint];
            
            if([newStop.stopName isEqual: @"Inria"])
                _inriaStop = newStop;
        }
        [self findNearestStop];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection Error");
}

#pragma - Hop-on-off handlers
/**
 * Hop on pressed handlers
 */
- (IBAction)hopOnPressed:(id)sender {
    if(_user.onBoard == NO){
        [self hopOn];
    } else {
        [self hopOff];
    }
}

/** 
 * Handles the hop-on event
 */
-(void)hopOn
{
    [_user setOnBoard: YES];
    [_user setOnBoardBus:[[SH_Bus alloc] initWithLocation:_user.currentLocation withLine:_user.busLine withLastSeenStop:_user.closestStop]];
    [_user setHopedOnLocation: _user.currentLocation]; //Keep the initial location to calculate total km on Hop-off
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/hopon/",Server_URL]; //Update the server
    
    //UI adjustments
    [self._hopOnButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"hop_off", nil)] forState:UIControlStateNormal];
    [self._hopOnButton setBackgroundColor:[UIColor colorWithRed:(60/255.0) green:(143/255.0) blue:(173/255.0) alpha:1] ];
    
    //Stop the bus request timer. An on-board user should not see buses. And remove all buses from the map
    [_busesRequests invalidate];
    [self.circularMap removeAnnotations:self.annotationsToRemove];
    [self.annotationsToRemove removeAllObjects];
    
    //Construct JSON as string and send the request to server
    NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"lat\":\"%f\",\"lon\":\"%f\",\"line\":\"%d\"}",
                      _user.email,
                      _user.currentLocation.coordinate.latitude,
                      _user.currentLocation.coordinate.longitude,
                      _user.busLine.lineId];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:requestsTimeOut];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self updateUI];
}

/**
 * Handles the hop-off event
 */
-(void)hopOff
{
    [_user setOnBoard: NO];
    [_user setOnBoardBus:nil];
    NSString *requestURL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/hopoff/",Server_URL];
    [self._hopOnButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"hop_on", nil)]  forState:UIControlStateNormal];
    [self._hopOnButton setBackgroundColor:[UIColor colorWithRed:(95/255.0) green:(197/255.0) blue:(229/255.0) alpha:1] ];
    
    _busesRequests = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(requestBusesForLine) userInfo:nil repeats:YES];
    [self calculateKilometers];
    
    //Construct JSON as string
    NSString *post = [NSString stringWithFormat: @"{\"email\":\"%@\",\"kilometers\":\"%f\"}",
                      _user.email,
                      _user.distanceTravelled];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:20];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [self findNearestStop];
    [self updateUI];
}

/**
 * Adjust UI when hop-on-off
 */
-(void)updateUI
{
    if(_user.onBoard==YES){
        //Hide elements
        [UIView animateWithDuration:0.2f animations:^{
            _busExptectedLabel.alpha = 0.0f;
            _expectedArrivalTimeLabel.alpha = 0.0f;
            _busIcon.alpha = 1.0f;
        }];
        [_nearestStopDescriptionlabel setText:[NSString stringWithFormat:NSLocalizedString(@"on_board",nil)]];
        [_nearestStopLabel setText: [NSString stringWithFormat:@"%@", _user.closestStop.line.name]];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            _busIcon.alpha = 0.0f;
            _busExptectedLabel.alpha = 1.0f;
            _expectedArrivalTimeLabel.alpha = 1.0f;
        }];
        [_nearestStopDescriptionlabel setText:[NSString stringWithFormat:NSLocalizedString(@"nearest_stop",nil)]];
    }
}

/**
 * Identify the closest stop to the user based on his location
 * Used when user is not on-board the bus
 */
-(void)findNearestStop
{
    double distanceFromNearestStop = 0;
    
    // Iterate stops
    for (id key in _stops) {
        CLLocationCoordinate2D annotationCoord;
        SH_Stop *stop = [_stops objectForKey:key];
        annotationCoord.latitude = stop.location.coordinate.latitude;
        annotationCoord.longitude = stop.location.coordinate.longitude;
        
        double distanceFromUser = [_user.currentLocation distanceFromLocation:stop.location];
        if(distanceFromNearestStop == 0 || distanceFromUser < distanceFromNearestStop){
            distanceFromNearestStop = distanceFromUser;
            [_user setClosestStop: stop];
        }
    }
    [_nearestStopLabel setText:_user.closestStop.stopName];
    [_user setBusLine: _user.closestStop.line]; //User is interested for the line passing from the stop that he is closest to
}

/**
 * Identify the closest bus to the user based on his location
 * Used when user is not on-board the bus
 */
-(void)findNearestBus
{
    double distanceFromNearestBus = 0;
    [_user setClosestBus:nil];
    
    for (SH_Bus *bus in _buses) {
        if(bus.line.lineId == _user.busLine.lineId && bus.lastSeenStop.stopId <= _user.closestStop.stopId){ //Check only buses passing through my stop and are behind my stop
            double distanceFromUser = [_user.currentLocation distanceFromLocation:bus.currentLocation];
            if(distanceFromNearestBus == 0 || distanceFromUser < distanceFromNearestBus){
                distanceFromNearestBus = distanceFromUser;
                _user.closestBus = bus;
            }
        }
    }
    [self findDirectionsFrom];
}

/**
 * Calculates the expected arrival time of the closest bus
 * Uses the map traffic API
 */
- (void)findDirectionsFrom
{
    if(_user.closestBus == nil) {
        [_expectedArrivalTimeLabel setText:@"--:--"];
        return;
    }
    CLLocationCoordinate2D sourceCoordinate = CLLocationCoordinate2DMake(_user.closestBus.currentLocation.coordinate.latitude,_user.closestBus.currentLocation.coordinate.longitude);
    MKPlacemark *_srcMark = [[MKPlacemark alloc] initWithCoordinate:sourceCoordinate addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:_srcMark];
    MKMapItem *destination = [MKMapItem mapItemForCurrentLocation];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.destination = destination;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    __block typeof(self) weakSelf = self;
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            [_expectedArrivalTimeLabel setText:@"--:--"];
            NSLog(@"There was an error getting your directions");
            return;
        }
        
        MKRoute *currentRoute = [response.routes firstObject];
        NSDate *now = [NSDate date];
        NSDate *dateETA = [now dateByAddingTimeInterval:currentRoute.expectedTravelTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"HH:mm";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [_expectedArrivalTimeLabel setText:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:dateETA]]];
    }];
}

/**
 * Calculate total km when the user hops-off
 */
- (double)calculateKilometers
{
    double distance = 0;
    if(_user.hopedOnLocation == nil)
        return distance;
    
    CLLocationCoordinate2D sourceCoordinate = CLLocationCoordinate2DMake(_user.hopedOnLocation.coordinate.latitude,_user.hopedOnLocation.coordinate.longitude);
    MKPlacemark *_srcMark = [[MKPlacemark alloc] initWithCoordinate:sourceCoordinate addressDictionary:nil];
    MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:_srcMark];
    MKMapItem *destination = [MKMapItem mapItemForCurrentLocation];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = source;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.destination = destination;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    __block typeof(self) weakSelf = self;
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"There was an error getting your directions");
        }
        MKRoute *currentRoute = [response.routes firstObject];
        [_user setDistanceTravelled:currentRoute.distance / 1000];
    }];
    return _user.distanceTravelled;
}

/**
 * Updates the Last stop that the bus was seen. 
 * This used to define whether the bus has passed from a specific stop.
 */
-(void)updateBusLastSeenStop
{
    if(_user.onBoard == NO)
        return;
    
    for (id key in _stops) {
        SH_Stop *stop = [_stops objectForKey:key];
        if([_user.currentLocation distanceFromLocation:stop.location] < busAtStopThreshold )
        {
            //Me (on board the bus) approaching to a stop.
            if(_user.onBoardBus!=nil)
                [_user.onBoardBus setLastSeenStop:stop];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"homeToProfileSegue"])
    {
        SH_ProfileViewController *profile = [segue destinationViewController];
        [profile setUser:_user];
    }
}

@end