//
//  SH_RegisterViewController.h
//  shuttler
//
//  Created by Georgios Mathioudakis on 5/4/14.
//  Copyright (c) 2014 fr.inria.arles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SH_RegisterViewController : UIViewController
- (IBAction)registerButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *errorMsgImage;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *formScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *registerLoadingIndicator;

@end
