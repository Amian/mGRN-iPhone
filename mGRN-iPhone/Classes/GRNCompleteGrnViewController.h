//
//  GRNCompleteGrnViewController.h
//  mGRN-iPhone
//
//  Created by Anum on 24/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GRN;
@interface GRNCompleteGrnViewController : UIViewController

@property (nonatomic, strong) GRN *grn;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UIView *photoView;
@property (strong, nonatomic) IBOutlet UITextView *comments;

- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)showDatePicker:(UIButton*)button;

@end
