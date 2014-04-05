//
//  SH_ViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 13/2/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPPSignInButton;

@interface SH_LoginViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *formScrollView;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)signInButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorMsgImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *signInLoadingIndicator;

@end

