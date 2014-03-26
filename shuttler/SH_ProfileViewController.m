//
//  SH_ProfileViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 17/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_ProfileViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "SH_Constants.h"
#import "SH_DataHandler.h"


@interface SH_ProfileViewController ()
@property SH_DataHandler *dataHandler;
@end

@implementation SH_ProfileViewController


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
    
    //Make back button white
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /* Round border on profile image */
    [self.userProfileImage.layer setMasksToBounds:YES];
    [self.userProfileImage.layer setCornerRadius:100.0];
    [self.userProfileImage.layer setBorderColor:[[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.25f] CGColor]];
    [self.userProfileImage.layer setBorderWidth:10.0];
    
    [self getGoogleProfileData];
    [self getDataFromShuttlerServer];
    
    _dataHandler = [SH_DataHandler sharedInstance];
}

-(void)getGoogleProfileData
{
    if(_user.image == nil) {
        
        /* Get profile data */
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        [plusService setAuthorizer:signIn.authentication];
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        GTMLoggerError(@"Error: %@", error);
                    } else {
                        NSString *name = [NSString stringWithFormat:@"%@",person.displayName];
                        [_user setName:name];
                        [_profileName setText:name];
                        GTLPlusPersonImage *profileImg = person.image;
                        NSString *strimag = profileImg.url;
                        NSString *largerImgURL = [strimag stringByReplacingOccurrencesOfString:@"sz=50" withString:@"sz=400"];
                        NSData *receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:largerImgURL]];
                        UIImage *img = [[UIImage alloc] initWithData:receivedData ];
                        receivedData=UIImageJPEGRepresentation(img,200);
                        _userProfileImage.image = [UIImage imageWithData:receivedData];
                        [_user setImage:receivedData];
                    }
                }];
    } else {
        _userProfileImage.image = [UIImage imageWithData:_user.image];
        [_profileName setText:_user.name];
    }
}

-(void)getDataFromShuttlerServer
{
    // Create the request.
    NSString *URL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/profile/%@",Server_URL, _user.email];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOutButtonPressed:(id)sender {
    [_dataHandler.busesRequestsTimer invalidate];
    [self signOut];
    [_user setImage:nil];
    [self presentLogin:self];
}

- (IBAction)presentLogin:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    SEL theUnwindSelector = @selector(goToLogin:);
    NSString *unwindSegueIdentifier = @"unwindToLoginSeque";
    
    UINavigationController *nc = [self navigationController];
    // Find the view controller that has this unwindAction selector (may not be one in the nav stack)
    UIViewController *viewControllerToCallUnwindSelectorOn = [nc viewControllerForUnwindSegueAction: theUnwindSelector
                                                                                 fromViewController: self
                                                                                         withSender: sender];
    // None found, then do nothing.
    if (viewControllerToCallUnwindSelectorOn == nil) {
        NSLog(@"No controller found to unwind too");
        [self performSegueWithIdentifier:@"profileToLoginSegue" sender:sender];
        return;
    }
    
    // Can the controller that we found perform the unwind segue.  (This is decided by that controllers implementation of canPerformSeque: method
    BOOL cps = [viewControllerToCallUnwindSelectorOn canPerformUnwindSegueAction: theUnwindSelector
                                                              fromViewController: self
                                                                      withSender: sender];
    // If we have permision to perform the seque on the controller where the unwindAction is implmented
    // then get the segue object and perform it.
    if (cps) {
        
        UIStoryboardSegue *unwindSegue = [nc segueForUnwindingToViewController: viewControllerToCallUnwindSelectorOn fromViewController: self identifier: unwindSegueIdentifier];
        
        [viewControllerToCallUnwindSelectorOn prepareForSegue: unwindSegue sender: self];
        
        [unwindSegue perform];
    }
}

- (void)signOut {
    [[GPPSignIn sharedInstance] signOut];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self._responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self._responseData appendData:data];
    //NSLog(@"Received Data");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    //NSLog(@"Connection");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:self._responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSString *rank = [res objectForKey:@"rank"];
    if(rank == nil)
        rank = @"0";
    NSString * views = [res objectForKey:@"views"];
    if(views == nil)
        views = @"0";
    NSString * km = [res objectForKey:@"kilometers"];
    if(km == nil)
        km = @"0";
    
    [_viewsLabel setText: [NSString stringWithFormat:@"%@",views]];
    [_rankLabel setText:[NSString stringWithFormat:@"#%@",rank]];
    [_kilometersLabel setText:[NSString stringWithFormat:@"%@",km]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Connection Error");
}

@end
