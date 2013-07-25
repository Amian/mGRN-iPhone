//
//  GRNOrderItemDetailViewController.m
//  mGRN-iPhone
//
//  Created by Anum on 22/07/2013.
//  Copyright (c) 2013 Anum. All rights reserved.
//

#import "GRNOrderItemDetailViewController.h"
#import "PurchaseOrderItem+Management.h"
#import "GRNItem+Management.h"
#import "WBS+Management.h"
#import "CoreDataManager.h"
#import "GRN.h"
#import "RejectionReasons+Management.h"
#import "GRNM1XHeader.h"
#import "M1XmGRNService.h"
#import "LoadingView.h"
#import "GRNRejectionReasonTableViewController.h"
#import "GRNWbsTableViewController.h"
#import "GRNWbsTableViewController.h"

#define WBSCodeText @"Select WBS Code"
#define QuantityAlertTag 123

@interface GRNOrderItemDetailViewController () <M1XmGRNDelegate, WbsDelegate, UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, weak) UIView *selectedField;
@property BOOL quantityConfirmed;
@property (nonatomic, strong) NSString *quantityToConfirm;

@end

@implementation GRNOrderItemDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make sure these values are empty
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:KeyImage1];
    [defaults setObject:nil forKey:KeyImage2];
    [defaults setObject:nil forKey:KeyImage3];
    [defaults setObject:nil forKey:KeySignature];
    [defaults synchronize];
    
    [self displaySelectedItem];
}

-(void)viewDidAppear:(BOOL)animated
{
    //Notify when keyboard appears
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


#pragma mark - Keyboard Notifications

-(void)onKeyboardHide:(NSNotification *)notification
{
    self.dismissKeyboardButton.enabled = NO;
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //frame of keyboard
    CGRect rect = self.scrollView.frame;
    rect.size.height += keyboardFrame.size.height;
    self.scrollView.frame = rect;
    self.scrollView.contentSize = CGSizeZero;
}

-(void)onKeyboardShow:(NSNotification *)notification
{
    self.dismissKeyboardButton.enabled = YES;
    CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue]; //frame of keyboard
    CGRect rect = self.scrollView.frame;
    rect.size.height -= keyboardFrame.size.height;
    self.scrollView.frame = rect;
    self.scrollView.contentSize = self.view.frame.size;
    
    if (self.selectedField)
    {
        self.scrollView.contentOffset = CGPointMake(0.0, self.selectedField.frame.origin.y - 30.0);
    }
}

-(void)displaySelectedItem
{
    PurchaseOrderItem *item = self.grnItem.purchaseOrderItem;
    
    if (![self.grnItem.grn.purchaseOrder.contract.useWBS boolValue] && !self.wbsButton.hidden)
    {
        self.wbsButton.hidden = YES;
        self.wbsCodeLabel.hidden = YES;
        CGRect frame = self.viewBelowWbsCode.frame;
        frame.origin = self.wbsCodeLabel.frame.origin;
        self.viewBelowWbsCode.frame = frame;
    }
    else
    {
        //Get wbs if not present
        if (![[WBS fetchWBSCodesForContractNumber:self.grnItem.grn.purchaseOrder.contract.number
                                            inMOC:[CoreDataManager moc]] count])
        {
            [self getWBS];
        }
        else
        {
            
            WBS *wbs = [WBS fetchWBSWithCode:self.grnItem.wbsCode.length? self.grnItem.wbsCode : item.wbsCode inMOC:[CoreDataManager moc]];
            NSString *wbsCode = wbs.code.length? [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription] : WBSCodeText;
            [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
        }
    }
    
    self.itemLabel.text = item.itemNumber;
    self.descriptionLabel.text = item.itemDescription;
    [self.titleButton setTitle:item.itemDescription forState:UIControlStateNormal];
    self.expected.text = [NSString stringWithFormat:@"EA (%.02f expected)",[item.quantityBalance doubleValue]];
    self.titleButton.titleLabel.minimumFontSize = 8.0;
    self.titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleButton.titleLabel.adjustsLetterSpacingToFitWidth = YES;
    
    //Set Delivered and rejected quantities rounded to 2 decimal places
    double delivered = [self.grnItem.quantityDelivered doubleValue] > 0? [self.grnItem.quantityDelivered doubleValue] : [item.quantityBalance doubleValue];
    double rejected = [self.grnItem.quantityRejected doubleValue];
    
    self.quantityDelivered.text = delivered > 0.0? [NSString stringWithFormat:@"%.02f",delivered] : @"";
    self.quantityRejected.text = rejected > 0.0? [NSString stringWithFormat:@"%.02f",rejected] : @"";
    
    //Set Reason: If either rejected quantity is null or rejection code is null show "No Reason" as title
    RejectionReasons *reason = [RejectionReasons fetchReasonWithCode:self.grnItem.exception
                                                               inMOC:[CoreDataManager moc]];
    [self.reasonButton setTitle:reason == nil || rejected == 0.0 ? @"No Reason" : reason.codeDescription forState:UIControlStateNormal];
    self.reasonButton.titleLabel.minimumFontSize = 8.0;
    self.reasonButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.reasonButton.titleLabel.adjustsLetterSpacingToFitWidth = YES;
    
    
    self.note.text = self.grnItem.notes;
    
    //Show or hide serial number
    if ([item.plant boolValue])
    {
        self.serialNumber.hidden = NO;
        self.serialNumberLabel.hidden = NO;
        self.serialNumber.text = self.grnItem.serialNumber.length? self.grnItem.serialNumber : @"";
    }
    else
    {
        self.serialNumber.hidden = YES;
        self.serialNumberLabel.hidden = YES;
    }
}

-(void)getWBS
{
    [self startLoading];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        M1XmGRNService *service = [[M1XmGRNService alloc] init];
        service.delegate = self;
        NSString *kco = [[NSUserDefaults standardUserDefaults] objectForKey:KeyKCO];
        kco = [kco componentsSeparatedByString:@","].count > 0? [[kco componentsSeparatedByString:@","] objectAtIndex:0] : @"";
        [service GetWBSWithHeader:[GRNM1XHeader Header]
                   contractNumber:self.grnItem.grn.purchaseOrder.contract.number
                              kco:kco];
    }];
}

-(void)onAPIRequestFailure:(M1XResponse *)response
{
    
}

-(void)onAPIRequestSuccess:(NSDictionary *)response requestType:(RequestType)requestType
{
    NSArray *wbsData = [response objectForKey:@"wbsCodes"];
    NSManagedObjectContext *context = [CoreDataManager moc];
    for (NSDictionary *wbs in wbsData)
    {
        [WBS insertWBSCodesWithData:wbs
                        forContract:self.grnItem.grn.purchaseOrder.contract
             inManagedObjectContext:context
                              error:nil];
    }
    WBS *wbs = [WBS fetchWBSWithCode:self.grnItem.wbsCode.length? self.grnItem.wbsCode : self.grnItem.purchaseOrderItem.wbsCode inMOC:[CoreDataManager moc]];
    NSString *wbsCode = wbs.code.length? [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription] : WBSCodeText;
    [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
    [self stopLoading];
}

-(void)startLoading
{
    [self.view addSubview:self.loadingView];
}

-(void)stopLoading
{
    [self.loadingView removeFromSuperview];
}


-(UIView*)loadingView
{
    if(!_loadingView)
    {
        _loadingView = [[LoadingView alloc] initWithFrame:self.view.bounds];
    }
    return _loadingView;
}

-(void)RejectionReasonDidSelectReason:(RejectionReasons *)reason
{
    self.grnItem.exception = reason.code;
    [self.reasonButton setTitle:!reason.codeDescription.length ? @"No Reason" : reason.codeDescription forState:UIControlStateNormal];
}

-(void)wbsSelected:(WBS *)wbs
{
    self.grnItem.wbsCode = wbs.code;
    NSString *wbsCode = [NSString stringWithFormat:@"%@: %@",wbs.code,wbs.codeDescription];
    [self.wbsButton setTitle:wbsCode forState:UIControlStateNormal];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"back"])
    {
        NSString *error = [self checkItem:self.grnItem];
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        else
        {
            //Save Item
            self.grnItem.quantityDelivered = [NSNumber numberWithDouble:[self.quantityDelivered.text doubleValue]];
            self.grnItem.quantityRejected = [NSNumber numberWithDouble:[self.quantityRejected.text doubleValue]];
            if ([self.grnItem.quantityRejected doubleValue] <= 0.0) self.grnItem.exception = @"";
            self.grnItem.serialNumber = self.serialNumber.text;
            self.grnItem.notes = self.note.text;
        }
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reason"])
    {
        GRNRejectionReasonTableViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.selectedReasonCode = self.grnItem.exception;
    }
    else if ([segue.identifier isEqualToString:@"wbs"])
    {
        GRNWbsTableViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        vc.selectedWbsCode = self.grnItem.wbsCode;
        vc.dataArray = [self.grnItem.grn.purchaseOrder.contract.wbsCodes allObjects];
    }
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setDismissKeyboardButton:nil];
    [super viewDidUnload];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.selectedField = textField;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.selectedField = textView;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.selectedField = nil;
    return YES;
}

- (IBAction)dismissKeyBoard:(UIButton*)sender
{
    if (self.selectedField)
        [self.selectedField resignFirstResponder];
}


-(NSString*)checkItem:(GRNItem*)item
{
    NSMutableString *errorString = [NSMutableString string];
    if ([self.quantityDelivered.text doubleValue] != 0.0)
    {
        if (!self.wbsButton.hidden && [self.wbsButton.titleLabel.text isEqualToString:WBSCodeText])
        {
            [errorString appendFormat:@"Please enter WBS Code.\n"];
        }
        if (!self.serialNumber.hidden && ![self stripedTextLength:self.serialNumber.text])
        {
            [errorString appendFormat:@"Please enter serial number.\n"];
        }
    }
    
    if ([self.quantityDelivered.text doubleValue] < [self.quantityRejected.text doubleValue])
    {
        [errorString appendFormat:@"Rejected ￼quantity for item must not exceed the quantity ￼delivered.\n"];
    }
    else if ([self.quantityRejected.text doubleValue] > 0 && item.exception.length == 0)
    {
        [errorString appendFormat:@"Please select a rejection reason.\n"];
    }
    else if ([self.quantityRejected.text doubleValue] == 0)
    {
        item.exception = @"";
        [[CoreDataManager moc] save:nil];
    }
    
    double quantityBalance = [self.grnItem.purchaseOrderItem.quantityBalance doubleValue];
    int quantityError = [self.grnItem.grn.purchaseOrder.quantityError intValue];
    if ([self.quantityDelivered.text doubleValue] > quantityBalance)
    {
        switch (quantityError)
        {
            case 1:
            {
                [errorString appendFormat:@"Quantity delivered cannot exceed quantity balance.\n"];
                
                break;
            }
                //                case 2:
                //            {
                //
                //            }
            default:
                break;
        }
    }
    return errorString;
}

-(int)stripedTextLength:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([textField isEqual:self.quantityDelivered] && [textField.text doubleValue] < [newString doubleValue])
    {
        int quantityError = [self.grnItem.grn.purchaseOrder.quantityError intValue];
        if (!self.quantityConfirmed &&
            [newString doubleValue] > [self.grnItem.purchaseOrderItem.quantityBalance doubleValue] &&
            quantityError == 2)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The quantity delivered exceeds quantity balance."
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm",nil];
            self.quantityToConfirm = newString;
            alert.tag = QuantityAlertTag;
            [alert show];
            return NO;
        }
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == QuantityAlertTag)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            self.quantityConfirmed = YES;
            self.quantityDelivered.text = self.quantityToConfirm;
        }
    }
}
@end
