//
//  GRNLoginViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) IBOutlet UIImageView *mgrnLogo;
@property (strong, nonatomic) IBOutlet UIView *hiddenView;

- (IBAction)dismissKeyboard:(id)sender;
@end
