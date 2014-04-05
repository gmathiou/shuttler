//
//  SH_ProfileViewController.m
//  shuttler
//
//  Created by Georgios Mathioudakis on 17/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import "SH_ProfileViewController.h"
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
    
    [self getDataFromShuttlerServer];
    
    _dataHandler = [SH_DataHandler sharedInstance];
    _profileName.text = _dataHandler.user.username;
}


-(void)getDataFromShuttlerServer
{
    // Create the request.
    NSString *URL = [NSString stringWithFormat:@"%@Shuttler-server/webapi/profile/%@",Server_URL, _user.username];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    
    // Create url connection and fire request
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOutButtonPressed:(id)sender {
    [_dataHandler.busesRequestsTimer invalidate];
    [self signOut];
    [self presentLogin:self];
}

- (IBAction)presentLogin:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    SEL theUnwindSelector = NSSelectorFromString(@"goToLogin:");
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
    _dataHandler.user.signedIn = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password_sha"];
    [defaults synchronize];
    [self presentLogin:self];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self._responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self._responseData appendData:data];
    //NSLog(@"Received Data");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
