//
//  GRNSettingsViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRNSettingsViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *version;

@property (strong, nonatomic) IBOutlet UILabel *masterHostLabel;
@property (strong, nonatomic) IBOutlet UILabel *domainLabel;

@property (strong, nonatomic) IBOutlet UITextField *popUpTextField;
@property (strong, nonatomic) IBOutlet UIButton *popUpView;

@property (strong, nonatomic) IBOutlet UILabel *popupHeading;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)closePopup:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)showDomainPopup:(id)sender;
- (IBAction)showMasterHostPopup:(id)sender;
- (IBAction)ok:(id)sender;

@end
