//
//  SH_ProfileViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 17/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SH_User.h"
#import "SH_HomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SH_ProfileViewController : UIViewController <FBLoginViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
- (IBAction)signOutButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *kilometersLabel;
@property (weak, nonatomic) IBOutlet FBLoginView *facebookLoginView;
@end
