//
//  GRNSettingsViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 15/06/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreDataManager.h"

@interface GRNSettingsViewController () <UITextFieldDelegate>

@end

@implementation GRNSettingsViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.okButton.layer.borderColor = self.cancelButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.okButton.layer.borderWidth = self.cancelButton.layer.borderWidth = 1.0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.masterHostLabel.text = [defaults objectForKey:KeySystemURI];
    self.domainLabel.text = [defaults objectForKey:KeyDomainName];
    self.version.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    //Add Popupview
    self.popUpView.frame = self.view.bounds;
    self.popUpView.hidden = YES;
    [self.view addSubview:self.popUpView];
}

- (void)viewDidUnload {
    [self setVersion:nil];
    [self setMasterHostLabel:nil];
    [self setDomainLabel:nil];
    [self setPopUpTextField:nil];
    [self setPopUpView:nil];
    [self setOkButton:nil];
    [self setCancelButton:nil];
    [self setPopupHeading:nil];
    [super viewDidUnload];
}

-(BOOL)checkDetails
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![[userDefault objectForKey:KeyDomainName] length] ||
        ![[userDefault objectForKey:KeySystemURI] length])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter correct details to proceed"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    return YES;
}

- (IBAction)ok:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self.popupHeading.text hasPrefix:@"Master"])
    {
        
        if ([self.popUpTextField.text isEqualToString:[defaults objectForKey:KeySystemURI]])
        {
            self.popUpView.hidden = YES;
            [self.popUpTextField resignFirstResponder];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"If you change MasterHost all your buffered data will be deleted. Are you sure you wnat to change it?"
                                                           delegate:self
                                                  cancelButtonTitle:@"NO"
                                                  otherButtonTitles:@"YES",nil];
            [alert show];
            
        }
    }
    else if ([self.popupHeading.text hasPrefix:@"Domain"])
    {
        [defaults setValue:self.popUpTextField.text forKey:KeyDomainName];
        self.domainLabel.text = self.popUpTextField.text;
        self.popUpView.hidden = YES;
        [self.popUpTextField resignFirstResponder];
        [defaults synchronize];
    }
}

- (IBAction)closePopup:(id)sender
{
    self.popUpView.hidden = YES;
    [self.popUpTextField resignFirstResponder];
}

- (IBAction)showDomainPopup:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.popupHeading.text = @"Domain";
    self.popUpTextField.text = [defaults objectForKey:KeyDomainName];
    self.popUpView.hidden = NO;
    [self.view bringSubviewToFront:self.popUpView];
    [self.popUpTextField becomeFirstResponder];
}

- (IBAction)showMasterHostPopup:(id)sender
{
    self.popupHeading.text = @"Master Host";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.popUpTextField.text = [defaults objectForKey:KeySystemURI];
    self.popUpView.hidden = NO;
    [self.view bringSubviewToFront:self.popUpView];
    [self.popUpTextField becomeFirstResponder];
}

- (IBAction)back:(id)sender
{
    self.popUpView.hidden = YES;
    if ([self checkDetails])
        [self.navigationController popViewControllerAnimated:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        self.popUpView.hidden = YES;
        [self.popUpTextField resignFirstResponder];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *uri = [self.popUpTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        [defaults setValue:uri forKey:KeySystemURI];
        self.masterHostLabel.text = self.popUpTextField.text;
        [defaults synchronize];
        [CoreDataManager removeData:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self ok:nil];
    return YES;
}
@end
